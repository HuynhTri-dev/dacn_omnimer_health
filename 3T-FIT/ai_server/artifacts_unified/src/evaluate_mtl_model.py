# -*- coding: utf-8 -*-
"""
evaluate_mtl_model.py

Script đánh giá chi tiết cho Multi-Task Learning (MTL) Model
Tính toán các metrics: Precision@K, Recall@K, F1@K, RMSE, MAE, R²
"""

import os
import json
import argparse
import numpy as np
import pandas as pd
import joblib
from typing import Dict, Tuple

import torch
import torch.nn as nn
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

# Import từ training script
import sys
sys.path.append(os.path.dirname(__file__))
from train_mtl_multilabel_weighted import MTLNet, parse_srw, build_labels, build_features


def precision_recall_f1_at_k(logits: torch.Tensor, y_true: torch.Tensor, K: int = 5) -> Tuple[float, float, float]:
    """
    Tính Precision@K, Recall@K và F1@K
    """
    probs = torch.sigmoid(logits)
    K = min(K, probs.shape[1])
    topk_indices = torch.topk(probs, k=K, dim=1).indices
    
    precisions, recalls, f1_scores = [], [], []
    
    for i in range(probs.shape[0]):
        pred_set = set(topk_indices[i].tolist())
        true_set = set(torch.nonzero(y_true[i]).squeeze(1).tolist())
        
        if len(pred_set) == 0:
            precisions.append(0.0)
            recalls.append(0.0)
            f1_scores.append(0.0)
            continue
        
        tp = len(pred_set & true_set)
        precision = tp / len(pred_set) if len(pred_set) > 0 else 0.0
        recall = tp / len(true_set) if len(true_set) > 0 else 0.0
        
        if precision + recall > 0:
            f1 = 2 * (precision * recall) / (precision + recall)
        else:
            f1 = 0.0
        
        precisions.append(precision)
        recalls.append(recall)
        f1_scores.append(f1)
    
    return float(np.mean(precisions)), float(np.mean(recalls)), float(np.mean(f1_scores))


def evaluate_regression(pred: np.ndarray, target: np.ndarray, 
                       param_ranges: Dict[str, Tuple[float, float]]) -> Dict[str, Dict[str, float]]:
    """
    Đánh giá regression task (sets, reps, load)
    
    Args:
        pred: Predictions [N, 3] (scaled [0,1])
        target: Ground truth [N, 3] (scaled [0,1])
        param_ranges: Dictionary of (min, max) for each parameter
    
    Returns:
        Dictionary of metrics for each parameter
    """
    param_names = ['sets', 'reps', 'load_kg']
    results = {}
    
    for idx, param_name in enumerate(param_names):
        # Inverse scale to original values
        lo, hi = param_ranges[param_name]
        pred_original = pred[:, idx] * (hi - lo) + lo
        target_original = target[:, idx] * (hi - lo) + lo
        
        # Filter out zero targets (invalid samples)
        valid_mask = target_original > 0
        
        if valid_mask.sum() == 0:
            results[param_name] = {
                'mae': np.nan,
                'rmse': np.nan,
                'r2': np.nan,
                'n_samples': 0
            }
            continue
        
        pred_valid = pred_original[valid_mask]
        target_valid = target_original[valid_mask]
        
        # Calculate metrics
        mae = mean_absolute_error(target_valid, pred_valid)
        rmse = np.sqrt(mean_squared_error(target_valid, pred_valid))
        
        try:
            r2 = r2_score(target_valid, pred_valid)
        except:
            r2 = np.nan
        
        results[param_name] = {
            'mae': float(mae),
            'rmse': float(rmse),
            'r2': float(r2),
            'n_samples': int(valid_mask.sum())
        }
    
    return results


def main(model_path: str, test_data_path: str, artifacts_dir: str):
    """
    Main evaluation function
    """
    print("=" * 80)
    print("MULTI-TASK LEARNING (MTL) MODEL EVALUATION")
    print("=" * 80)
    
    # Load model checkpoint first to get configuration
    print(f"\n[1/6] Loading model checkpoint from: {model_path}")
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    checkpoint = torch.load(model_path, map_location=device, weights_only=False)
    
    num_exercises = checkpoint.get('num_exercises', 200)
    in_dim = checkpoint.get('in_dim', 15)
    
    print(f"  ✓ Number of exercises: {num_exercises}")
    print(f"  ✓ Input dimension: {in_dim}")
    
    # Load preprocessor
    preprocessor_path = os.path.join(artifacts_dir, 'preprocessor.joblib')
    preprocessor = joblib.load(preprocessor_path)
    print(f"\n[2/6] Loaded preprocessor from: {preprocessor_path}")
    
    # Load test data
    print(f"\n[3/6] Loading test data from: {test_data_path}")
    test_df = pd.read_excel(test_data_path)
    print(f"  ✓ Loaded {len(test_df):,} test samples")
    
    # Prepare labels and targets
    y_cls, col_list = build_labels(test_df, max_labels=num_exercises)
    
    # Parse regression targets
    parsed = test_df['sets/reps/weight/timeresteachset'].apply(parse_srw)
    sets_arr = np.array([x[0] for x in parsed], dtype='float32')
    reps_arr = np.array([x[1] for x in parsed], dtype='float32')
    load_arr = np.array([x[2] for x in parsed], dtype='float32')
    
    # Calculate ranges from data (or use defaults)
    sets_min, sets_max = 1.0, 5.0
    reps_min, reps_max = 5.0, 20.0
    load_min, load_max = 0.0, 200.0
    
    # Try to get from checkpoint if available
    if 'sets_min' in checkpoint:
        sets_min, sets_max = checkpoint['sets_min'], checkpoint['sets_max']
        reps_min, reps_max = checkpoint['reps_min'], checkpoint['reps_max']
        load_min, load_max = checkpoint['load_min'], checkpoint['load_max']
    
    param_ranges = {
        'sets': (sets_min, sets_max),
        'reps': (reps_min, reps_max),
        'load_kg': (load_min, load_max)
    }
    
    print(f"  ✓ Using parameter ranges: sets=[{sets_min}, {sets_max}], reps=[{reps_min}, {reps_max}], load=[{load_min}, {load_max}]")
    
    # Scale targets
    sets_scaled = (sets_arr - sets_min) / max(1e-6, (sets_max - sets_min))
    reps_scaled = (reps_arr - reps_min) / max(1e-6, (reps_max - reps_min))
    load_scaled = (load_arr - load_min) / max(1e-6, (load_max - load_min))
    
    y_reg = np.column_stack([sets_scaled, reps_scaled, load_scaled])
    
    # Prepare features - Try to load from metadata first, fallback to build_features()
    metadata_path = os.path.join(artifacts_dir, 'metadata.json')
    if os.path.exists(metadata_path):
        # Exercise Recommendation Model - has metadata.json
        with open(metadata_path, 'r', encoding='utf-8') as f:
            metadata = json.load(f)
        feature_cols = metadata.get('features_used', build_features(test_df))
        print(f"  ✓ Loaded features from metadata: {len(feature_cols)} features")
    else:
        # MTL Model - use build_features()
        feature_cols = build_features(test_df)
        print(f"  ✓ Built features: {len(feature_cols)} features")
    
    X_test = test_df[feature_cols].copy()
    
    # Handle categorical columns
    categorical_cols = ['gender', 'experience_level', 'activity_level']
    for col in categorical_cols:
        if col in X_test.columns:
            X_test[col] = X_test[col].astype(str)
    
    X_test_transformed = preprocessor.transform(X_test)
    X_test_array = X_test_transformed.toarray() if hasattr(X_test_transformed, 'toarray') else np.asarray(X_test_transformed)
    
    print(f"  ✓ Preprocessed {X_test_array.shape[1]} features")
    
    # Initialize model
    print(f"\n[4/6] Initializing model...")
    
    model = MTLNet(
        in_dim=in_dim,
        num_exercises=num_exercises,
        hidden=256
    ).to(device)
    
    model.load_state_dict(checkpoint['model_state_dict'])
    model.eval()
    
    print(f"  ✓ Model loaded successfully")
    
    # Evaluate
    print(f"\n[5/6] Running evaluation...")
    
    X_tensor = torch.FloatTensor(X_test_array).to(device)
    y_cls_tensor = torch.FloatTensor(y_cls).to(device)
    y_reg_tensor = torch.FloatTensor(y_reg).to(device)
    
    with torch.no_grad():
        logits, reg_out = model(X_tensor)
        
        # Classification metrics
        p5, r5, f1_5 = precision_recall_f1_at_k(logits, y_cls_tensor, K=5)
        p10, r10, f1_10 = precision_recall_f1_at_k(logits, y_cls_tensor, K=10)
        
        # Regression metrics
        reg_pred_np = torch.sigmoid(reg_out).cpu().numpy()
        reg_target_np = y_reg
        
        regression_results = evaluate_regression(reg_pred_np, reg_target_np, param_ranges)
    
    # Print results
    print(f"\n[6/6] Evaluation Results:")
    print("=" * 80)
    
    print("\n📊 CLASSIFICATION METRICS (Exercise Recommendation)")
    print("-" * 80)
    print(f"  Precision@5:  {p5:.4f}")
    print(f"  Recall@5:     {r5:.4f}")
    print(f"  F1-Score@5:   {f1_5:.4f}")
    print(f"  Precision@10: {p10:.4f}")
    print(f"  Recall@10:    {r10:.4f}")
    print(f"  F1-Score@10:  {f1_10:.4f}")
    
    print("\n📈 REGRESSION METRICS (Intensity Parameters)")
    print("-" * 80)
    print(f"{'Parameter':<15} {'MAE':<12} {'RMSE':<12} {'R²':<12} {'Samples':<10}")
    print("-" * 80)
    
    for param_name in ['sets', 'reps', 'load_kg']:
        metrics = regression_results[param_name]
        if metrics['n_samples'] > 0:
            print(f"{param_name:<15} {metrics['mae']:<12.4f} {metrics['rmse']:<12.4f} "
                  f"{metrics['r2']:<12.4f} {metrics['n_samples']:<10}")
        else:
            print(f"{param_name:<15} {'N/A':<12} {'N/A':<12} {'N/A':<12} {0:<10}")
    
    # Performance assessment
    print("\n🎯 PERFORMANCE ASSESSMENT")
    print("-" * 80)
    
    def assess_metric(value, target, excellent):
        if value >= excellent:
            return "🌟 Excellent"
        elif value >= target:
            return "✅ Good"
        else:
            return "⚠️  Needs Improvement"
    
    print(f"  Classification P@5: {p5:.4f} - {assess_metric(p5, 0.70, 0.85)}")
    print(f"  Classification R@5: {r5:.4f} - {assess_metric(r5, 0.60, 0.75)}")
    
    if regression_results['sets']['n_samples'] > 0:
        sets_mae = regression_results['sets']['mae']
        print(f"  Regression Sets MAE: {sets_mae:.4f} - {assess_metric(1/sets_mae if sets_mae > 0 else 0, 1/0.5, 1/0.3)}")
    
    if regression_results['reps']['n_samples'] > 0:
        reps_mae = regression_results['reps']['mae']
        print(f"  Regression Reps MAE: {reps_mae:.4f} - {assess_metric(1/reps_mae if reps_mae > 0 else 0, 1/2.0, 1/1.0)}")
    
    if regression_results['load_kg']['n_samples'] > 0:
        load_mae = regression_results['load_kg']['mae']
        print(f"  Regression Load MAE: {load_mae:.4f} kg - {assess_metric(1/load_mae if load_mae > 0 else 0, 1/5.0, 1/3.0)}")
    
    # Save results
    results = {
        'classification': {
            'precision@5': p5,
            'recall@5': r5,
            'f1@5': f1_5,
            'precision@10': p10,
            'recall@10': r10,
            'f1@10': f1_10
        },
        'regression': regression_results,
        'test_samples': len(test_df),
        'model_path': model_path,
        'test_data_path': test_data_path
    }
    
    results_path = os.path.join(artifacts_dir, 'evaluation_results.json')
    with open(results_path, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    
    print(f"\n✅ Evaluation completed!")
    print(f"Results saved to: {results_path}")
    print("=" * 80)



if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Evaluate MTL Model')
    parser.add_argument('--model_path', type=str,
                       default='../artifacts_exercise_rec/best_model.pt',
                       help='Path to model checkpoint')
    parser.add_argument('--test_data', type=str,
                       default='../../../Data/data/merged_omni_health_dataset.xlsx',
                       help='Path to test data')
    parser.add_argument('--artifacts', type=str,
                       default='../artifacts_exercise_rec',
                       help='Directory containing artifacts')
    
    args = parser.parse_args()
    
    main(
        model_path=args.model_path,
        test_data_path=args.test_data,
        artifacts_dir=args.artifacts
    )

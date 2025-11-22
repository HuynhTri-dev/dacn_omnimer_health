# -*- coding: utf-8 -*-
"""
evaluate_exercise_model.py

Script đánh giá chi tiết cho Exercise Recommendation Model
Tính toán các metrics: Precision@K, Recall@K, F1@K, RMSE, MAE, R²
"""

import os
import json
import argparse
import numpy as np
import pandas as pd
import joblib
from typing import Dict, List, Tuple

import torch
import torch.nn as nn
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

# Import model từ training script
import sys
sys.path.append(os.path.dirname(__file__))
from train_exercise_recommendation import ExerciseRecommendationModel, normalize_exercise_name, parse_sets_reps_weight


def precision_recall_f1_at_k(logits: torch.Tensor, y_true: torch.Tensor, K: int = 5) -> Tuple[float, float, float]:
    """
    Tính Precision@K, Recall@K và F1@K
    
    Args:
        logits: Model predictions [N, num_exercises]
        y_true: Ground truth labels [N, num_exercises]
        K: Top K exercises to consider
    
    Returns:
        (precision, recall, f1_score)
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


def evaluate_regression(pred: np.ndarray, target: np.ndarray, mask: np.ndarray, 
                       intensity_scales: Dict, param_names: List[str]) -> Dict[str, Dict[str, float]]:
    """
    Đánh giá regression task với MAE, RMSE, R²
    
    Args:
        pred: Predictions [N, 8] (scaled [0,1])
        target: Ground truth [N, 8] (scaled [0,1])
        mask: Valid value mask [N, 8]
        intensity_scales: Dictionary of (min, max) for each parameter
        param_names: List of parameter names
    
    Returns:
        Dictionary of metrics for each parameter
    """
    results = {}
    
    for idx, param_name in enumerate(param_names):
        # Get valid samples (where mask == 1)
        valid_mask = mask[:, idx] > 0
        
        if valid_mask.sum() == 0:
            results[param_name] = {
                'mae': np.nan,
                'rmse': np.nan,
                'r2': np.nan,
                'n_samples': 0
            }
            continue
        
        pred_valid = pred[valid_mask, idx]
        target_valid = target[valid_mask, idx]
        
        # Inverse scale to original values
        lo, hi = intensity_scales[param_name]
        pred_original = pred_valid * (hi - lo) + lo
        target_original = target_valid * (hi - lo) + lo
        
        # Calculate metrics
        mae = mean_absolute_error(target_original, pred_original)
        rmse = np.sqrt(mean_squared_error(target_original, pred_original))
        
        # R² score (handle edge cases)
        try:
            r2 = r2_score(target_original, pred_original)
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
    print("EXERCISE RECOMMENDATION MODEL EVALUATION")
    print("=" * 80)
    
    # Load metadata
    metadata_path = os.path.join(artifacts_dir, 'metadata.json')
    with open(metadata_path, 'r', encoding='utf-8') as f:
        metadata = json.load(f)
    
    print(f"\n[1/6] Loading metadata from: {metadata_path}")
    print(f"  ✓ Model trained on: {metadata['timestamp']}")
    print(f"  ✓ Number of exercises: {metadata['num_exercises']}")
    
    # Load preprocessor
    preprocessor_path = os.path.join(artifacts_dir, 'preprocessor.joblib')
    preprocessor = joblib.load(preprocessor_path)
    print(f"\n[2/6] Loaded preprocessor from: {preprocessor_path}")
    
    # Load test data
    print(f"\n[3/6] Loading test data from: {test_data_path}")
    test_df = pd.read_excel(test_data_path)
    print(f"  ✓ Loaded {len(test_df):,} test samples")
    
    # Prepare test data (same as training)
    test_df['exercise_name_norm'] = test_df['exercise_name'].apply(normalize_exercise_name)
    
    exercise_to_idx = metadata['exercise_to_idx']
    intensity_scales = {k: tuple(v) for k, v in metadata['intensity_scales'].items()}
    param_names = metadata['intensity_params']
    features_used = metadata['features_used']
    
    # Create labels
    num_exercises = metadata['num_exercises']
    test_labels = np.zeros((len(test_df), num_exercises), dtype='float32')
    test_ex_idx = np.zeros(len(test_df), dtype='int64')
    
    for i, ex_name in enumerate(test_df['exercise_name_norm']):
        if ex_name in exercise_to_idx:
            idx = exercise_to_idx[ex_name]
            test_labels[i, idx] = 1.0
            test_ex_idx[i] = idx
    
    # Parse intensity parameters
    def parse_intensity_params(df):
        intensity_raw = np.zeros((len(df), 8), dtype='float32')
        
        if 'sets/reps/weight/timeresteachset' in df.columns:
            parsed = df['sets/reps/weight/timeresteachset'].apply(parse_sets_reps_weight)
            for i, (sets, reps, weight, rest) in enumerate(parsed):
                intensity_raw[i, 0] = sets if not np.isnan(sets) else 0
                intensity_raw[i, 1] = reps if not np.isnan(reps) else 0
                intensity_raw[i, 2] = weight if not np.isnan(weight) else 0
                intensity_raw[i, 5] = rest if not np.isnan(rest) else 0
        
        if 'distance_km' in df.columns:
            intensity_raw[:, 3] = pd.to_numeric(df['distance_km'], errors='coerce').fillna(0).values
        if 'duration_min' in df.columns:
            intensity_raw[:, 4] = pd.to_numeric(df['duration_min'], errors='coerce').fillna(0).values
        if 'avg_hr' in df.columns:
            intensity_raw[:, 6] = pd.to_numeric(df['avg_hr'], errors='coerce').fillna(0).values
        if 'max_hr' in df.columns:
            intensity_raw[:, 7] = pd.to_numeric(df['max_hr'], errors='coerce').fillna(0).values
        
        return intensity_raw
    
    test_intensity_raw = parse_intensity_params(test_df)
    
    # Scale intensity
    def scale_intensity(intensity_raw, scales):
        intensity_scaled = np.zeros_like(intensity_raw, dtype='float32')
        intensity_mask = np.zeros_like(intensity_raw, dtype='float32')
        
        for idx, key in enumerate(param_names):
            lo, hi = scales[key]
            col = intensity_raw[:, idx]
            
            valid_mask = col > 0
            intensity_mask[:, idx] = valid_mask.astype('float32')
            
            col_clipped = np.clip(col, lo, hi)
            col_scaled = (col_clipped - lo) / max(1e-6, (hi - lo))
            intensity_scaled[:, idx] = col_scaled
        
        return intensity_scaled, intensity_mask
    
    test_intensity, test_intensity_mask = scale_intensity(test_intensity_raw, intensity_scales)
    
    # Prepare features
    X_test = test_df[features_used].copy()
    
    # Handle categorical columns
    categorical_feature_names = ['gender', 'experience_level', 'activity_level']
    categorical_cols = [c for c in categorical_feature_names if c in X_test.columns]
    for col in categorical_cols:
        X_test[col] = X_test[col].astype(str)
    
    X_test_transformed = preprocessor.transform(X_test)
    X_test_array = X_test_transformed.toarray() if hasattr(X_test_transformed, 'toarray') else np.asarray(X_test_transformed)
    
    print(f"  ✓ Preprocessed {X_test_array.shape[1]} features")
    
    # Load model
    print(f"\n[4/6] Loading model from: {model_path}")
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    
    checkpoint = torch.load(model_path, map_location=device, weights_only=False)
    model = ExerciseRecommendationModel(
        input_dim=checkpoint['input_dim'],
        num_exercises=checkpoint['num_exercises'],
        embed_dim=128,
        hidden_dim=256,
        dropout=0.15
    ).to(device)
    
    model.load_state_dict(checkpoint['model_state_dict'])
    model.eval()
    
    print(f"  ✓ Model loaded (epoch {checkpoint['epoch']})")
    
    # Evaluate
    print(f"\n[5/6] Running evaluation...")
    
    X_tensor = torch.FloatTensor(X_test_array).to(device)
    y_labels_tensor = torch.FloatTensor(test_labels).to(device)
    y_intensity_tensor = torch.FloatTensor(test_intensity).to(device)
    intensity_mask_tensor = torch.FloatTensor(test_intensity_mask).to(device)
    ex_idx_tensor = torch.LongTensor(test_ex_idx).to(device)
    
    with torch.no_grad():
        suit_logits, int_pred = model(X_tensor)
        
        # Classification metrics
        p5, r5, f1_5 = precision_recall_f1_at_k(suit_logits, y_labels_tensor, K=5)
        p10, r10, f1_10 = precision_recall_f1_at_k(suit_logits, y_labels_tensor, K=10)
        
        # Regression metrics
        # Extract predictions for ground truth exercises
        batch_size = int_pred.size(0)
        gt_indices_expanded = ex_idx_tensor.view(batch_size, 1, 1).expand(batch_size, 1, 8)
        int_pred_gt = int_pred.gather(1, gt_indices_expanded).squeeze(1)  # [N, 8]
        
        int_pred_np = int_pred_gt.cpu().numpy()
        int_target_np = test_intensity
        int_mask_np = test_intensity_mask
        
        regression_results = evaluate_regression(
            int_pred_np, int_target_np, int_mask_np,
            intensity_scales, param_names
        )
    
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
    
    for param_name in param_names:
        metrics = regression_results[param_name]
        if metrics['n_samples'] > 0:
            print(f"{param_name:<15} {metrics['mae']:<12.4f} {metrics['rmse']:<12.4f} "
                  f"{metrics['r2']:<12.4f} {metrics['n_samples']:<10}")
        else:
            print(f"{param_name:<15} {'N/A':<12} {'N/A':<12} {'N/A':<12} {0:<10}")
    
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
    parser = argparse.ArgumentParser(description='Evaluate Exercise Recommendation Model')
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

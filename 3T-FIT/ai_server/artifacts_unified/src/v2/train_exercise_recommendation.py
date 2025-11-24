# -*- coding: utf-8 -*-
"""
train_exercise_recommendation.py

Model gợi ý bài tập với Exercise Embeddings
- Input: Health profile + danh sách exercise names (từ RAG/filtering)
- Output: 
  + Suitability scores cho từng exercise
  + Intensity parameters (sets, reps, kg, km, min, minRest, avgHR, peakHR)

Training: mapped_workout_dataset_20251120_012453.xlsx
Testing: merged_omni_health_dataset.xlsx

Key Features:
- Exercise name embeddings (learnable)
- Multi-task learning: classification + regression
- Exact exercise name matching (cho backend mapping)
"""

import os
import re
import json
import argparse
import numpy as np
import pandas as pd
import joblib
from typing import List, Dict, Tuple
from datetime import datetime

import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader

from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline

# ==================== UTILITIES ====================

def normalize_exercise_name(name: str) -> str:
    """
    Chuẩn hóa tên bài tập (giữ nguyên để mapping chính xác với database)
    """
    if pd.isna(name):
        return ""
    return str(name).strip()

def parse_sets_reps_weight(cell_value: str) -> Tuple[float, float, float, float]:
    """
    Parse chuỗi sets/reps/weight/timeresteachset
    Format: "8x50x3 | 10x45x2 | 12x40x1"
    Returns: (num_sets, median_reps, median_weight, median_rest)
    """
    if pd.isna(cell_value):
        return (np.nan, np.nan, np.nan, np.nan)
    
    try:
        parts = [p.strip() for p in str(cell_value).split("|")]
        reps_list, weights_list, rests_list = [], [], []
        
        for part in parts:
            # Parse format: reps x weight x rest_time
            nums = re.findall(r"(-?\d+\.?\d*)", part)
            if len(nums) >= 2:
                reps_list.append(float(nums[0]))
                weights_list.append(abs(float(nums[1])))  # abs for assisted machines
            if len(nums) >= 3:
                rests_list.append(float(nums[2]))
        
        if len(reps_list) == 0:
            return (np.nan, np.nan, np.nan, np.nan)
        
        num_sets = len(reps_list)
        median_reps = float(np.median(reps_list))
        median_weight = float(np.median(weights_list)) if len(weights_list) > 0 else np.nan
        median_rest = float(np.median(rests_list)) if len(rests_list) > 0 else np.nan
        
        return (num_sets, median_reps, median_weight, median_rest)
    
    except Exception:
        return (np.nan, np.nan, np.nan, np.nan)

# ==================== DATASET ====================

class ExerciseDataset(Dataset):
    """
    Dataset cho exercise recommendation
    """
    def __init__(self, X, y_suitability, y_intensity, intensity_mask, exercise_indices):
        """
        Args:
            X: Features [N, D]
            y_suitability: Suitability scores [N, num_exercises]
            y_intensity: Intensity parameters [N, 8] (scaled [0,1])
            intensity_mask: Mask for valid intensity values [N, 8]
            exercise_indices: Ground truth exercise index [N]
        """
        self.X = X.astype("float32")
        self.y_suit = y_suitability.astype("float32")
        self.y_int = y_intensity.astype("float32")
        self.int_mask = intensity_mask.astype("float32")
        self.ex_idx = exercise_indices.astype("int64")
    
    def __len__(self):
        return self.X.shape[0]
    
    def __getitem__(self, idx):
        return (
            torch.from_numpy(self.X[idx]),
            torch.from_numpy(self.y_suit[idx]),
            torch.from_numpy(self.y_int[idx]),
            torch.from_numpy(self.int_mask[idx]),
            torch.tensor(self.ex_idx[idx])
        )

# ==================== MODEL ====================

class ExerciseRecommendationModel(nn.Module):
    """
    Model gợi ý bài tập với exercise embeddings
    """
    def __init__(self, input_dim: int, num_exercises: int, 
                 embed_dim: int = 128, hidden_dim: int = 256, dropout: float = 0.15):
        super().__init__()
        
        # Health profile encoder
        self.health_encoder = nn.Sequential(
            nn.Linear(input_dim, hidden_dim),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dim, hidden_dim),
            nn.ReLU(),
            nn.Dropout(dropout)
        )
        
        # Exercise embeddings (learnable)
        self.exercise_embeddings = nn.Parameter(
            torch.randn(num_exercises, embed_dim) * 0.02
        )
        
        # Projection layer to match dimensions
        self.health_proj = nn.Linear(hidden_dim, embed_dim)
        
        # Suitability head (classification)
        # Input: [health_encoding, exercise_embedding, interaction]
        joint_dim = embed_dim * 3
        self.suitability_head = nn.Sequential(
            nn.Linear(joint_dim, hidden_dim),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dim, 1)  # Single score per exercise
        )
        
        # Intensity head (regression for 8 parameters)
        self.intensity_head = nn.Sequential(
            nn.Linear(joint_dim, hidden_dim),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dim, 128),
            nn.ReLU(),
            nn.Linear(128, 8)  # 8 intensity parameters
        )
    
    def forward(self, x):
        """
        Args:
            x: Health profile features [B, input_dim]
        
        Returns:
            suitability_scores: [B, num_exercises]
            intensity_params: [B, num_exercises, 8]
        """
        batch_size = x.size(0)
        
        # Encode health profile
        health_enc = self.health_encoder(x)  # [B, hidden_dim]
        health_proj = self.health_proj(health_enc)  # [B, embed_dim]
        
        # Get all exercise embeddings
        ex_emb = self.exercise_embeddings  # [num_exercises, embed_dim]
        num_exercises = ex_emb.size(0)
        
        # Expand for batch processing
        health_exp = health_proj.unsqueeze(1).expand(batch_size, num_exercises, -1)  # [B, N, E]
        ex_exp = ex_emb.unsqueeze(0).expand(batch_size, num_exercises, -1)  # [B, N, E]
        
        # Create joint representation: [health, exercise, interaction]
        interaction = health_exp * ex_exp  # [B, N, E]
        joint = torch.cat([health_exp, ex_exp, interaction], dim=-1)  # [B, N, 3*E]
        
        # Compute suitability scores
        suitability_logits = self.suitability_head(joint).squeeze(-1)  # [B, N]
        
        # Compute intensity parameters (with sigmoid for [0,1] range)
        intensity_raw = self.intensity_head(joint)  # [B, N, 8]
        intensity_scaled = torch.sigmoid(intensity_raw)  # [B, N, 8]
        
        return suitability_logits, intensity_scaled

# ==================== METRICS ====================

def precision_recall_at_k(logits, y_true, K=5):
    """
    Tính Precision@K và Recall@K
    """
    probs = torch.sigmoid(logits)
    K = min(K, probs.shape[1])
    topk_indices = torch.topk(probs, k=K, dim=1).indices
    
    precisions, recalls = [], []
    for i in range(probs.shape[0]):
        pred_set = set(topk_indices[i].tolist())
        true_set = set(torch.nonzero(y_true[i]).squeeze(1).tolist())
        
        if len(pred_set) == 0:
            precisions.append(0.0)
        else:
            precisions.append(len(pred_set & true_set) / len(pred_set))
        
        if len(true_set) == 0:
            recalls.append(0.0)
        else:
            recalls.append(len(pred_set & true_set) / len(true_set))
    
    return float(np.mean(precisions)), float(np.mean(recalls))

# ==================== MAIN TRAINING ====================

def main(train_path: str, test_path: str, artifacts_dir: str, 
         epochs: int = 100, batch_size: int = 64, lr: float = 1e-3,
         load_cap_kg: float = 200.0):
    """
    Main training function
    """
    print("=" * 80)
    print("EXERCISE RECOMMENDATION MODEL TRAINING")
    print("=" * 80)
    
    os.makedirs(artifacts_dir, exist_ok=True)
    
    # ==================== LOAD DATA ====================
    print(f"\n[1/10] Loading training data from: {train_path}")
    train_df = pd.read_excel(train_path)
    print(f"  ✓ Loaded {len(train_df):,} training records")
    
    print(f"\n[2/10] Loading test data from: {test_path}")
    test_df = pd.read_excel(test_path)
    print(f"  ✓ Loaded {len(test_df):,} test records")
    
    # ==================== BUILD EXERCISE VOCABULARY ====================
    print(f"\n[3/10] Building exercise vocabulary...")
    
    # Normalize exercise names
    train_df['exercise_name_norm'] = train_df['exercise_name'].apply(normalize_exercise_name)
    test_df['exercise_name_norm'] = test_df['exercise_name'].apply(normalize_exercise_name)
    
    # Get unique exercises (từ cả train và test để đảm bảo coverage)
    all_exercises = pd.concat([
        train_df['exercise_name_norm'],
        test_df['exercise_name_norm']
    ]).dropna().unique()
    
    exercise_list = sorted([ex for ex in all_exercises if ex])
    exercise_to_idx = {ex: idx for idx, ex in enumerate(exercise_list)}
    idx_to_exercise = {idx: ex for ex, idx in exercise_to_idx.items()}
    
    print(f"  ✓ Found {len(exercise_list)} unique exercises")
    print(f"  Top 10 exercises: {exercise_list[:10]}")
    
    # ==================== CREATE LABELS ====================
    print(f"\n[4/10] Creating labels...")
    
    # Multi-label for suitability (binary matrix)
    def create_exercise_labels(df, exercise_to_idx):
        num_exercises = len(exercise_to_idx)
        labels = np.zeros((len(df), num_exercises), dtype='float32')
        exercise_indices = np.zeros(len(df), dtype='int64')
        
        for i, ex_name in enumerate(df['exercise_name_norm']):
            if ex_name in exercise_to_idx:
                idx = exercise_to_idx[ex_name]
                labels[i, idx] = 1.0
                exercise_indices[i] = idx
        
        return labels, exercise_indices
    
    train_labels, train_ex_idx = create_exercise_labels(train_df, exercise_to_idx)
    test_labels, test_ex_idx = create_exercise_labels(test_df, exercise_to_idx)
    
    print(f"  ✓ Created labels for train and test")
    
    # ==================== PARSE INTENSITY PARAMETERS ====================
    print(f"\n[5/10] Parsing intensity parameters...")
    
    def parse_intensity_params(df):
        """
        Parse 8 intensity parameters:
        0: sets, 1: reps, 2: kg, 3: km, 4: min, 5: minRest, 6: avgHR, 7: peakHR
        """
        intensity_raw = np.zeros((len(df), 8), dtype='float32')
        
        # Parse sets/reps/weight/timeresteachset
        if 'sets/reps/weight/timeresteachset' in df.columns:
            parsed = df['sets/reps/weight/timeresteachset'].apply(parse_sets_reps_weight)
            for i, (sets, reps, weight, rest) in enumerate(parsed):
                intensity_raw[i, 0] = sets if not np.isnan(sets) else 0
                intensity_raw[i, 1] = reps if not np.isnan(reps) else 0
                intensity_raw[i, 2] = weight if not np.isnan(weight) else 0
                intensity_raw[i, 5] = rest if not np.isnan(rest) else 0
        
        # Distance (km)
        if 'distance_km' in df.columns:
            intensity_raw[:, 3] = pd.to_numeric(df['distance_km'], errors='coerce').fillna(0).values
        
        # Duration (min)
        if 'duration_min' in df.columns:
            intensity_raw[:, 4] = pd.to_numeric(df['duration_min'], errors='coerce').fillna(0).values
        
        # Heart rate
        if 'avg_hr' in df.columns:
            intensity_raw[:, 6] = pd.to_numeric(df['avg_hr'], errors='coerce').fillna(0).values
        if 'max_hr' in df.columns:
            intensity_raw[:, 7] = pd.to_numeric(df['max_hr'], errors='coerce').fillna(0).values
        
        return intensity_raw
    
    train_intensity_raw = parse_intensity_params(train_df)
    test_intensity_raw = parse_intensity_params(test_df)
    
    # Scale intensity parameters to [0, 1]
    intensity_scales = {
        'sets': (1.0, 5.0),
        'reps': (5.0, 20.0),
        'kg': (0.0, load_cap_kg),
        'km': (0.0, 20.0),
        'min': (0.0, 120.0),
        'minRest': (0.0, 5.0),
        'avgHR': (60.0, 180.0),
        'peakHR': (100.0, 200.0)
    }
    
    scale_keys = ['sets', 'reps', 'kg', 'km', 'min', 'minRest', 'avgHR', 'peakHR']
    
    def scale_intensity(intensity_raw, scales):
        intensity_scaled = np.zeros_like(intensity_raw, dtype='float32')
        intensity_mask = np.zeros_like(intensity_raw, dtype='float32')
        
        for idx, key in enumerate(scale_keys):
            lo, hi = scales[key]
            col = intensity_raw[:, idx]
            
            # Mask for valid values (non-zero)
            valid_mask = col > 0
            intensity_mask[:, idx] = valid_mask.astype('float32')
            
            # Clip and scale
            col_clipped = np.clip(col, lo, hi)
            col_scaled = (col_clipped - lo) / max(1e-6, (hi - lo))
            intensity_scaled[:, idx] = col_scaled
        
        return intensity_scaled, intensity_mask
    
    train_intensity, train_intensity_mask = scale_intensity(train_intensity_raw, intensity_scales)
    test_intensity, test_intensity_mask = scale_intensity(test_intensity_raw, intensity_scales)
    
    print(f"  ✓ Parsed and scaled intensity parameters")
    
    # ==================== PREPARE FEATURES ====================
    print(f"\n[6/10] Preparing features...")
    
    feature_candidates = [
        'age', 'height_m', 'height_cm', 'weight_kg', 'bmi', 'bmr', 
        'bodyFatPct', 'fat_percentage', 'resting_hr', 'resting_heartrate',
        'workout_frequency_per_week', 'workout_frequency',
        'gender', 'experience_level', 'activity_level'
    ]
    
    # Combine train and test for preprocessing
    combined_df = pd.concat([train_df, test_df], ignore_index=True)
    
    # Select available features
    features_used = []
    for feat in feature_candidates:
        if feat in combined_df.columns:
            if feat not in features_used:  # Avoid duplicates
                features_used.append(feat)
    
    print(f"  ✓ Using {len(features_used)} features: {features_used}")
    
    X_combined = combined_df[features_used].copy()
    
    # Explicitly define categorical columns
    categorical_feature_names = ['gender', 'experience_level', 'activity_level']
    categorical_cols = [c for c in categorical_feature_names if c in X_combined.columns]
    numeric_cols = [c for c in X_combined.columns if c not in categorical_cols]
    
    # Convert categorical columns to strings to avoid mixed type errors
    for col in categorical_cols:
        X_combined[col] = X_combined[col].astype(str)
    
    print(f"  - Numeric: {len(numeric_cols)} columns")
    print(f"  - Categorical: {len(categorical_cols)} columns")
    
    # Create preprocessor
    preprocessor = ColumnTransformer([
        ('num', Pipeline([
            ('imputer', SimpleImputer(strategy='median')),
            ('scaler', StandardScaler())
        ]), numeric_cols),
        ('cat', Pipeline([
            ('imputer', SimpleImputer(strategy='most_frequent')),
            ('onehot', OneHotEncoder(handle_unknown='ignore'))
        ]), categorical_cols)
    ], remainder='drop')
    
    # Fit and transform
    X_combined_transformed = preprocessor.fit_transform(X_combined)
    X_combined_array = X_combined_transformed.toarray() if hasattr(X_combined_transformed, 'toarray') else np.asarray(X_combined_transformed)
    
    # Split back to train and test
    X_train = X_combined_array[:len(train_df)]
    X_test = X_combined_array[len(train_df):]
    
    print(f"  ✓ Preprocessed features: {X_train.shape[1]} dimensions")
    
    # ==================== CREATE VALIDATION SPLIT ====================
    print(f"\n[7/10] Creating validation split...")
    
    # Split train into train/val
    indices = np.arange(len(X_train))
    train_idx, val_idx = train_test_split(indices, test_size=0.2, random_state=42)
    
    X_tr, X_val = X_train[train_idx], X_train[val_idx]
    y_suit_tr, y_suit_val = train_labels[train_idx], train_labels[val_idx]
    y_int_tr, y_int_val = train_intensity[train_idx], train_intensity[val_idx]
    int_mask_tr, int_mask_val = train_intensity_mask[train_idx], train_intensity_mask[val_idx]
    ex_idx_tr, ex_idx_val = train_ex_idx[train_idx], train_ex_idx[val_idx]
    
    print(f"  ✓ Train: {len(X_tr):,} samples")
    print(f"  ✓ Val: {len(X_val):,} samples")
    print(f"  ✓ Test: {len(X_test):,} samples")
    
    # ==================== CREATE DATALOADERS ====================
    print(f"\n[8/10] Creating dataloaders...")
    
    train_dataset = ExerciseDataset(X_tr, y_suit_tr, y_int_tr, int_mask_tr, ex_idx_tr)
    val_dataset = ExerciseDataset(X_val, y_suit_val, y_int_val, int_mask_val, ex_idx_val)
    test_dataset = ExerciseDataset(X_test, test_labels, test_intensity, test_intensity_mask, test_ex_idx)
    
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)
    test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False)
    
    print(f"  ✓ Created dataloaders (batch_size={batch_size})")
    
    # ==================== INITIALIZE MODEL ====================
    print(f"\n[9/10] Initializing model...")
    
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"  Using device: {device}")
    
    model = ExerciseRecommendationModel(
        input_dim=X_train.shape[1],
        num_exercises=len(exercise_list),
        embed_dim=128,
        hidden_dim=256,
        dropout=0.15
    ).to(device)
    
    optimizer = torch.optim.AdamW(model.parameters(), lr=lr, weight_decay=1e-4)
    
    # Loss functions
    # Classification: BCEWithLogitsLoss with pos_weight
    pos_counts = y_suit_tr.sum(axis=0) + 1e-6
    neg_counts = (len(y_suit_tr) - y_suit_tr.sum(axis=0)) + 1e-6
    pos_weight = torch.tensor(neg_counts / pos_counts, dtype=torch.float32, device=device)
    
    classification_loss_fn = nn.BCEWithLogitsLoss(pos_weight=pos_weight)
    
    # Regression: Masked SmoothL1Loss
    def masked_regression_loss(pred, target, mask, gt_indices):
        """
        Chỉ tính loss cho exercise được chọn (ground truth)
        """
        batch_size = pred.size(0)
        
        # Gather predictions for ground truth exercises
        gt_indices_expanded = gt_indices.view(batch_size, 1, 1).expand(batch_size, 1, 8)
        pred_gt = pred.gather(1, gt_indices_expanded).squeeze(1)  # [B, 8]
        
        # Compute loss only on valid (masked) values
        diff = F.smooth_l1_loss(pred_gt, target, reduction='none')
        masked_diff = diff * mask
        
        return masked_diff.sum() / (mask.sum() + 1e-8)
    
    print(f"  ✓ Model initialized with {sum(p.numel() for p in model.parameters()):,} parameters")
    
    # ==================== TRAINING LOOP ====================
    print(f"\n[10/10] Starting training...")
    print("=" * 80)
    
    best_val_precision = -1.0
    best_model_path = os.path.join(artifacts_dir, 'best_model.pt')
    
    for epoch in range(1, epochs + 1):
        # Training
        model.train()
        train_loss = 0.0
        
        for batch in train_loader:
            x, y_suit, y_int, int_mask, ex_idx = [b.to(device) for b in batch]
            
            optimizer.zero_grad()
            
            # Forward pass
            suit_logits, int_pred = model(x)
            
            # Compute losses
            cls_loss = classification_loss_fn(suit_logits, y_suit)
            reg_loss = masked_regression_loss(int_pred, y_int, int_mask, ex_idx)
            
            # Combined loss
            loss = 1.0 * cls_loss + 0.25 * reg_loss
            
            # Backward pass
            loss.backward()
            optimizer.step()
            
            train_loss += loss.item()
        
        train_loss /= len(train_loader)
        
        # Validation
        model.eval()
        val_loss = 0.0
        val_precisions, val_recalls = [], []
        
        with torch.no_grad():
            for batch in val_loader:
                x, y_suit, y_int, int_mask, ex_idx = [b.to(device) for b in batch]
                
                suit_logits, int_pred = model(x)
                
                cls_loss = classification_loss_fn(suit_logits, y_suit)
                reg_loss = masked_regression_loss(int_pred, y_int, int_mask, ex_idx)
                loss = 1.0 * cls_loss + 0.25 * reg_loss
                
                val_loss += loss.item()
                
                # Metrics
                p, r = precision_recall_at_k(suit_logits, y_suit, K=5)
                val_precisions.append(p)
                val_recalls.append(r)
        
        val_loss /= len(val_loader)
        val_precision = np.mean(val_precisions)
        val_recall = np.mean(val_recalls)
        
        # Print progress
        print(f"Epoch {epoch:3d}/{epochs} | "
              f"Train Loss: {train_loss:.4f} | "
              f"Val Loss: {val_loss:.4f} | "
              f"P@5: {val_precision:.3f} | "
              f"R@5: {val_recall:.3f}")
        
        # Save best model
        if val_precision > best_val_precision:
            best_val_precision = val_precision
            torch.save({
                'epoch': epoch,
                'model_state_dict': model.state_dict(),
                'optimizer_state_dict': optimizer.state_dict(),
                'val_precision': val_precision,
                'val_recall': val_recall,
                'input_dim': X_train.shape[1],
                'num_exercises': len(exercise_list),
                'exercise_list': exercise_list,
                'exercise_to_idx': exercise_to_idx
            }, best_model_path)
            
            print(f"  → Saved best model (P@5: {val_precision:.3f})")
    
    # ==================== SAVE ARTIFACTS ====================
    print("\n" + "=" * 80)
    print("Saving artifacts...")
    
    # Save preprocessor
    preprocessor_path = os.path.join(artifacts_dir, 'preprocessor.joblib')
    joblib.dump(preprocessor, preprocessor_path)
    print(f"  ✓ Saved preprocessor: {preprocessor_path}")
    
    # Save metadata
    metadata = {
        'timestamp': datetime.now().isoformat(),
        'train_path': train_path,
        'test_path': test_path,
        'num_exercises': len(exercise_list),
        'exercise_list': exercise_list,
        'exercise_to_idx': exercise_to_idx,
        'idx_to_exercise': idx_to_exercise,
        'features_used': features_used,
        'intensity_scales': {k: list(v) for k, v in intensity_scales.items()},
        'intensity_params': scale_keys,
        'model_config': {
            'input_dim': int(X_train.shape[1]),
            'num_exercises': len(exercise_list),
            'embed_dim': 128,
            'hidden_dim': 256,
            'dropout': 0.15
        },
        'training_config': {
            'epochs': epochs,
            'batch_size': batch_size,
            'learning_rate': lr,
            'load_cap_kg': load_cap_kg
        },
        'best_val_precision': float(best_val_precision)
    }
    
    metadata_path = os.path.join(artifacts_dir, 'metadata.json')
    with open(metadata_path, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, ensure_ascii=False, indent=2)
    print(f"  ✓ Saved metadata: {metadata_path}")
    
    print("\n" + "=" * 80)
    print("✅ TRAINING COMPLETED!")
    print("=" * 80)
    print(f"Best validation P@5: {best_val_precision:.3f}")
    print(f"Artifacts saved to: {artifacts_dir}")
    print("=" * 80)

# ==================== ENTRY POINT ====================

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Train Exercise Recommendation Model')
    parser.add_argument('--train', type=str, 
                       default='../../../Data/data/mapped_workout_dataset_20251120_012453.xlsx',
                       help='Path to training data')
    parser.add_argument('--test', type=str,
                       default='../../../Data/data/merged_omni_health_dataset.xlsx',
                       help='Path to test data')
    parser.add_argument('--artifacts', type=str,
                       default='../artifacts_exercise_rec',
                       help='Directory to save artifacts')
    parser.add_argument('--epochs', type=int, default=100,
                       help='Number of training epochs')
    parser.add_argument('--batch-size', type=int, default=64,
                       help='Batch size')
    parser.add_argument('--lr', type=float, default=1e-3,
                       help='Learning rate')
    parser.add_argument('--load-cap-kg', type=float, default=200.0,
                       help='Maximum weight capacity (kg)')
    
    args = parser.parse_args()
    
    main(
        train_path=args.train,
        test_path=args.test,
        artifacts_dir=args.artifacts,
        epochs=args.epochs,
        batch_size=args.batch_size,
        lr=args.lr,
        load_cap_kg=args.load_cap_kg
    )

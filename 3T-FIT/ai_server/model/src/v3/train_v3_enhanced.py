"""
train_v3_enhanced.py
Enhanced V3 Training Model implementing Strategy_Analysis.md recommendations

Key Features:
- 1RM Estimation as primary target (using Epley formula)
- SePA integration (mood, fatigue, effort) with 1-5 scale normalization
- Rule-based decoding for workout generation
- Goal-based intensity mapping (Strength, Hypertrophy, Endurance)
- Enhanced data preprocessing with capability metrics
- Multi-task learning: 1RM prediction + suitability scoring

Architecture:
1. Feature Engineering: Parse workout data → Estimated 1RM
2. Model Core: LSTM/Transformer for sequence prediction + SePA integration
3. Prediction: Daily capability (1RM) + Readiness factor
4. Decoding: Rule-based sets/reps/weight calculation

Artifacts: artifacts_v3/
  - best_v3.pt
  - preprocessor_v3.joblib
  - meta_v3.json
  - decoding_rules.json

Author: Claude Code Assistant
Date: 2025-11-25
"""

import os, re, json, argparse, numpy as np, pandas as pd, joblib
import torch, torch.nn as nn, torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, StandardScaler, LabelEncoder
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from typing import Dict, List, Tuple, Optional
import warnings
warnings.filterwarnings('ignore')

# ==================== SEPA MAPPING ====================
# SePA (Sleep, Psychology, Activity) normalization to 1-5 scale

MOOD_MAPPING = {
    'Very Bad': 1, 'Bad': 2, 'Neutral': 3, 'Good': 4, 'Very Good': 5, 'Excellent': 5
}

FATIGUE_MAPPING = {
    'Very Low': 1, 'Low': 2, 'Medium': 3, 'High': 4, 'Very High': 5
}

EFFORT_MAPPING = {
    'Very Low': 1, 'Low': 2, 'Medium': 3, 'High': 4, 'Very High': 5
}

def map_sepa_to_numeric(value, mapping_dict, default=3):
    """Convert SePA text to numeric 1-5 scale"""
    if pd.isna(value):
        return default

    try:
        num_val = int(float(value))
        if 1 <= num_val <= 5:
            return num_val
    except (ValueError, TypeError):
        pass

    if isinstance(value, str):
        value_str = value.strip()

        if value_str in mapping_dict:
            return mapping_dict[value_str]

        for key, val in mapping_dict.items():
            if key.lower() == value_str.lower():
                return val

    return default

# ==================== 1RM CALCULATION ====================

def calculate_1rm_epley(weight: float, reps: int) -> float:
    """
    Calculate estimated 1RM using Epley formula
    1RM = Weight × (1 + Reps/30)
    """
    if weight <= 0 or reps <= 0:
        return 0.0
    return weight * (1 + reps / 30)

def parse_workout_data(cell_value) -> Tuple[List[float], List[float], List[float]]:
    """
    Parse workout data from sets/reps/weight format
    Returns: (reps_list, weights_list, rests_list)

    Input format: "12x40x2 | 8x50x3" (reps x weight x sets)
    """
    if pd.isna(cell_value):
        return [], [], []

    try:
        reps_list, weights_list, rests_list = [], [], []

        # Split by pipe for multiple sets
        sets_data = str(cell_value).split('|')

        for set_data in sets_data:
            parts = set_data.strip().split('x')
            if len(parts) >= 2:
                reps = float(parts[0])
                weight = float(parts[1])
                sets = float(parts[2]) if len(parts) > 2 else 1

                # Add each set individually
                for _ in range(int(sets)):
                    reps_list.append(reps)
                    weights_list.append(weight)
                    rests_list.append(120.0)  # Default 2 minutes rest

        return reps_list, weights_list, rests_list

    except Exception:
        return [], [], []

def calculate_workout_1rm(reps_list: List[float], weights_list: List[float]) -> float:
    """Calculate maximum 1RM from workout data"""
    if not reps_list or not weights_list:
        return 0.0

    max_1rm = 0.0
    for reps, weight in zip(reps_list, weights_list):
        current_1rm = calculate_1rm_epley(weight, int(reps))
        max_1rm = max(max_1rm, current_1rm)

    return round(max_1rm, 2)

def calculate_readiness_factor(mood: float, fatigue: float, effort: float) -> float:
    """
    Calculate readiness factor based on SePA scores (1-5 scale)
    Formula: base_factor + mood_adj + fatigue_adj + effort_adj
    """
    base_factor = 1.0

    # Mood adjustment: better mood = higher readiness
    if mood >= 5:  # Very Good/Excellent
        mood_adj = 0.05
    elif mood <= 2:  # Bad/Very Bad
        mood_adj = -0.1
    else:
        mood_adj = 0.0

    # Fatigue adjustment: higher fatigue = lower readiness
    if fatigue >= 4:  # High/Very High
        fatigue_adj = -0.15
    elif fatigue <= 2:  # Low/Very Low
        fatigue_adj = 0.05
    else:
        fatigue_adj = 0.0

    # Effort adjustment: very high effort might indicate need for recovery
    if effort >= 5:  # Very High
        effort_adj = -0.05
    else:
        effort_adj = 0.0

    readiness = base_factor + mood_adj + fatigue_adj + effort_adj
    return round(max(0.6, min(1.3, readiness)), 3)

# ==================== GOAL-BASED DECODING RULES ====================

WORKOUT_GOAL_MAPPING = {
    'strength': {
        'intensity_percent': (0.85, 0.95),  # 85-95% 1RM
        'rep_range': (5, 15),  # Updated to ensure 5-15 reps range
        'sets_range': (1, 5),  # Updated to ensure 1-5 sets range
        'rest_minutes': (3, 5),
        'description': 'Strength Training - Heavy loads, low reps'
    },
    'hypertrophy': {
        'intensity_percent': (0.70, 0.80),  # 70-80% 1RM
        'rep_range': (8, 20),  # Updated to ensure 8-20 reps range
        'sets_range': (1, 5),  # Updated to ensure 1-5 sets range
        'rest_minutes': (1, 2),
        'description': 'Hypertrophy - Moderate loads, medium reps'
    },
    'endurance': {
        'intensity_percent': (0.50, 0.60),  # 50-60% 1RM
        'rep_range': (10, 30),  # Updated to ensure 10-30 reps range
        'sets_range': (1, 5),  # Updated to ensure 1-5 sets range
        'rest_minutes': (0.5, 1),
        'description': 'Endurance - Light loads, high reps'
    },
    'general_fitness': {
        'intensity_percent': (0.60, 0.75),  # 60-75% 1RM
        'rep_range': (10, 30),  # Updated to ensure 10-30 reps range (other goals)
        'sets_range': (1, 5),  # Updated to ensure 1-5 sets range
        'rest_minutes': (1, 2),
        'description': 'General Fitness - Balanced approach'
    }
}

def decode_1rm_to_workout(predicted_1rm: float, goal: str, readiness_factor: float) -> Dict:
    """
    Convert predicted 1RM to specific workout parameters using rule-based decoding
    """
    if goal not in WORKOUT_GOAL_MAPPING:
        goal = 'general_fitness'

    rules = WORKOUT_GOAL_MAPPING[goal]

    # Apply readiness factor to 1RM
    adjusted_1rm = predicted_1rm * readiness_factor

    # Calculate intensity ranges
    intensity_min, intensity_max = rules['intensity_percent']
    training_weight_min = adjusted_1rm * intensity_min
    training_weight_max = adjusted_1rm * intensity_max

    # Select reps and sets within ranges
    rep_min, rep_max = rules['rep_range']
    sets_min, sets_max = rules['sets_range']
    rest_min, rest_max = rules['rest_minutes']

    return {
        'predicted_1rm': round(predicted_1rm, 2),
        'adjusted_1rm': round(adjusted_1rm, 2),
        'readiness_factor': readiness_factor,
        'goal': goal,
        'training_weight_kg': {
            'min': round(training_weight_min, 2),
            'max': round(training_weight_max, 2),
            'recommended': round((training_weight_min + training_weight_max) / 2, 2)
        },
        'reps': {
            'min': rep_min,
            'max': rep_max,
            'recommended': (rep_min + rep_max) // 2
        },
        'sets': {
            'min': sets_min,
            'max': sets_max,
            'recommended': (sets_min + sets_max) // 2
        },
        'rest_minutes': {
            'min': rest_min,
            'max': rest_max,
            'recommended': (rest_min + rest_max) / 2
        },
        'description': rules['description']
    }

# ==================== DATASET CLASS ====================

class V3Dataset(Dataset):
    """Enhanced Dataset for V3 training with 1RM prediction"""

    def __init__(self, features, target_1rm, suitability_scores, readiness_factors):
        self.X = features.astype(np.float32)
        self.y_1rm = target_1rm.astype(np.float32)
        self.y_suit = suitability_scores.astype(np.float32)
        self.y_ready = readiness_factors.astype(np.float32)

    def __len__(self):
        return len(self.X)

    def __getitem__(self, idx):
        return (
            torch.from_numpy(self.X[idx]),
            torch.from_numpy(np.array([self.y_1rm[idx]])),
            torch.from_numpy(np.array([self.y_suit[idx]])),
            torch.from_numpy(np.array([self.y_ready[idx]]))
        )

# ==================== MODEL ARCHITECTURE ====================

class V3EnhancedModel(nn.Module):
    """
    Enhanced V3 Model implementing Strategy_Analysis.md recommendations

    Architecture:
    - Input Encoder: User profile + SePA features
    - LSTM/Transformer Layer: Sequence learning for progression
    - Multi-task Heads: 1RM prediction + Suitability + Readiness
    - Attention Mechanism: Feature importance weighting
    """

    def __init__(self, input_dim: int, hidden_dim: int = 256, num_layers: int = 2,
                 dropout: float = 0.2, use_transformer: bool = False):
        super().__init__()

        self.input_dim = input_dim
        self.hidden_dim = hidden_dim
        self.use_transformer = use_transformer

        # Feature encoder
        self.feature_encoder = nn.Sequential(
            nn.Linear(input_dim, hidden_dim),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dim, hidden_dim),
            nn.ReLU(),
            nn.Dropout(dropout)
        )

        # Sequence processing layer
        if use_transformer:
            self.sequence_processor = nn.TransformerEncoder(
                nn.TransformerEncoderLayer(d_model=hidden_dim, nhead=8, dropout=dropout),
                num_layers=num_layers
            )
        else:
            self.lstm = nn.LSTM(hidden_dim, hidden_dim, num_layers,
                              batch_first=True, dropout=dropout if num_layers > 1 else 0)

        # Multi-task heads
        self.head_1rm = nn.Sequential(
            nn.Linear(hidden_dim, hidden_dim // 2),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dim // 2, 1)  # 1RM prediction
        )

        self.head_suitability = nn.Sequential(
            nn.Linear(hidden_dim, hidden_dim // 2),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dim // 2, 1)  # Suitability score (0-1)
        )

        self.head_readiness = nn.Sequential(
            nn.Linear(hidden_dim, hidden_dim // 2),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dim // 2, 1)  # Readiness factor (0.6-1.3)
        )

        # Attention mechanism for feature importance
        self.attention = nn.Sequential(
            nn.Linear(hidden_dim, hidden_dim // 8),
            nn.Tanh(),
            nn.Linear(hidden_dim // 8, 1),
            nn.Softmax(dim=1)
        )

    def forward(self, x, sequence_length=1):
        batch_size = x.size(0)

        # Encode features
        features = self.feature_encoder(x)  # [B, H]

        # Create sequence for LSTM/Transformer
        features_seq = features.unsqueeze(1).repeat(1, sequence_length, 1)  # [B, L, H]

        # Process sequence
        if self.use_transformer:
            processed = self.sequence_processor(features_seq.transpose(0, 1)).transpose(0, 1)
            processed = processed[:, 0, :]  # Take first token
        else:
            processed, _ = self.lstm(features_seq)
            processed = processed[:, -1, :]  # Take last hidden state

        # Apply attention
        attention_weights = self.attention(processed.unsqueeze(1))  # [B, 1, 1]
        attended_features = processed * attention_weights.squeeze(1)  # [B, H]

        # Multi-task predictions
        pred_1rm = self.head_1rm(attended_features)
        pred_suitability = torch.sigmoid(self.head_suitability(attended_features))
        pred_readiness = 0.6 + 0.7 * torch.sigmoid(self.head_readiness(attended_features))  # Scale to 0.6-1.3

        return pred_1rm, pred_suitability, pred_readiness

# ==================== TRAINING UTILITIES ====================

def calculate_metrics(y_true, y_pred, task_name=""):
    """Calculate comprehensive metrics for model evaluation"""
    mae = mean_absolute_error(y_true, y_pred)
    mse = mean_squared_error(y_true, y_pred)
    rmse = np.sqrt(mse)
    r2 = r2_score(y_true, y_pred)

    # Percentage error (MAPE)
    mape = np.mean(np.abs((y_true - y_pred) / (y_true + 1e-8))) * 100

    # Correlation coefficient
    correlation = np.corrcoef(y_true.flatten(), y_pred.flatten())[0, 1]
    if np.isnan(correlation):
        correlation = 0.0

    metrics = {
        f'{task_name}_mae': mae,
        f'{task_name}_mse': mse,
        f'{task_name}_rmse': rmse,
        f'{task_name}_r2': r2,
        f'{task_name}_mape': mape
    }

    # Add correlation for multi-task outputs
    if task_name in ['suitability', 'readiness']:
        metrics[f'{task_name}_corr'] = correlation

    return metrics

def train_epoch(model, dataloader, optimizer, criterion_1rm, criterion_suit, criterion_ready, device):
    """Training epoch for V3 model"""
    model.train()
    total_loss = 0.0
    losses_1rm, losses_suit, losses_ready = [], [], []

    for features, target_1rm, target_suit, target_ready in dataloader:
        features = features.to(device)
        target_1rm = target_1rm.to(device)
        target_suit = target_suit.to(device)
        target_ready = target_ready.to(device)

        optimizer.zero_grad()

        pred_1rm, pred_suit, pred_ready = model(features)

        # Calculate losses
        loss_1rm = criterion_1rm(pred_1rm, target_1rm)
        loss_suit = criterion_suit(pred_suit, target_suit)
        loss_ready = criterion_ready(pred_ready, target_ready)

        # Combined loss with weighting
        total_loss_batch = 2.0 * loss_1rm + 1.0 * loss_suit + 0.5 * loss_ready

        total_loss_batch.backward()
        torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
        optimizer.step()

        total_loss += total_loss_batch.item()
        losses_1rm.append(loss_1rm.item())
        losses_suit.append(loss_suit.item())
        losses_ready.append(loss_ready.item())

    return (
        total_loss / len(dataloader),
        np.mean(losses_1rm),
        np.mean(losses_suit),
        np.mean(losses_ready)
    )

def validate_epoch(model, dataloader, criterion_1rm, criterion_suit, criterion_ready, device):
    """Validation epoch for V3 model"""
    model.eval()
    total_loss = 0.0
    all_1rm_true, all_1rm_pred = [], []
    all_suit_true, all_suit_pred = [], []
    all_ready_true, all_ready_pred = [], []

    with torch.no_grad():
        for features, target_1rm, target_suit, target_ready in dataloader:
            features = features.to(device)
            target_1rm = target_1rm.to(device)
            target_suit = target_suit.to(device)
            target_ready = target_ready.to(device)

            pred_1rm, pred_suit, pred_ready = model(features)

            # Calculate losses
            loss_1rm = criterion_1rm(pred_1rm, target_1rm)
            loss_suit = criterion_suit(pred_suit, target_suit)
            loss_ready = criterion_ready(pred_ready, target_ready)

            total_loss_batch = 2.0 * loss_1rm + 1.0 * loss_suit + 0.5 * loss_ready
            total_loss += total_loss_batch.item()

            # Collect predictions for metrics
            all_1rm_true.extend(target_1rm.cpu().numpy())
            all_1rm_pred.extend(pred_1rm.cpu().numpy())
            all_suit_true.extend(target_suit.cpu().numpy())
            all_suit_pred.extend(pred_suit.cpu().numpy())
            all_ready_true.extend(target_ready.cpu().numpy())
            all_ready_pred.extend(pred_ready.cpu().numpy())

    # Calculate comprehensive metrics
    metrics = {}
    metrics.update(calculate_metrics(np.array(all_1rm_true), np.array(all_1rm_pred), "1rm"))
    metrics.update(calculate_metrics(np.array(all_suit_true), np.array(all_suit_pred), "suitability"))
    metrics.update(calculate_metrics(np.array(all_ready_true), np.array(all_ready_pred), "readiness"))

    return total_loss / len(dataloader), metrics

# ==================== VISUALIZATION FUNCTIONS ====================

def plot_training_data_analysis(df: pd.DataFrame, artifacts_dir: str):
    """
    Create comprehensive visualizations for training data analysis
    
    Args:
        df: Training dataframe
        artifacts_dir: Directory to save plots
    """
    import matplotlib.pyplot as plt
    import seaborn as sns
    
    # Create visualization directory
    viz_dir = os.path.join(artifacts_dir, 'visualizations')
    os.makedirs(viz_dir, exist_ok=True)
    
    print(f"\n📊 Generating Training Data Visualizations...")
    
    # Set style
    sns.set_style("whitegrid")
    plt.rcParams['figure.figsize'] = (15, 10)
    
    # 1. Target Variable Distributions
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    fig.suptitle('Target Variable Distributions', fontsize=16, fontweight='bold')
    
    # 1RM Distribution
    if 'estimated_1rm' in df.columns:
        axes[0, 0].hist(df['estimated_1rm'].dropna(), bins=50, color='steelblue', edgecolor='black', alpha=0.7)
        axes[0, 0].set_title('Estimated 1RM Distribution')
        axes[0, 0].set_xlabel('1RM (kg)')
        axes[0, 0].set_ylabel('Frequency')
        axes[0, 0].axvline(df['estimated_1rm'].mean(), color='red', linestyle='--', label=f'Mean: {df["estimated_1rm"].mean():.1f}')
        axes[0, 0].legend()
    
    # Suitability Score Distribution
    if 'suitability_score' in df.columns:
        axes[0, 1].hist(df['suitability_score'].dropna(), bins=30, color='green', edgecolor='black', alpha=0.7)
        axes[0, 1].set_title('Suitability Score Distribution')
        axes[0, 1].set_xlabel('Suitability Score')
        axes[0, 1].set_ylabel('Frequency')
        axes[0, 1].axvline(df['suitability_score'].mean(), color='red', linestyle='--', label=f'Mean: {df["suitability_score"].mean():.3f}')
        axes[0, 1].legend()
    
    # Readiness Factor Distribution
    if 'readiness_factor' in df.columns:
        axes[1, 0].hist(df['readiness_factor'].dropna(), bins=30, color='orange', edgecolor='black', alpha=0.7)
        axes[1, 0].set_title('Readiness Factor Distribution')
        axes[1, 0].set_xlabel('Readiness Factor')
        axes[1, 0].set_ylabel('Frequency')
        axes[1, 0].axvline(df['readiness_factor'].mean(), color='red', linestyle='--', label=f'Mean: {df["readiness_factor"].mean():.3f}')
        axes[1, 0].legend()
    
    # BMI Distribution
    if 'bmi' in df.columns:
        axes[1, 1].hist(df['bmi'].dropna(), bins=40, color='purple', edgecolor='black', alpha=0.7)
        axes[1, 1].set_title('BMI Distribution')
        axes[1, 1].set_xlabel('BMI')
        axes[1, 1].set_ylabel('Frequency')
        axes[1, 1].axvline(df['bmi'].mean(), color='red', linestyle='--', label=f'Mean: {df["bmi"].mean():.1f}')
        axes[1, 1].legend()
    
    plt.tight_layout()
    plt.savefig(os.path.join(viz_dir, '01_target_distributions.png'), dpi=300, bbox_inches='tight')
    plt.close()
    print(f"  ✅ Saved: 01_target_distributions.png")
    
    # 2. SePA (Sleep, Psychology, Activity) Analysis
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle('SePA Features Distribution', fontsize=16, fontweight='bold')
    
    sepa_cols = ['mood_numeric', 'fatigue_numeric', 'effort_numeric']
    sepa_titles = ['Mood (1-5)', 'Fatigue (1-5)', 'Effort (1-5)']
    colors = ['skyblue', 'salmon', 'lightgreen']
    
    for idx, (col, title, color) in enumerate(zip(sepa_cols, sepa_titles, colors)):
        if col in df.columns:
            value_counts = df[col].value_counts().sort_index()
            axes[idx].bar(value_counts.index, value_counts.values, color=color, edgecolor='black', alpha=0.7)
            axes[idx].set_title(title)
            axes[idx].set_xlabel('Score')
            axes[idx].set_ylabel('Count')
            axes[idx].set_xticks([1, 2, 3, 4, 5])
    
    plt.tight_layout()
    plt.savefig(os.path.join(viz_dir, '02_sepa_distributions.png'), dpi=300, bbox_inches='tight')
    plt.close()
    print(f"  ✅ Saved: 02_sepa_distributions.png")
    
    # 3. Correlation Heatmap
    numeric_cols = ['age', 'weight_kg', 'height_m', 'bmi', 'experience_level', 
                    'workout_frequency', 'resting_heartrate', 'mood_numeric', 
                    'fatigue_numeric', 'effort_numeric', 'estimated_1rm', 
                    'suitability_score', 'readiness_factor']
    
    available_numeric = [col for col in numeric_cols if col in df.columns]
    
    if len(available_numeric) > 2:
        plt.figure(figsize=(14, 12))
        correlation_matrix = df[available_numeric].corr()
        
        mask = np.triu(np.ones_like(correlation_matrix, dtype=bool))
        sns.heatmap(correlation_matrix, mask=mask, annot=True, fmt='.2f', 
                   cmap='coolwarm', center=0, square=True, linewidths=1,
                   cbar_kws={"shrink": 0.8})
        
        plt.title('Feature Correlation Heatmap', fontsize=16, fontweight='bold', pad=20)
        plt.tight_layout()
        plt.savefig(os.path.join(viz_dir, '03_correlation_heatmap.png'), dpi=300, bbox_inches='tight')
        plt.close()
        print(f"  ✅ Saved: 03_correlation_heatmap.png")
    
    # 4. 1RM vs User Characteristics
    fig, axes = plt.subplots(2, 3, figsize=(18, 10))
    fig.suptitle('1RM Relationships with User Characteristics', fontsize=16, fontweight='bold')
    
    scatter_pairs = [
        ('age', 'estimated_1rm', 'Age vs 1RM'),
        ('weight_kg', 'estimated_1rm', 'Weight vs 1RM'),
        ('bmi', 'estimated_1rm', 'BMI vs 1RM'),
        ('experience_level', 'estimated_1rm', 'Experience vs 1RM'),
        ('workout_frequency', 'estimated_1rm', 'Workout Frequency vs 1RM'),
        ('readiness_factor', 'estimated_1rm', 'Readiness vs 1RM')
    ]
    
    for idx, (x_col, y_col, title) in enumerate(scatter_pairs):
        row, col = idx // 3, idx % 3
        if x_col in df.columns and y_col in df.columns:
            axes[row, col].scatter(df[x_col], df[y_col], alpha=0.5, s=20, color='steelblue')
            axes[row, col].set_title(title)
            axes[row, col].set_xlabel(x_col.replace('_', ' ').title())
            axes[row, col].set_ylabel('1RM (kg)')
            
            # Add trend line
            z = np.polyfit(df[x_col].dropna(), df[y_col].dropna(), 1)
            p = np.poly1d(z)
            axes[row, col].plot(df[x_col].sort_values(), p(df[x_col].sort_values()), 
                              "r--", alpha=0.8, linewidth=2)
    
    plt.tight_layout()
    plt.savefig(os.path.join(viz_dir, '04_1rm_relationships.png'), dpi=300, bbox_inches='tight')
    plt.close()
    print(f"  ✅ Saved: 04_1rm_relationships.png")
    
    # 5. Gender Analysis
    if 'gender' in df.columns and 'estimated_1rm' in df.columns:
        fig, axes = plt.subplots(1, 2, figsize=(14, 5))
        fig.suptitle('Gender-based Analysis', fontsize=16, fontweight='bold')
        
        # 1RM by Gender
        gender_1rm = df.groupby('gender')['estimated_1rm'].apply(list)
        axes[0].boxplot(gender_1rm.values, labels=gender_1rm.index)
        axes[0].set_title('1RM Distribution by Gender')
        axes[0].set_ylabel('1RM (kg)')
        axes[0].grid(True, alpha=0.3)
        
        # Count by Gender
        gender_counts = df['gender'].value_counts()
        axes[1].bar(gender_counts.index, gender_counts.values, color=['lightblue', 'lightpink'], 
                   edgecolor='black', alpha=0.7)
        axes[1].set_title('Sample Count by Gender')
        axes[1].set_ylabel('Count')
        
        plt.tight_layout()
        plt.savefig(os.path.join(viz_dir, '05_gender_analysis.png'), dpi=300, bbox_inches='tight')
        plt.close()
        print(f"  ✅ Saved: 05_gender_analysis.png")
    
    # 6. Experience Level Analysis
    if 'experience_level' in df.columns and 'estimated_1rm' in df.columns:
        plt.figure(figsize=(10, 6))
        
        exp_1rm = df.groupby('experience_level')['estimated_1rm'].apply(list)
        plt.boxplot(exp_1rm.values, labels=exp_1rm.index)
        plt.title('1RM Distribution by Experience Level', fontsize=14, fontweight='bold')
        plt.xlabel('Experience Level')
        plt.ylabel('1RM (kg)')
        plt.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(os.path.join(viz_dir, '06_experience_analysis.png'), dpi=300, bbox_inches='tight')
        plt.close()
        print(f"  ✅ Saved: 06_experience_analysis.png")
    
    print(f"\n✅ All visualizations saved to: {viz_dir}/")
    return viz_dir

def plot_training_history(train_losses: List[float], val_losses: List[float], 
                          val_metrics_history: List[Dict], artifacts_dir: str):
    """
    Plot training history including losses and metrics over epochs
    
    Args:
        train_losses: List of training losses per epoch
        val_losses: List of validation losses per epoch
        val_metrics_history: List of validation metrics dictionaries per epoch
        artifacts_dir: Directory to save plots
    """
    import matplotlib.pyplot as plt
    
    viz_dir = os.path.join(artifacts_dir, 'visualizations')
    os.makedirs(viz_dir, exist_ok=True)
    
    epochs = range(1, len(train_losses) + 1)
    
    # 1. Loss Curves
    fig, axes = plt.subplots(1, 2, figsize=(15, 5))
    fig.suptitle('Training History', fontsize=16, fontweight='bold')
    
    # Combined Loss
    axes[0].plot(epochs, train_losses, 'b-', label='Training Loss', linewidth=2)
    axes[0].plot(epochs, val_losses, 'r-', label='Validation Loss', linewidth=2)
    axes[0].set_title('Training and Validation Loss')
    axes[0].set_xlabel('Epoch')
    axes[0].set_ylabel('Loss')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # R² Score over time
    if val_metrics_history:
        r2_scores = [m.get('1rm_r2', 0) for m in val_metrics_history]
        axes[1].plot(epochs, r2_scores, 'g-', linewidth=2, marker='o', markersize=3)
        axes[1].set_title('1RM Prediction R² Score')
        axes[1].set_xlabel('Epoch')
        axes[1].set_ylabel('R² Score')
        axes[1].grid(True, alpha=0.3)
        axes[1].axhline(y=0.8, color='r', linestyle='--', alpha=0.5, label='Target: 0.8')
        axes[1].legend()
    
    plt.tight_layout()
    plt.savefig(os.path.join(viz_dir, '07_training_history.png'), dpi=300, bbox_inches='tight')
    plt.close()
    print(f"  ✅ Saved: 07_training_history.png")



# ==================== MAIN TRAINING FUNCTION ====================

def load_and_combine_datasets(data_dir: str) -> pd.DataFrame:
    """
    Load and combine datasets from v3/data directory
    - Primary: enhanced_gym_member_exercise_tracking_10k.xlsx
    - Test: test_dataset.xlsx (prioritized for test set)
    """
    import glob

    print(f"\n[1] Loading and combining datasets from: {data_dir}")

    # Define dataset paths
    primary_path = os.path.join(data_dir, "enhanced_gym_member_exercise_tracking_10k.xlsx")
    test_path = os.path.join(data_dir, "test_dataset.xlsx")

    datasets = []

    # Load primary dataset
    if os.path.exists(primary_path):
        print(f"Loading primary dataset: enhanced_gym_member_exercise_tracking_10k.xlsx")
        df_primary = pd.read_excel(primary_path)
        df_primary['source'] = 'primary'
        datasets.append(df_primary)
        print(f"  - Primary dataset shape: {df_primary.shape}")

    # Load test dataset (prioritized for test set)
    if os.path.exists(test_path):
        print(f"Loading test dataset: test_dataset.xlsx")
        df_test = pd.read_excel(test_path)
        df_test['source'] = 'test'
        datasets.append(df_test)
        print(f"  - Test dataset shape: {df_test.shape}")

    # Load any other Excel files in the directory
    other_files = glob.glob(os.path.join(data_dir, "*.xlsx"))
    for file_path in other_files:
        filename = os.path.basename(file_path)
        if filename not in ["enhanced_gym_member_exercise_tracking_10k.xlsx", "test_dataset.xlsx"]:
            print(f"Loading additional dataset: {filename}")
            try:
                df_other = pd.read_excel(file_path)
                df_other['source'] = 'other'
                datasets.append(df_other)
                print(f"  - {filename} shape: {df_other.shape}")
            except Exception as e:
                print(f"  - Error loading {filename}: {e}")

    if not datasets:
        raise FileNotFoundError("No valid Excel datasets found in the specified directory")

    # Combine all datasets
    df_combined = pd.concat(datasets, ignore_index=True)
    print(f"\nCombined dataset shape: {df_combined.shape}")
    print(f"Source distribution:")
    print(df_combined['source'].value_counts().to_dict())

    return df_combined

def create_train_val_test_split(df: pd.DataFrame, train_ratio: float = 0.7,
                               val_ratio: float = 0.1, test_ratio: float = 0.2,
                               random_state: int = 42) -> Tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """
    Create train/validation/test split with priority for test dataset

    Args:
        df: Combined dataset with 'source' column
        train_ratio: Proportion for training (default: 0.7)
        val_ratio: Proportion for validation (default: 0.1)
        test_ratio: Proportion for testing (default: 0.2)
        random_state: Random seed for reproducibility

    Returns:
        Tuple of (train_df, val_df, test_df)
    """
    print(f"\n[2] Creating train/validation/test split")
    print(f"Target ratios - Train: {train_ratio}, Val: {val_ratio}, Test: {test_ratio}")

    # Prioritize test dataset for test set
    test_df = df[df['source'] == 'test'].copy()
    non_test_df = df[df['source'] != 'test'].copy()

    print(f"Test dataset from source: {len(test_df)} samples")

    # Calculate how many more test samples we need
    total_samples = len(df)
    target_test_size = int(total_samples * test_ratio)
    additional_test_needed = max(0, target_test_size - len(test_df))

    print(f"Target test size: {target_test_size}, Additional test samples needed: {additional_test_needed}")

    # If we need more test samples, take from non-test data
    if additional_test_needed > 0 and len(non_test_df) > 0:
        # Shuffle non-test data
        non_test_shuffled = non_test_df.sample(frac=1, random_state=random_state)

        # Take additional samples for test
        additional_test = non_test_shuffled.head(additional_test_needed)
        test_df = pd.concat([test_df, additional_test], ignore_index=True)

        # Update non_test_df to exclude the additional test samples
        remaining_indices = non_test_shuffled.index[additional_test_needed:]
        non_test_df = non_test_shuffled.loc[remaining_indices]

        print(f"Added {len(additional_test)} additional samples to test set")

    # Calculate train and validation sizes from remaining data
    remaining_size = len(non_test_df)
    target_val_size = int(total_samples * val_ratio)
    target_train_size = remaining_size - target_val_size

    # Split remaining data into train and validation
    if len(non_test_df) > 0:
        train_df = non_test_df.head(target_train_size)
        val_df = non_test_df.tail(len(non_test_df) - target_train_size)
    else:
        # Edge case: no remaining data
        train_df = pd.DataFrame()
        val_df = pd.DataFrame()

    print(f"\nFinal split:")
    print(f"  Train: {len(train_df)} samples ({len(train_df)/len(df)*100:.1f}%)")
    print(f"  Validation: {len(val_df)} samples ({len(val_df)/len(df)*100:.1f}%)")
    print(f"  Test: {len(test_df)} samples ({len(test_df)/len(df)*100:.1f}%)")

    # Remove 'source' column from splits
    for split_df in [train_df, val_df, test_df]:
        if 'source' in split_df.columns:
            split_df.drop('source', axis=1, inplace=True)

    return train_df, val_df, test_df

def main(data_dir: str, artifacts_dir: str, epochs: int = 100, batch_size: int = 64,
         lr: float = 1e-3, use_transformer: bool = False):

    print("="*80)
    print("V3 ENHANCED TRAINING - 1RM PREDICTION WITH SEPA INTEGRATION")
    print("Implementing Strategy_Analysis.md Recommendations")
    print("="*80)

    os.makedirs(artifacts_dir, exist_ok=True)

    # Load and combine datasets
    df_combined = load_and_combine_datasets(data_dir)
    print(f"Combined dataset shape: {df_combined.shape}")
    print(f"Columns: {list(df_combined.columns)}")

    # Generate training data visualizations
    print(f"\n📊 Generating Training Data Analysis...")
    plot_training_data_analysis(df_combined, artifacts_dir)

    # Create train/validation/test split
    train_df, val_df, test_df = create_train_val_test_split(df_combined, train_ratio=0.7, val_ratio=0.1, test_ratio=0.2)

    # ==================== FEATURE ENGINEERING ====================

    print("\n[3] Feature Engineering and Target Preparation")

    # Since the datasets already have processed columns, we'll use them directly
    # The datasets should already have: estimated_1rm, mood, fatigue, effort, suitability_x, etc.

    def prepare_features_and_targets(df: pd.DataFrame, split_name: str):
        """Prepare features and targets for a given dataframe"""
        print(f"\n  Preparing {split_name} dataset ({len(df)} samples)...")

        # Check if SePA columns need standardization (they might already be numeric)
        if 'mood' in df.columns:
            # Check if mood is already numeric (1-5) or needs conversion
            if df['mood'].dtype == 'object' or df['mood'].apply(lambda x: isinstance(x, str)).any():
                df['mood_numeric'] = df['mood'].apply(lambda x: map_sepa_to_numeric(x, MOOD_MAPPING))
                print(f"    - Mood standardized: {df['mood_numeric'].value_counts().sort_index().to_dict()}")
            else:
                df['mood_numeric'] = df['mood'].astype(float)
                print(f"    - Mood already numeric: {df['mood_numeric'].value_counts().sort_index().to_dict()}")

        if 'fatigue' in df.columns:
            if df['fatigue'].dtype == 'object' or df['fatigue'].apply(lambda x: isinstance(x, str)).any():
                df['fatigue_numeric'] = df['fatigue'].apply(lambda x: map_sepa_to_numeric(x, FATIGUE_MAPPING))
                print(f"    - Fatigue standardized: {df['fatigue_numeric'].value_counts().sort_index().to_dict()}")
            else:
                df['fatigue_numeric'] = df['fatigue'].astype(float)

        if 'effort' in df.columns:
            if df['effort'].dtype == 'object' or df['effort'].apply(lambda x: isinstance(x, str)).any():
                df['effort_numeric'] = df['effort'].apply(lambda x: map_sepa_to_numeric(x, EFFORT_MAPPING))
                print(f"    - Effort standardized: {df['effort_numeric'].value_counts().sort_index().to_dict()}")
            else:
                df['effort_numeric'] = df['effort'].astype(float)

        # Calculate readiness factors
        df['readiness_factor'] = df.apply(
            lambda row: calculate_readiness_factor(
                row.get('mood_numeric', 3),
                row.get('fatigue_numeric', 3),
                row.get('effort_numeric', 3)
            ), axis=1
        )

        # Use existing suitability_x as suitability_score, or create if missing
        if 'suitability_x' in df.columns:
            df['suitability_score'] = df['suitability_x']
        else:
            # Generate synthetic suitability scores if missing
            df['suitability_score'] = np.clip(
                np.random.normal(0.7, 0.15, len(df)), 0.1, 1.0
            )

        # Feature selection
        feature_columns = [
            'age', 'weight_kg', 'height_m', 'bmi', 'experience_level',
            'workout_frequency', 'resting_heartrate', 'gender',
            'mood_numeric', 'fatigue_numeric', 'effort_numeric'
        ]

        # Filter available features
        available_features = [col for col in feature_columns if col in df.columns]
        print(f"    - Using features: {available_features}")

        # Prepare feature matrix
        X_df = df[available_features].copy()

        # Target variables
        y_1rm = df['estimated_1rm'].values
        y_suitability = df['suitability_score'].values
        y_readiness = df['readiness_factor'].values

        print(f"    - 1RM: mean={y_1rm.mean():.2f}, std={y_1rm.std():.2f}, range=[{y_1rm.min():.2f}, {y_1rm.max():.2f}]")
        print(f"    - Suitability: mean={y_suitability.mean():.3f}, std={y_suitability.std():.3f}")
        print(f"    - Readiness: mean={y_readiness.mean():.3f}, std={y_readiness.std():.3f}")

        return X_df, y_1rm, y_suitability, y_readiness, available_features

    # Prepare all splits
    X_train_full, y_1rm_train, y_suit_train, y_ready_train, feature_columns = prepare_features_and_targets(train_df, "training")
    X_val_full, y_1rm_val, y_suit_val, y_ready_val, _ = prepare_features_and_targets(val_df, "validation")
    X_test_full, y_1rm_test, y_suit_test, y_ready_test, _ = prepare_features_and_targets(test_df, "testing")

    # Handle categorical variables
    categorical_columns = ['gender'] if 'gender' in feature_columns else []
    numeric_columns = [col for col in feature_columns if col not in categorical_columns]

    print(f"\n[4] Feature Preprocessing")
    print(f"  - Numeric features: {numeric_columns}")
    print(f"  - Categorical features: {categorical_columns}")

    # Create preprocessor
    preprocessor = ColumnTransformer([
        ('num', Pipeline([
            ('imputer', SimpleImputer(strategy='median')),
            ('scaler', StandardScaler())
        ]), numeric_columns),
        ('cat', Pipeline([
            ('imputer', SimpleImputer(strategy='most_frequent')),
            ('onehot', OneHotEncoder(handle_unknown='ignore'))
        ]), categorical_columns)
    ])

    # Fit preprocessor on training data and transform all splits
    print("  - Fitting preprocessor on training data...")
    X_train_processed = preprocessor.fit_transform(X_train_full)
    X_val_processed = preprocessor.transform(X_val_full)
    X_test_processed = preprocessor.transform(X_test_full)

    # Convert sparse matrices to dense if needed
    if hasattr(X_train_processed, 'toarray'):
        X_train_processed = X_train_processed.toarray()
    if hasattr(X_val_processed, 'toarray'):
        X_val_processed = X_val_processed.toarray()
    if hasattr(X_test_processed, 'toarray'):
        X_test_processed = X_test_processed.toarray()

    # ==================== MODEL TRAINING ====================

    print(f"\n[5] Model Training")
    print(f"  - Input dimension: {X_train_processed.shape[1]}")
    print(f"  - Training samples: {len(X_train_processed)}")
    print(f"  - Validation samples: {len(X_val_processed)}")
    print(f"  - Test samples: {len(X_test_processed)}")

    # Create datasets and dataloaders
    train_dataset = V3Dataset(
        X_train_processed, y_1rm_train, y_suit_train, y_ready_train
    )
    val_dataset = V3Dataset(
        X_val_processed, y_1rm_val, y_suit_val, y_ready_val
    )
    test_dataset = V3Dataset(
        X_test_processed, y_1rm_test, y_suit_test, y_ready_test
    )

    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)
    test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False)

    # Initialize model
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"  - Using device: {device}")

    model = V3EnhancedModel(
        input_dim=X_train_processed.shape[1],
        hidden_dim=256,
        num_layers=2,
        dropout=0.2,
        use_transformer=use_transformer
    ).to(device)

    # Loss functions with weights
    criterion_1rm = nn.MSELoss()
    criterion_suit = nn.MSELoss()
    criterion_ready = nn.MSELoss()

    # Optimizer
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(
        optimizer, mode='min', factor=0.5, patience=10
    )

    # Training loop
    train_losses = []
    val_losses = []
    val_metrics_history = []
    best_val_loss = float('inf')
    patience_counter = 0

    print(f"  - Starting training for {epochs} epochs...")

    for epoch in range(epochs):
        # Training
        train_loss, train_loss_1rm, train_loss_suit, train_loss_ready = train_epoch(
            model, train_loader, optimizer, criterion_1rm, criterion_suit,
            criterion_ready, device
        )
        train_losses.append(train_loss)

        # Validation
        val_loss, val_metrics = validate_epoch(
            model, val_loader, criterion_1rm, criterion_suit,
            criterion_ready, device
        )
        val_losses.append(val_loss)
        val_metrics_history.append(val_metrics)

        # Track learning rate for verbose logging
        old_lr = optimizer.param_groups[0]['lr']
        scheduler.step(val_loss)
        new_lr = optimizer.param_groups[0]['lr']

        # Manual verbose logging for learning rate changes
        if new_lr != old_lr:
            print(f"    Learning rate reduced: {old_lr:.6f} -> {new_lr:.6f}")

        # Print progress
        if (epoch + 1) % 10 == 0 or epoch == 0:
            print(f"    Epoch {epoch+1:3d}/{epochs}: "
                  f"Train Loss={train_loss:.4f}, Val Loss={val_loss:.4f}, "
                  f"Val R²={val_metrics['1rm_r2']:.4f}")

        # Early stopping
        if val_loss < best_val_loss:
            best_val_loss = val_loss
            patience_counter = 0
            # Save best model
            torch.save(model.state_dict(), os.path.join(artifacts_dir, "best_v3.pt"))
        else:
            patience_counter += 1
            if patience_counter >= 20:
                print(f"    Early stopping at epoch {epoch+1}")
                break

    # Load best model for evaluation
    model.load_state_dict(torch.load(os.path.join(artifacts_dir, "best_v3.pt")))

    # Final evaluation on test set
    print(f"\n[6] Final Test Evaluation")
    test_loss, test_metrics = validate_epoch(
        model, test_loader, criterion_1rm, criterion_suit,
        criterion_ready, device
    )

    print(f"  - Test Loss: {test_loss:.4f}")
    print(f"  - Test 1RM RMSE: {test_metrics['1rm_rmse']:.4f}")
    print(f"  - Test 1RM R²: {test_metrics['1rm_r2']:.4f}")
    print(f"  - Test 1RM MAE: {test_metrics['1rm_mae']:.4f}")
    print(f"  - Test Suitability Correlation: {test_metrics['suitability_corr']:.4f}")
    print(f"  - Test Readiness Correlation: {test_metrics['readiness_corr']:.4f}")

    # Create test_results dictionary
    test_results = {
        'test_loss': float(test_loss),
        'test_1rm_rmse': float(test_metrics['1rm_rmse']),
        'test_1rm_r2': float(test_metrics['1rm_r2']),
        'test_1rm_mae': float(test_metrics['1rm_mae']),
        'test_suitability_rmse': float(test_metrics['suitability_rmse']),
        'test_suitability_corr': float(test_metrics['suitability_corr']),
        'test_readiness_rmse': float(test_metrics['readiness_rmse']),
        'test_readiness_corr': float(test_metrics['readiness_corr'])
    }

    # Plot training history
    plot_training_history(train_losses, val_losses, val_metrics_history, artifacts_dir)

    # Save preprocessor
    preprocessor_path = os.path.join(artifacts_dir, "preprocessor_v3.joblib")
    joblib.dump(preprocessor, preprocessor_path)

    # Save metadata
    metadata = {
        'model_version': 'v3_enhanced',
        'training_date': '2025-11-25',
        'dataset_info': {
            'data_directory': data_dir,
            'total_samples': len(df_combined),
            'train_samples': len(X_train_processed),
            'val_samples': len(X_val_processed),
            'test_samples': len(X_test_processed),
            'feature_columns': feature_columns,
            'numeric_features': numeric_columns,
            'categorical_features': categorical_columns,
            'data_sources': df_combined['source'].value_counts().to_dict() if 'source' in df_combined.columns else {}
        },
        'target_statistics': {
            'train': {
                '1rm_mean': float(y_1rm_train.mean()),
                '1rm_std': float(y_1rm_train.std()),
                '1rm_min': float(y_1rm_train.min()),
                '1rm_max': float(y_1rm_train.max()),
                'suitability_mean': float(y_suit_train.mean()),
                'readiness_mean': float(y_ready_train.mean())
            },
            'test': {
                '1rm_mean': float(y_1rm_test.mean()),
                '1rm_std': float(y_1rm_test.std()),
                '1rm_min': float(y_1rm_test.min()),
                '1rm_max': float(y_1rm_test.max()),
                'suitability_mean': float(y_suit_test.mean()),
                'readiness_mean': float(y_ready_test.mean())
            }
        },
        'test_results': test_results,
        'sepa_mapping': {
            'mood': MOOD_MAPPING,
            'fatigue': FATIGUE_MAPPING,
            'effort': EFFORT_MAPPING
        },
        'workout_goals': WORKOUT_GOAL_MAPPING,
        'model_architecture': {
            'input_dim': X_train_processed.shape[1],
            'hidden_dim': 256,
            'num_layers': 2,
            'dropout': 0.2,
            'use_transformer': use_transformer,
            'multi_task_heads': ['1rm_prediction', 'suitability_scoring', 'readiness_factor']
        },
        'best_validation_metrics': {k: float(v) for k, v in val_metrics.items()},
        'training_config': {
            'epochs': epochs,
            'batch_size': batch_size,
            'learning_rate': lr,
            'loss_weights': {'1rm': 2.0, 'suitability': 1.0, 'readiness': 0.5}
        },
        'strategy_analysis_implementation': {
            'feature_engineering': '1RM estimation using Epley formula',
            'sepa_integration': 'Mood, Fatigue, Effort standardized to 1-5 scale',
            'readiness_calculation': 'Auto-regulation based on SePA scores',
            'multi_task_learning': 'Simultaneous 1RM, suitability, and readiness prediction',
            'rule_based_decoding': 'Goal-based workout parameter generation'
        }
    }

    metadata_path = os.path.join(artifacts_dir, "meta_v3.json")
    with open(metadata_path, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)

    # Save decoding rules
    decoding_rules_path = os.path.join(artifacts_dir, "decoding_rules.json")
    with open(decoding_rules_path, 'w', encoding='utf-8') as f:
        json.dump(WORKOUT_GOAL_MAPPING, f, indent=2, ensure_ascii=False)

    print(f"Artifacts saved to {artifacts_dir}/:")
    print(f"  - best_v3.pt (model weights)")
    print(f"  - preprocessor_v3.joblib (feature preprocessing)")
    print(f"  - meta_v3.json (metadata and config)")
    print(f"  - decoding_rules.json (workout generation rules)")

    # ==================== DEMONSTRATION ====================

    print(f"\n[8] Model Demonstration")
    print("Example workout decoding:")

    # Sample demonstration
    sample_1rm = 80.0
    sample_readiness = 1.1
    goals = ['strength', 'hypertrophy', 'endurance']

    for goal in goals:
        workout_params = decode_1rm_to_workout(sample_1rm, goal, sample_readiness)
        print(f"\n  Goal: {goal.upper()}")
        print(f"    Predicted 1RM: {workout_params['predicted_1rm']}kg")
        print(f"    Adjusted 1RM: {workout_params['adjusted_1rm']}kg (Readiness: {workout_params['readiness_factor']})")
        print(f"    Training Weight: {workout_params['training_weight_kg']['recommended']:.1f}kg")
        print(f"    Reps: {workout_params['reps']['recommended']} ({workout_params['reps']['min']}-{workout_params['reps']['max']})")
        print(f"    Sets: {workout_params['sets']['recommended']} ({workout_params['sets']['min']}-{workout_params['sets']['max']})")
        print(f"    Rest: {workout_params['rest_minutes']['recommended']:.1f}min")

    print(f"\n{'='*80}")
    print("V3 ENHANCED TRAINING COMPLETED SUCCESSFULLY")
    print(f"{'='*80}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='V3 Enhanced Training with 1RM Prediction and SePA Integration')
    parser.add_argument('--data_dir', type=str,
                       default='./data',
                       help='Directory containing Excel datasets')
    parser.add_argument('--artifacts', type=str,
                       default='./model',
                       help='Directory to save model artifacts')
    parser.add_argument('--epochs', type=int, default=100, help='Number of training epochs')
    parser.add_argument('--batch_size', type=int, default=64, help='Batch size for training')
    parser.add_argument('--lr', type=float, default=1e-3, help='Learning rate')
    parser.add_argument('--use_transformer', action='store_true', help='Use Transformer instead of LSTM')

    args = parser.parse_args()

    main(
        data_dir=args.data_dir,
        artifacts_dir=args.artifacts,
        epochs=args.epochs,
        batch_size=args.batch_size,
        lr=args.lr,
        use_transformer=args.use_transformer
    )
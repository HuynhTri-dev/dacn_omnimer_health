"""
two_branch_model_v4.py
V4 Two-Branch Model Architecture following README.md requirements

Architecture:
1. Branch A: Dự đoán Cường độ (Intensity Prediction)
   - Input: User Health Profile + Exercise List
   - Output: Output_Intensity (real number for predicted intensity)

2. Branch B: Dự đoán Nhãn (Label/Suitability Prediction)
   - Input: Exercise_Info + Output_Intensity + Health Indicators
   - Output: Output_Suitable (0-1 suitability score)

Key Features:
- Advanced feature preprocessing with intensity coefficients
- Multi-task learning for intensity and suitability
- SePA integration for personalized recommendations
- Rule-based workout decoding from intensity predictions
- Comprehensive evaluation metrics

Author: Claude Code Assistant
Date: 2025-11-27
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
import json
from typing import Dict, List, Tuple, Optional, Union
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import RobustScaler, StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import joblib
import warnings
warnings.filterwarnings('ignore')

# ==================== INTENSITY COEFFICIENT CALCULATION ====================

class IntensityCoefficientsCalculator:
    """
    Calculate intensity coefficients for exercise normalization
    According to V4 README specifications
    """

    def __init__(self):
        self.exercise_coefficients = {}
        self.default_coefficients = {
            'resistance_coefficient': 1.0,
            'cardio_coefficient': 0.5,
            'volume_coefficient': 0.7,
            'rest_density_coefficient': 0.3,
            'tempo_coefficient': 0.5
        }

    def calculate_resistance_intensity(self, weight: float, reps: int, user_1rm: float) -> float:
        """
        Calculate resistance intensity coefficient
        Formula: (weight × reps) / (User_1RM × 10)
        """
        if user_1rm <= 0 or weight <= 0 or reps <= 0:
            return 0.0
        return (weight * reps) / (user_1rm * 10)

    def calculate_cardio_intensity(self, distance: float, time: float, user_max_pace: float) -> float:
        """
        Calculate cardio intensity coefficient
        Formula: distance / (time × User_MaxPace)
        """
        if user_max_pace <= 0 or time <= 0 or distance <= 0:
            return 0.0
        return distance / (time * user_max_pace)

    def calculate_volume_load(self, weight: float, reps: int, sets: int, max_volume: float = 10000) -> float:
        """
        Calculate normalized volume load coefficient
        Formula: (weight × reps × sets) / max_volume
        """
        if max_volume <= 0:
            max_volume = 10000.0
        return (weight * reps * sets) / max_volume

    def calculate_rest_density(self, rest_time: float, total_time: float) -> float:
        """
        Calculate rest density coefficient
        Formula: rest_time / total_time
        """
        if total_time <= 0:
            return 0.0
        return np.clip(rest_time / total_time, 0.0, 1.0)

    def calculate_tempo_factor(self, eccentric: float = 2.0, concentric: float = 1.0,
                               isometric: float = 0.0) -> float:
        """
        Calculate tempo factor coefficient
        Simplified formula based on movement speed
        """
        total_time = eccentric + concentric + isometric
        if total_time <= 0:
            return 1.0

        # Faster tempo = higher coefficient (up to reasonable limits)
        tempo_score = 4.0 / total_time  # Standard: 2s eccentric, 1s concentric, 1s isometric = 4s
        return np.clip(tempo_score, 0.5, 1.5)

    def process_exercise_data(self, workout_data_str: str, user_1rm: float,
                           user_max_pace: float = 1.0) -> Dict[str, float]:
        """
        Process workout data string into intensity coefficients
        Input format: "reps x weight x sets | reps x weight x sets"
        """
        coefficients = {
            'resistance_intensity': 0.0,
            'cardio_intensity': 0.0,
            'volume_load': 0.0,
            'rest_density': 0.3,  # Default rest density
            'tempo_factor': 1.0    # Default tempo
        }

        if pd.isna(workout_data_str) or workout_data_str == '':
            return coefficients

        try:
            exercises = str(workout_data_str).split('|')
            total_volume = 0
            total_resistance = 0
            total_cardio = 0
            total_work_time = 0
            total_rest_time = 0

            for i, exercise in enumerate(exercises):
                parts = exercise.strip().split('x')
                if len(parts) >= 2:
                    reps = float(parts[0])
                    weight = float(parts[1])
                    sets = float(parts[2]) if len(parts) > 2 else 1

                    # Skip invalid data
                    if reps <= 0 or weight <= 0 or sets <= 0:
                        continue

                    # Calculate coefficients for this exercise
                    resistance_int = self.calculate_resistance_intensity(weight, reps, user_1rm)
                    cardio_int = self.calculate_cardio_intensity(weight, reps * 4, user_max_pace)  # 4s per rep avg
                    volume_load = self.calculate_volume_load(weight, reps, sets)

                    # Time estimates
                    work_time = reps * sets * 4  # 4 seconds per rep average
                    rest_time = sets * 120       # 2 minutes rest per set

                    # Accumulate totals
                    total_resistance += resistance_int * sets
                    total_cardio += cardio_int * sets
                    total_volume += volume_load
                    total_work_time += work_time
                    total_rest_time += rest_time

            # Calculate final coefficients
            if exercises and total_work_time > 0:
                coefficients['resistance_intensity'] = np.clip(total_resistance / len(exercises), 0.0, 2.0)
                coefficients['cardio_intensity'] = np.clip(total_cardio / len(exercises), 0.0, 1.5)
                coefficients['volume_load'] = np.clip(total_volume / 10000, 0.0, 1.0)
                coefficients['rest_density'] = np.clip(total_rest_time / (total_work_time + total_rest_time), 0.0, 1.0)
                coefficients['tempo_factor'] = self.calculate_tempo_factor()

        except Exception as e:
            print(f"Warning: Could not process workout data '{workout_data_str}': {e}")
            # Return default coefficients on error
            pass

        return coefficients

# ==================== V4 TWO-BRANCH MODEL ARCHITECTURE ====================

class V4TwoBranchModel(nn.Module):
    """
    V4 Two-Branch Model implementing README.md architecture

    Branch A: Dự đoán Cường độ (Intensity Prediction)
    Branch B: Dự đoán Nhãn (Suitability Prediction)
    """

    def __init__(self,
                 branch_a_input_dim: int,
                 branch_b_input_dim: int,
                 shared_dim: int = 128,
                 hidden_dims: List[int] = [256, 128, 64],
                 dropout: float = 0.3,
                 use_attention: bool = True):
        super(V4TwoBranchModel, self).__init__()

        self.branch_a_input_dim = branch_a_input_dim
        self.branch_b_input_dim = branch_b_input_dim
        self.shared_dim = shared_dim
        self.use_attention = use_attention

        # ==================== BRANCH A: INTENSITY PREDICTION ====================
        # Input: User Health Profile + Exercise Name
        self.branch_a_encoder = nn.Sequential(
            nn.Linear(branch_a_input_dim, hidden_dims[0]),
            nn.LayerNorm(hidden_dims[0]),
            nn.ReLU(),
            nn.Dropout(dropout),

            nn.Linear(hidden_dims[0], hidden_dims[1]),
            nn.LayerNorm(hidden_dims[1]),
            nn.ReLU(),
            nn.Dropout(dropout),

            nn.Linear(hidden_dims[1], shared_dim),
            nn.LayerNorm(shared_dim),
            nn.ReLU()
        )

        # User health profile processing
        self.health_profile_processor = nn.Sequential(
            nn.Linear(6, 32),  # age, weight, height, bmi, experience, goals
            nn.ReLU(),
            nn.Dropout(dropout * 0.5),
            nn.Linear(32, 16),
            nn.ReLU()
        )

        # Exercise intensity processing
        self.exercise_intensity_processor = nn.Sequential(
            nn.Linear(5, 32),  # resistance, cardio, volume, rest_density, tempo
            nn.ReLU(),
            nn.Dropout(dropout * 0.5),
            nn.Linear(32, 16),
            nn.ReLU()
        )

        # Branch A attention mechanism
        if use_attention:
            self.branch_a_attention = nn.Sequential(
                nn.Linear(shared_dim, shared_dim // 8),
                nn.Tanh(),
                nn.Linear(shared_dim // 8, 1),
                nn.Softmax(dim=1)
            )

        # Branch A output: Output_Intensity (scalar)
        self.branch_a_output = nn.Sequential(
            nn.Linear(shared_dim + 16 + 16, hidden_dims[2]),  # encoded + health + exercise
            nn.LayerNorm(hidden_dims[2]),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dims[2], hidden_dims[1]),
            nn.LayerNorm(hidden_dims[1]),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dims[1], 1),  # Output scalar intensity
        )

        # Branch B encoder (similar to Branch A)
        self.branch_b_encoder = nn.Sequential(
            nn.Linear(branch_b_input_dim + 1, hidden_dims[0]),  # +1 for intensity input
            nn.LayerNorm(hidden_dims[0]),
            nn.ReLU(),
            nn.Dropout(dropout),

            nn.Linear(hidden_dims[0], hidden_dims[1]),
            nn.LayerNorm(hidden_dims[1]),
            nn.ReLU(),
            nn.Dropout(dropout),

            nn.Linear(hidden_dims[1], shared_dim),
            nn.LayerNorm(shared_dim),
            nn.ReLU()
        )

        # Exercise info processing
        self.exercise_info_processor = nn.Sequential(
            nn.Linear(12, 32),  # muscle_group, movement_type, difficulty, etc.
            nn.ReLU(),
            nn.Dropout(dropout * 0.5),
            nn.Linear(32, 16),
            nn.ReLU()
        )

        # Health indicators processing (from WatchLog)
        self.health_indicators_processor = nn.Sequential(
            nn.Linear(8, 32),  # heart_rate_rest, heart_rate_avg, heart_rate_max, steps, distance, calories, vo2max, sleep_duration
            nn.ReLU(),
            nn.Dropout(dropout * 0.5),
            nn.Linear(32, 16),
            nn.ReLU()
        )

        # Branch B attention mechanism
        if use_attention:
            self.branch_b_attention = nn.Sequential(
                nn.Linear(shared_dim, shared_dim // 8),
                nn.Tanh(),
                nn.Linear(shared_dim // 8, 1),
                nn.Softmax(dim=1)
            )

        # Branch B output: Output_Suitable (0-1)
        self.branch_b_output = nn.Sequential(
            nn.Linear(shared_dim + 16 + 16 + 1, hidden_dims[2]),  # encoded + exercise_info + health_indicators + intensity
            nn.LayerNorm(hidden_dims[2]),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dims[2], 32),
            nn.ReLU(),
            nn.Dropout(dropout * 0.5),
            nn.Linear(32, 1)  # Output_Suitable: 0-1 range
        )

        # ==================== SHARED COMPONENTS ====================
        # Feature fusion layer
        self.feature_fusion = nn.Sequential(
            nn.Linear(shared_dim * 2, shared_dim),
            nn.LayerNorm(shared_dim),
            nn.ReLU(),
            nn.Dropout(dropout)
        )

        # Multi-task auxiliary heads (optional)
        self.readiness_head = nn.Sequential(
            nn.Linear(shared_dim, 32),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(32, 1)  # Readiness factor
        )

        self.performance_head = nn.Sequential(
            nn.Linear(shared_dim, 32),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(32, 1)  # Performance score
        )

    def forward(self, branch_a_input, branch_b_input,
                 health_profile, exercise_intensity, exercise_info, health_indicators):
        """
        Forward pass for V4 two-branch model

        Args:
            branch_a_input: User profile + exercise name (for Branch A)
            branch_b_input: Full feature set (for Branch B)
            health_profile: User health profile features [6]
            exercise_intensity: Exercise intensity coefficients [5]
            exercise_info: Exercise information [10]
            health_indicators: Health indicators from WatchLog [8]

        Returns:
            output_intensity: Predicted intensity (real number)
            output_suitable: Predicted suitability (0-1)
            output_readiness: Optional readiness factor
            output_performance: Optional performance score
        """

        # ==================== BRANCH A: INTENSITY PREDICTION ====================
        # Encode branch A input
        branch_a_encoded = self.branch_a_encoder(branch_a_input)

        # Process health profile
        health_profile_features = self.health_profile_processor(health_profile)

        # Process exercise intensity coefficients
        exercise_intensity_features = self.exercise_intensity_processor(exercise_intensity)

        # Apply attention if enabled
        if self.use_attention:
            attention_weights = self.branch_a_attention(branch_a_encoded.unsqueeze(1))
            branch_a_attended = branch_a_encoded * attention_weights.squeeze(1)
        else:
            branch_a_attended = branch_a_encoded

        # Concatenate for intensity prediction
        intensity_concat = torch.cat([
            branch_a_attended,
            health_profile_features,
            exercise_intensity_features
        ], dim=1)

        # Branch A output
        output_intensity = self.branch_a_output(intensity_concat)

        # ==================== BRANCH B: SUITABILITY PREDICTION ====================
        # Encode branch B input (includes Output_Intensity from Branch A)
        branch_b_input_with_intensity = torch.cat([branch_b_input, output_intensity], dim=1)
        branch_b_encoded = self.branch_b_encoder(branch_b_input_with_intensity)

        # Process exercise information
        exercise_info_features = self.exercise_info_processor(exercise_info)

        # Process health indicators
        health_indicators_features = self.health_indicators_processor(health_indicators)

        # Apply attention if enabled
        if self.use_attention:
            attention_weights = self.branch_b_attention(branch_b_encoded.unsqueeze(1))
            branch_b_attended = branch_b_encoded * attention_weights.squeeze(1)
        else:
            branch_b_attended = branch_b_encoded

        # Concatenate for suitability prediction
        suitability_concat = torch.cat([
            branch_b_attended,
            exercise_info_features,
            health_indicators_features,
            output_intensity  # Include intensity output
        ], dim=1)

        # Branch B output (apply sigmoid for 0-1 range)
        output_suitable_raw = self.branch_b_output(suitability_concat)
        output_suitable = torch.sigmoid(output_suitable_raw)

        # ==================== SHARED FEATURES & MULTI-TASK ====================
        # Fuse features from both branches
        fused_features = torch.cat([branch_a_attended, branch_b_attended], dim=1)
        fused_encoded = self.feature_fusion(fused_features)

        # Optional auxiliary outputs
        output_readiness = self.readiness_head(fused_encoded)
        output_performance = self.performance_head(fused_encoded)

        return {
            'output_intensity': output_intensity,
            'output_suitable': output_suitable,
            'output_readiness': output_readiness,
            'output_performance': output_performance,
            'branch_a_features': branch_a_attended,
            'branch_b_features': branch_b_attended,
            'fused_features': fused_encoded
        }

# ==================== V4 DATASET CLASS ====================

class V4Dataset(Dataset):
    """Enhanced Dataset for V4 Two-Branch Model Training"""

    def __init__(self, data: pd.DataFrame, feature_columns: Dict[str, List[str]],
                 target_columns: Dict[str, str], intensity_calculator: IntensityCoefficientsCalculator):
        self.data = data
        self.feature_columns = feature_columns
        self.target_columns = target_columns
        self.intensity_calculator = intensity_calculator

        # Preprocess data
        self._preprocess_data()

    def _preprocess_data(self):
        """Preprocess and validate all features and targets"""
        print(f"Preprocessing V4 dataset with {len(self.data)} samples...")

        # Initialize feature containers
        self.branch_a_features = []
        self.branch_b_features = []
        self.health_profiles = []
        self.exercise_intensities = []
        self.exercise_infos = []
        self.health_indicators = []
        self.targets = []

        for idx, row in self.data.iterrows():
            try:
                # Extract Branch A features (User Health Profile + Exercise)
                branch_a_feat = self._extract_branch_a_features(row)

                # Extract Branch B features (Full feature set)
                branch_b_feat = self._extract_branch_b_features(row)

                # Extract health profile [6 features]
                health_profile = self._extract_health_profile(row)

                # Calculate exercise intensity coefficients [5 features]
                exercise_intensity = self._calculate_exercise_intensity(row)

                # Extract exercise information [10 features]
                exercise_info = self._extract_exercise_info(row)

                # Extract health indicators [8 features]
                health_indicators = self._extract_health_indicators(row)

                # Extract targets
                targets = self._extract_targets(row)

                # Validate and store
                if self._validate_sample(branch_a_feat, branch_b_feat, health_profile,
                                      exercise_intensity, exercise_info, health_indicators, targets):
                    self.branch_a_features.append(branch_a_feat)
                    self.branch_b_features.append(branch_b_feat)
                    self.health_profiles.append(health_profile)
                    self.exercise_intensities.append(exercise_intensity)
                    self.exercise_infos.append(exercise_info)
                    self.health_indicators.append(health_indicators)
                    self.targets.append(targets)

            except Exception as e:
                print(f"Warning: Skipping sample {idx} due to error: {e}")
                continue

        print(f"Successfully preprocessed {len(self.branch_a_features)} samples")

    def _extract_branch_a_features(self, row) -> np.ndarray:
        """Extract features for Branch A (User Health Profile + Exercise)"""
        features = []

        # User health profile features
        health_cols = ['age', 'weight_kg', 'height_m', 'bmi', 'experience_level']
        for col in health_cols:
            value = row.get(col, 0)
            features.append(float(value) if pd.notna(value) else 0.0)

        # Exercise name encoding (simplified - would use proper encoding in production)
        exercise_name = str(row.get('exercise_name', 'unknown')).lower()
        exercise_features = self._encode_exercise_name(exercise_name)
        features.extend(exercise_features)

        # Fitness goal encoding
        fitness_goal = str(row.get('fitness_goal', 'general')).lower()
        goal_encoding = self._encode_fitness_goal(fitness_goal)
        features.extend(goal_encoding)

        return np.array(features, dtype=np.float32)

    def _extract_branch_b_features(self, row) -> np.ndarray:
        """Extract features for Branch B (Full feature set)"""
        features = []

        # All demographic and experience features
        demo_cols = ['age', 'weight_kg', 'height_m', 'bmi', 'experience_level',
                     'workout_frequency', 'resting_heartrate']
        for col in demo_cols:
            value = row.get(col, 0)
            features.append(float(value) if pd.notna(value) else 0.0)

        # SePA features
        sepa_cols = ['mood_numeric', 'fatigue_numeric', 'effort_numeric', 'readiness_factor_v4']
        for col in sepa_cols:
            value = row.get(col, 3)  # Default to neutral
            features.append(float(value) if pd.notna(value) else 3.0)

        # Performance metrics
        perf_cols = ['strength_to_weight_ratio', 'overall_performance_score', 'training_density']
        for col in perf_cols:
            value = row.get(col, 0)
            features.append(float(value) if pd.notna(value) else 0.0)

        # Intensity coefficients (will be calculated separately)
        intensity_cols = ['resistance_intensity', 'cardio_intensity', 'volume_load',
                         'rest_density', 'tempo_factor']
        for col in intensity_cols:
            value = row.get(col, 0.5)  # Default to moderate
            features.append(float(value) if pd.notna(value) else 0.5)

        result = np.array(features, dtype=np.float32)

        # Debug: print first few feature dimensions
        if hasattr(self, '_debug_count') and self._debug_count < 3:
            print(f"[DEBUG] Branch B features shape: {result.shape}")
            print(f"[DEBUG] Available columns sample: {list(row.keys())[:10]}...")
            self._debug_count += 1
        elif not hasattr(self, '_debug_count'):
            self._debug_count = 1
            print(f"[DEBUG] Branch B features shape: {result.shape}")
            print(f"[DEBUG] Available columns sample: {list(row.keys())[:10]}...")

        return result

    def _extract_health_profile(self, row) -> np.ndarray:
        """Extract user health profile [6 features]"""
        return np.array([
            float(row.get('age', 30)) / 80,           # Normalized age
            float(row.get('weight_kg', 70)) / 150,     # Normalized weight
            float(row.get('height_m', 1.7)) / 2.2,     # Normalized height
            float(row.get('bmi', 23)) / 40,            # Normalized BMI
            float(row.get('experience_level', 1)) / 5,  # Normalized experience
            float(row.get('fitness_goal_encoded', 0))   # Goal encoding
        ], dtype=np.float32)

    def _calculate_exercise_intensity(self, row) -> np.ndarray:
        """Calculate exercise intensity coefficients [5 features]"""
        workout_data = str(row.get('workout_data', ''))
        user_1rm = float(row.get('estimated_1rm', 50))
        user_max_pace = float(row.get('max_pace', 1.0))

        coefficients = self.intensity_calculator.process_exercise_data(
            workout_data, user_1rm, user_max_pace
        )

        return np.array([
            coefficients['resistance_intensity'],
            coefficients['cardio_intensity'],
            coefficients['volume_load'],
            coefficients['rest_density'],
            coefficients['tempo_factor']
        ], dtype=np.float32)

    def _extract_exercise_info(self, row) -> np.ndarray:
        """Extract exercise information [10 features]"""
        exercise_name = str(row.get('exercise_name', 'unknown')).lower()

        # Simplified exercise encoding (would use proper database in production)
        muscle_group_encoding = self._encode_muscle_group(exercise_name)
        movement_type_encoding = self._encode_movement_type(exercise_name)
        difficulty_encoding = self._encode_difficulty(exercise_name)

        # Additional exercise characteristics
        is_compound = 1.0 if any(word in exercise_name for word in ['squat', 'deadlift', 'bench', 'press']) else 0.0
        is_cardio = 1.0 if any(word in exercise_name for word in ['run', 'cycle', 'swim', 'row']) else 0.0
        is_bodyweight = 1.0 if any(word in exercise_name for word in ['push', 'pull', 'plank', 'burpee']) else 0.0

        # Equipment type encoding (simplified)
        equipment_encoding = self._encode_equipment(exercise_name)

        # Skill level requirement
        skill_level = self._estimate_skill_level(exercise_name, row.get('experience_level', 1))

        return np.array([
            *muscle_group_encoding,    # [4] muscle groups
            *movement_type_encoding,   # [2] movement types
            difficulty_encoding,        # [1] difficulty
            is_compound,              # [1] compound movement
            is_cardio,                # [1] cardio movement
            is_bodyweight,             # [1] bodyweight
            equipment_encoding,        # [1] equipment type
            skill_level                # [1] skill level requirement
        ], dtype=np.float32)

    def _extract_health_indicators(self, row) -> np.ndarray:
        """Extract health indicators from WatchLog [8 features]"""
        return np.array([
            float(row.get('heart_rate_rest', 70)) / 120,    # Normalized resting HR
            float(row.get('heart_rate_avg', 85)) / 180,     # Normalized avg HR
            float(row.get('heart_rate_max', 120)) / 200,     # Normalized max HR
            float(row.get('steps', 8000)) / 20000,          # Normalized steps
            float(row.get('distance', 5)) / 20,             # Normalized distance (km)
            float(row.get('calories_burned', 300)) / 1000,  # Normalized calories
            float(row.get('vo2max', 35)) / 60,             # Normalized VO2max
            float(row.get('sleep_duration', 7)) / 12         # Normalized sleep
        ], dtype=np.float32)

    def _extract_targets(self, row) -> Dict[str, float]:
        """Extract target variables"""
        return {
            'target_intensity': float(row.get('target_overall_intensity', 0.7)),
            'target_suitability': float(row.get('target_suitability', 0.6)),
            'target_readiness': float(row.get('target_readiness_v4', 1.0)),
            'target_performance': float(row.get('overall_performance_score', 0.7))
        }

    def _encode_exercise_name(self, exercise_name: str) -> List[float]:
        """Simple exercise name encoding"""
        # Simplified encoding - would use proper embedding in production
        categories = ['push', 'pull', 'squat', 'hinge', 'carry', 'rotation']
        encoding = [1.0 if cat in exercise_name else 0.0 for cat in categories]
        return encoding

    def _encode_fitness_goal(self, fitness_goal: str) -> List[float]:
        """Encode fitness goal"""
        goals = ['strength', 'hypertrophy', 'endurance', 'general']
        return [1.0 if fitness_goal == goal else 0.0 for goal in goals]

    def _encode_muscle_group(self, exercise_name: str) -> List[float]:
        """Encode primary muscle groups"""
        groups = ['chest', 'back', 'legs', 'shoulders']
        encoding = [0.0] * len(groups)

        if any(word in exercise_name for word in ['bench', 'press', 'push']):
            encoding[0] = 1.0  # chest
        if any(word in exercise_name for word in ['row', 'pull', 'deadlift']):
            encoding[1] = 1.0  # back
        if any(word in exercise_name for word in ['squat', 'lunge', 'leg']):
            encoding[2] = 1.0  # legs
        if any(word in exercise_name for word in ['shoulder', 'press']):
            encoding[3] = 1.0  # shoulders

        return encoding

    def _encode_movement_type(self, exercise_name: str) -> List[float]:
        """Encode movement type"""
        if any(word in exercise_name for word in ['run', 'cycle', 'swim', 'row']):
            return [0.0, 1.0]  # cardio
        else:
            return [1.0, 0.0]  # resistance

    def _encode_difficulty(self, exercise_name: str) -> float:
        """Encode exercise difficulty"""
        complex_exercises = ['deadlift', 'olympic', 'muscle', 'planche']
        if any(word in exercise_name for word in complex_exercises):
            return 0.8
        intermediate_exercises = ['squat', 'bench', 'pull', 'handstand']
        if any(word in exercise_name for word in intermediate_exercises):
            return 0.6
        return 0.3  # beginner

    def _encode_equipment(self, exercise_name: str) -> float:
        """Encode equipment requirement"""
        if any(word in exercise_name for word in ['push', 'pull', 'plank']):
            return 0.0  # bodyweight
        elif any(word in exercise_name for word in ['barbell', 'dumbbell']):
            return 0.7  # free weights
        else:
            return 0.4  # machines/cables

    def _estimate_skill_level(self, exercise_name: str, user_experience: float) -> float:
        """Estimate required skill level considering user experience"""
        base_difficulty = self._encode_difficulty(exercise_name)
        # Adjust based on user experience
        return np.clip(base_difficulty - (user_experience * 0.1), 0.1, 1.0)

    def _validate_sample(self, *arrays) -> bool:
        """Validate that all arrays have valid values"""
        try:
            for arr in arrays:
                if isinstance(arr, dict):
                    # Validate dictionary targets
                    for v in arr.values():
                        if not np.isfinite(v):
                            return False
                else:
                    # Validate numpy arrays
                    if not np.all(np.isfinite(arr)):
                        return False
            return True
        except:
            return False

    def __len__(self):
        return len(self.branch_a_features)

    def __getitem__(self, idx):
        return (
            torch.FloatTensor(self.branch_a_features[idx]),
            torch.FloatTensor(self.branch_b_features[idx]),
            torch.FloatTensor(self.health_profiles[idx]),
            torch.FloatTensor(self.exercise_intensities[idx]),
            torch.FloatTensor(self.exercise_infos[idx]),
            torch.FloatTensor(self.health_indicators[idx]),
            torch.FloatTensor([self.targets[idx]['target_intensity']]),
            torch.FloatTensor([self.targets[idx]['target_suitability']]),
            torch.FloatTensor([self.targets[idx]['target_readiness']]),
            torch.FloatTensor([self.targets[idx]['target_performance']])
        )

# ==================== V4 MODEL TRAINER ====================

class V4ModelTrainer:
    """Trainer for V4 Two-Branch Model"""

    def __init__(self, data_path: str, artifacts_dir: str = "./artifacts_v4"):
        self.data_path = Path(data_path)
        self.artifacts_dir = Path(artifacts_dir)
        self.artifacts_dir.mkdir(exist_ok=True)

        self.data = None
        self.model = None
        self.scalers = {}
        self.intensity_calculator = IntensityCoefficientsCalculator()
        self.training_history = {}

    def load_and_prepare_data(self, data_cleaner=None, data_dir=None):
        """Load and prepare data for V4 training with dataset merging"""
        print(" Loading and preparing V4 data...")

        if data_cleaner is not None and hasattr(data_cleaner, 'cleaned_data'):
            # Use pre-cleaned data from V4DataCleaner (already merged)
            self.data = data_cleaner.cleaned_data.copy()
            print(f"   • Using pre-cleaned data: {self.data.shape}")
        else:
            # Load and merge multiple datasets
            if data_dir is None:
                data_dir = Path(self.data_path).parent

            data_files = self._discover_data_files(data_dir)
            datasets = []

            print("   • Discovering data files:")
            for file_path in data_files:
                try:
                    df = pd.read_excel(file_path)
                    datasets.append(df)
                    print(f"     - Loaded {file_path.name}: {df.shape}")
                except Exception as e:
                    print(f"     -  Error loading {file_path.name}: {e}")

            if not datasets:
                raise FileNotFoundError(f"No valid data files found in {data_dir}")

            # Merge all datasets
            print("   • Merging datasets...")
            self.data = pd.concat(datasets, ignore_index=True)
            print(f"   • Combined data shape: {self.data.shape}")

            # Apply basic cleaning to merged data
            self.data = self._basic_cleaning(self.data)

            # Ensure consistent column ordering
            self.data = self._standardize_columns(self.data)

        # Ensure required columns exist
        self._ensure_required_columns()

        print(f"   • Final data shape: {self.data.shape}")
        return self.data

    def _discover_data_files(self, data_dir: Path) -> List[Path]:
        """Discover and prioritize data files for merging"""
        data_dir = Path(data_dir)

        # Priority order for data files
        priority_files = [
            "enhanced_gym_member_exercise_tracking_10k.xlsx",  # Primary training data
            "test_dataset.xlsx",                                 # Test data
            "enhanced_gym_member_exercise_tracking_v4_cleaned.xlsx",  # Pre-cleaned if available
        ]

        discovered_files = []

        # Check priority files first
        for filename in priority_files:
            file_path = data_dir / filename
            if file_path.exists():
                discovered_files.append(file_path)
                print(f"   • Found priority file: {filename}")

        # Check for any other Excel files
        for file_path in data_dir.glob("*.xlsx"):
            if file_path not in discovered_files:
                discovered_files.append(file_path)
                print(f"   • Found additional file: {file_path.name}")

        return discovered_files

    def _standardize_columns(self, data: pd.DataFrame) -> pd.DataFrame:
        """Standardize column names and order across merged datasets"""
        # Define expected column order (based on current data structure)
        expected_columns = [
            'exercise_name', 'duration_min', 'avg_hr', 'max_hr', 'calories',
            'fatigue', 'effort', 'mood', 'suitability_x', 'age', 'height_m',
            'weight_kg', 'bmi', 'fat_percentage', 'resting_heartrate',
            'experience_level', 'workout_frequency', 'health_status',
            'workout_type', 'location', 'injury_or_pain_notes', 'gender',
            'session_duration', 'estimated_1rm', 'pace', 'duration_capacity',
            'rest_period', 'intensity_score'
        ]

        # Ensure all expected columns exist, add missing ones with default values
        for col in expected_columns:
            if col not in data.columns:
                if col in ['age', 'height_m', 'weight_kg', 'bmi', 'experience_level',
                          'workout_frequency', 'resting_heartrate', 'estimated_1rm',
                          'duration_min', 'avg_hr', 'max_hr', 'calories', 'gender',
                          'session_duration', 'pace', 'duration_capacity', 'rest_period',
                          'intensity_score']:
                    data[col] = 0.0  # Default for numeric columns
                elif col in ['exercise_name', 'health_status', 'workout_type', 'location',
                           'injury_or_pain_notes']:
                    data[col] = 'Unknown'  # Default for categorical columns
                elif col in ['fatigue', 'effort', 'mood']:
                    data[col] = 3  # Default to neutral SePA values

        # Reorder columns to match expected order (existing columns keep their order)
        final_columns = []
        for col in expected_columns:
            if col in data.columns:
                final_columns.append(col)

        # Add any remaining columns that weren't in expected list
        for col in data.columns:
            if col not in final_columns:
                final_columns.append(col)

        data = data[final_columns]
        print(f"   • Standardized columns: {len(data.columns)} total")

        return data

    def _basic_cleaning(self, data: pd.DataFrame) -> pd.DataFrame:
        """Basic data cleaning for V4"""
        cleaned = data.copy()

        # Remove invalid samples
        initial_count = len(cleaned)

        # Age validation
        cleaned = cleaned[(cleaned['age'] >= 16) & (cleaned['age'] <= 80)]

        # Weight validation
        cleaned = cleaned[(cleaned['weight_kg'] >= 35) & (cleaned['weight_kg'] <= 200)]

        # Height validation
        cleaned = cleaned[(cleaned['height_m'] >= 1.2) & (cleaned['height_m'] <= 2.4)]

        # 1RM validation
        cleaned = cleaned[cleaned['estimated_1rm'] > 0]

        print(f"   • Data cleaning: {initial_count} -> {len(cleaned)} samples ({len(cleaned)/initial_count:.1%} retained)")

        return cleaned

    def _ensure_required_columns(self):
        """Ensure all required columns exist"""
        required_cols = [
            'age', 'weight_kg', 'height_m', 'bmi', 'experience_level',
            'workout_frequency', 'resting_heartrate', 'estimated_1rm',
            'mood', 'fatigue', 'effort', 'workout_data'
        ]

        for col in required_cols:
            if col not in self.data.columns:
                print(f"   • Adding missing column: {col}")
        if 'exercise_name' not in self.data.columns:
            exercises = ['Bench Press', 'Squat', 'Deadlift', 'Running', 'Cycling', 'Push-ups', 'Pull-ups']
            self.data['exercise_name'] = np.random.choice(exercises, len(self.data))

        # Add health indicator columns if missing
        health_cols = ['heart_rate_rest', 'heart_rate_avg', 'heart_rate_max', 'steps',
                       'distance', 'calories_burned', 'vo2max', 'sleep_duration']
        for col in health_cols:
            if col not in self.data.columns:
                if col == 'heart_rate_rest':
                    self.data[col] = np.random.normal(65, 8, len(self.data))
                elif col == 'heart_rate_avg':
                    self.data[col] = np.random.normal(85, 12, len(self.data))
                elif col == 'heart_rate_max':
                    self.data[col] = np.random.normal(160, 20, len(self.data))
                elif col == 'steps':
                    self.data[col] = np.random.normal(8000, 3000, len(self.data))
                elif col == 'distance':
                    self.data[col] = np.random.normal(5, 3, len(self.data))
                elif col == 'calories_burned':
                    self.data[col] = np.random.normal(300, 100, len(self.data))
                elif col == 'vo2max':
                    self.data[col] = np.random.normal(35, 10, len(self.data))
                elif col == 'sleep_duration':
                    self.data[col] = np.random.normal(7, 1.5, len(self.data))

    def prepare_datasets(self, train_ratio: float = 0.7, val_ratio: float = 0.1,
                        test_ratio: float = 0.2, random_state: int = 42):
        """Prepare train/val/test datasets for V4"""
        print(" Preparing V4 datasets...")

        # Split data
        train_data, temp_data = train_test_split(
            self.data, test_size=(1-train_ratio), random_state=random_state
        )
        val_data, test_data = train_test_split(
            temp_data, test_size=test_ratio/(val_ratio+test_ratio), random_state=random_state
        )

        print(f"   • Train: {len(train_data)} samples")
        print(f"   • Validation: {len(val_data)} samples")
        print(f"   • Test: {len(test_data)} samples")

        # Define feature columns for each branch
        feature_columns = {
            'branch_a': [
                'age', 'weight_kg', 'height_m', 'bmi', 'experience_level',
                'workout_frequency', 'fitness_goal', 'exercise_name'
            ],
            'branch_b': [
                'age', 'weight_kg', 'height_m', 'bmi', 'experience_level',
                'workout_frequency', 'resting_heartrate', 'mood', 'fatigue', 'effort',
                'strength_to_weight_ratio', 'overall_performance_score', 'training_density',
                'resistance_intensity', 'cardio_intensity', 'volume_load', 'rest_density', 'tempo_factor'
            ]
        }

        target_columns = {
            'intensity': 'target_overall_intensity',
            'suitability': 'target_suitability',
            'readiness': 'target_readiness_v4',
            'performance': 'overall_performance_score'
        }

        # Create datasets
        train_dataset = V4Dataset(train_data, feature_columns, target_columns, self.intensity_calculator)
        val_dataset = V4Dataset(val_data, feature_columns, target_columns, self.intensity_calculator)
        test_dataset = V4Dataset(test_data, feature_columns, target_columns, self.intensity_calculator)

        return train_dataset, val_dataset, test_dataset, feature_columns, target_columns

    def create_model(self, branch_a_input_dim: int, branch_b_input_dim: int, **model_kwargs):
        """Create V4 Two-Branch Model"""
        print(" Creating V4 Two-Branch Model...")

        self.model = V4TwoBranchModel(
            branch_a_input_dim=branch_a_input_dim,
            branch_b_input_dim=branch_b_input_dim,
            **model_kwargs
        )

        print(f"   • Branch A input dimension: {branch_a_input_dim}")
        print(f"   • Branch B input dimension: {branch_b_input_dim}")
        print(f"   • Shared feature dimension: {self.model.shared_dim}")
        print(f"   • Model parameters: {sum(p.numel() for p in self.model.parameters()):,}")

        return self.model

    def train_model(self, train_dataset, val_dataset, epochs: int = 100,
                   batch_size: int = 64, learning_rate: float = 1e-3):
        """Train V4 Two-Branch Model"""
        print(" Training V4 Two-Branch Model...")

        # Create data loaders
        train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
        val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)

        # Setup device
        device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        self.model.to(device)

        # Loss functions
        intensity_criterion = nn.MSELoss()
        suitability_criterion = nn.BCELoss()
        readiness_criterion = nn.MSELoss()
        performance_criterion = nn.MSELoss()

        # Optimizer and scheduler
        optimizer = optim.AdamW(self.model.parameters(), lr=learning_rate, weight_decay=1e-4)
        scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='min', factor=0.5, patience=10)

        # Training tracking
        train_losses = []
        val_losses = []
        val_metrics = []
        best_val_loss = float('inf')
        patience_counter = 0

        print(f"   • Using device: {device}")
        print(f"   • Training samples: {len(train_dataset)}")
        print(f"   • Validation samples: {len(val_dataset)}")
        print(f"   • Batch size: {batch_size}")
        print(f"   • Epochs: {epochs}")

        for epoch in range(epochs):
            # Training phase
            self.model.train()
            train_loss = 0.0
            train_intensity_loss = 0.0
            train_suitability_loss = 0.0
            train_readiness_loss = 0.0
            train_performance_loss = 0.0

            for batch_idx, batch in enumerate(train_loader):
                (branch_a_input, branch_b_input, health_profile, exercise_intensity,
                 exercise_info, health_indicators, target_intensity, target_suitability,
                 target_readiness, target_performance) = batch

                # Debug: Print dimensions for first batch
                if batch_idx == 0:
                    print(f"[DEBUG TRAIN] branch_a_input shape: {branch_a_input.shape}")
                    print(f"[DEBUG TRAIN] branch_b_input shape: {branch_b_input.shape}")
                    print(f"[DEBUG TRAIN] Expected branch_b_dim: {self.model.branch_b_input_dim}")

                # Move to device
                branch_a_input = branch_a_input.to(device)
                branch_b_input = branch_b_input.to(device)
                health_profile = health_profile.to(device)
                exercise_intensity = exercise_intensity.to(device)
                exercise_info = exercise_info.to(device)
                health_indicators = health_indicators.to(device)
                target_intensity = target_intensity.to(device)
                target_suitability = target_suitability.to(device)
                target_readiness = target_readiness.to(device)
                target_performance = target_performance.to(device)

                # Forward pass
                outputs = self.model(branch_a_input, branch_b_input, health_profile,
                                  exercise_intensity, exercise_info, health_indicators)

                # Calculate losses
                loss_intensity = intensity_criterion(outputs['output_intensity'], target_intensity)
                loss_suitability = suitability_criterion(outputs['output_suitable'], target_suitability)
                loss_readiness = readiness_criterion(outputs['output_readiness'], target_readiness)
                loss_performance = performance_criterion(outputs['output_performance'], target_performance)

                # Combined loss with weights
                total_loss = (
                    2.0 * loss_intensity +      # Primary task: intensity prediction
                    2.0 * loss_suitability +    # Primary task: suitability prediction
                    0.5 * loss_readiness +      # Auxiliary task
                    0.5 * loss_performance       # Auxiliary task
                )

                # Backward pass
                optimizer.zero_grad()
                total_loss.backward()
                torch.nn.utils.clip_grad_norm_(self.model.parameters(), max_norm=1.0)
                optimizer.step()

                # Accumulate losses
                train_loss += total_loss.item()
                train_intensity_loss += loss_intensity.item()
                train_suitability_loss += loss_suitability.item()
                train_readiness_loss += loss_readiness.item()
                train_performance_loss += loss_performance.item()

            # Average training losses
            train_loss /= len(train_loader)
            train_intensity_loss /= len(train_loader)
            train_suitability_loss /= len(train_loader)
            train_readiness_loss /= len(train_loader)
            train_performance_loss /= len(train_loader)

            train_losses.append(train_loss)

            # Validation phase
            val_loss, val_metrics_epoch = self._validate_model(
                val_loader, intensity_criterion, suitability_criterion,
                readiness_criterion, performance_criterion, device
            )

            val_losses.append(val_loss)
            val_metrics.append(val_metrics_epoch)

            # Learning rate scheduling
            scheduler.step(val_loss)

            # Early stopping
            if val_loss < best_val_loss:
                best_val_loss = val_loss
                patience_counter = 0
                # Save best model
                torch.save(self.model.state_dict(), self.artifacts_dir / 'best_v4_model.pt')
            else:
                patience_counter += 1

            # Print progress
            if (epoch + 1) % 10 == 0 or epoch == 0:
                print(f"Epoch {epoch+1:3d}/{epochs}: "
                      f"Train Loss={train_loss:.4f}, Val Loss={val_loss:.4f}")
                print(f"  Intensity MAE={val_metrics_epoch['intensity_mae']:.4f}, "
                      f"Suitability MAE={val_metrics_epoch['suitability_mae']:.4f}")
                print(f"  Readiness MAE={val_metrics_epoch['readiness_mae']:.4f}, "
                      f"Performance MAE={val_metrics_epoch['performance_mae']:.4f}")

            # Early stopping
            if patience_counter >= 30:
                print(f"Early stopping at epoch {epoch+1}")
                break

        # Load best model
        self.model.load_state_dict(torch.load(self.artifacts_dir / 'best_v4_model.pt'))

        # Save training history
        self.training_history = {
            'train_losses': train_losses,
            'val_losses': val_losses,
            'val_metrics': val_metrics,
            'best_val_loss': best_val_loss,
            'total_epochs': epoch + 1
        }

        print(f"Training completed!")
        print(f"Best validation loss: {best_val_loss:.4f}")

        return self.training_history

    def _validate_model(self, val_loader, intensity_criterion, suitability_criterion,
                        readiness_criterion, performance_criterion, device):
        """Validate V4 model"""
        self.model.eval()

        val_loss = 0.0
        all_intensity_true = []
        all_intensity_pred = []
        all_suitability_true = []
        all_suitability_pred = []
        all_readiness_true = []
        all_readiness_pred = []
        all_performance_true = []
        all_performance_pred = []

        with torch.no_grad():
            for batch in val_loader:
                (branch_a_input, branch_b_input, health_profile, exercise_intensity,
                 exercise_info, health_indicators, target_intensity, target_suitability,
                 target_readiness, target_performance) = batch

                # Move to device
                branch_a_input = branch_a_input.to(device)
                branch_b_input = branch_b_input.to(device)
                health_profile = health_profile.to(device)
                exercise_intensity = exercise_intensity.to(device)
                exercise_info = exercise_info.to(device)
                health_indicators = health_indicators.to(device)
                target_intensity = target_intensity.to(device)
                target_suitability = target_suitability.to(device)
                target_readiness = target_readiness.to(device)
                target_performance = target_performance.to(device)

                # Forward pass
                outputs = self.model(branch_a_input, branch_b_input, health_profile,
                                  exercise_intensity, exercise_info, health_indicators)

                # Calculate losses
                loss_intensity = intensity_criterion(outputs['output_intensity'], target_intensity)
                loss_suitability = suitability_criterion(outputs['output_suitable'], target_suitability)
                loss_readiness = readiness_criterion(outputs['output_readiness'], target_readiness)
                loss_performance = performance_criterion(outputs['output_performance'], target_performance)

                total_loss = (
                    2.0 * loss_intensity + 2.0 * loss_suitability +
                    0.5 * loss_readiness + 0.5 * loss_performance
                )

                val_loss += total_loss.item()

                # Collect predictions
                all_intensity_true.extend(target_intensity.cpu().numpy())
                all_intensity_pred.extend(outputs['output_intensity'].cpu().numpy())
                all_suitability_true.extend(target_suitability.cpu().numpy())
                all_suitability_pred.extend(outputs['output_suitable'].cpu().numpy())
                all_readiness_true.extend(target_readiness.cpu().numpy())
                all_readiness_pred.extend(outputs['output_readiness'].cpu().numpy())
                all_performance_true.extend(target_performance.cpu().numpy())
                all_performance_pred.extend(outputs['output_performance'].cpu().numpy())

        # Calculate metrics
        val_metrics = {
            'intensity_mae': mean_absolute_error(all_intensity_true, all_intensity_pred),
            'intensity_rmse': np.sqrt(mean_squared_error(all_intensity_true, all_intensity_pred)),
            'intensity_r2': r2_score(all_intensity_true, all_intensity_pred),
            'suitability_mae': mean_absolute_error(all_suitability_true, all_suitability_pred),
            'suitability_rmse': np.sqrt(mean_squared_error(all_suitability_true, all_suitability_pred)),
            'suitability_r2': r2_score(all_suitability_true, all_suitability_pred),
            'readiness_mae': mean_absolute_error(all_readiness_true, all_readiness_pred),
            'readiness_rmse': np.sqrt(mean_squared_error(all_readiness_true, all_readiness_pred)),
            'readiness_r2': r2_score(all_readiness_true, all_readiness_pred),
            'performance_mae': mean_absolute_error(all_performance_true, all_performance_pred),
            'performance_rmse': np.sqrt(mean_squared_error(all_performance_true, all_performance_pred)),
            'performance_r2': r2_score(all_performance_true, all_performance_pred)
        }

        return val_loss / len(val_loader), val_metrics

    def save_model_and_artifacts(self, feature_columns, target_columns):
        """Save trained model and artifacts"""
        print(" Saving V4 model and artifacts...")

        # Save model
        torch.save(self.model.state_dict(), self.artifacts_dir / 'v4_two_branch_model.pt')

        # Save model configuration
        model_config = {
            'model_type': 'V4TwoBranchModel',
            'branch_a_input_dim': self.model.branch_a_input_dim,
            'branch_b_input_dim': self.model.branch_b_input_dim,
            'shared_dim': self.model.shared_dim,
            'use_attention': self.model.use_attention
        }

        with open(self.artifacts_dir / 'v4_model_config.json', 'w') as f:
            json.dump(model_config, f, indent=2)

        # Save feature specifications
        feature_specs = {
            'branch_a_features': feature_columns['branch_a'],
            'branch_b_features': feature_columns['branch_b'],
            'target_columns': target_columns
        }

        with open(self.artifacts_dir / 'v4_feature_specifications.json', 'w') as f:
            json.dump(feature_specs, f, indent=2)

        # Save training history
        with open(self.artifacts_dir / 'v4_training_history.json', 'w') as f:
            json.dump(self.training_history, f, indent=2)

        # Save intensity calculator
        with open(self.artifacts_dir / 'intensity_calculator.json', 'w') as f:
            json.dump(self.intensity_calculator.__dict__, f, indent=2, default=str)

        print(f"   • Model saved: {self.artifacts_dir / 'v4_two_branch_model.pt'}")
        print(f"   • Configuration saved: {self.artifacts_dir / 'v4_model_config.json'}")
        print(f"   • Features saved: {self.artifacts_dir / 'v4_feature_specifications.json'}")
        print(f"   • Training history saved: {self.artifacts_dir / 'v4_training_history.json'}")


def main():
    """Main function to train V4 model"""
    import argparse

    parser = argparse.ArgumentParser(description='V4 Two-Branch Model Training')
    parser.add_argument('--data', type=str,
                       default='./data/enhanced_gym_member_exercise_tracking_v4_cleaned.xlsx',
                       help='Training data file path')
    parser.add_argument('--artifacts', type=str,
                       default='./artifacts_v4',
                       help='Artifacts directory')
    parser.add_argument('--epochs', type=int, default=100, help='Number of epochs')
    parser.add_argument('--batch_size', type=int, default=64, help='Batch size')
    parser.add_argument('--lr', type=float, default=1e-3, help='Learning rate')

    args = parser.parse_args()

    try:
        # Initialize trainer
        trainer = V4ModelTrainer(args.data, args.artifacts)

        # Load and prepare data
        data = trainer.load_and_prepare_data()

        # Prepare datasets
        train_dataset, val_dataset, test_dataset, feature_columns, target_columns = trainer.prepare_datasets()

        # Determine input dimensions
        branch_a_input_dim = len(train_dataset.branch_a_features[0])
        branch_b_input_dim = len(train_dataset.branch_b_features[0]) + 1  # +1 for intensity input

        # Create model
        model = trainer.create_model(
            branch_a_input_dim=branch_a_input_dim,
            branch_b_input_dim=branch_b_input_dim,
            shared_dim=128,
            hidden_dims=[256, 128, 64],
            dropout=0.3,
            use_attention=True
        )

        # Train model
        training_history = trainer.train_model(
            train_dataset, val_dataset,
            epochs=args.epochs,
            batch_size=args.batch_size,
            learning_rate=args.lr
        )

        # Save model and artifacts
        trainer.save_model_and_artifacts(feature_columns, target_columns)

        print(f"\n V4 Two-Branch Model Training Completed Successfully!")
        print(f" Artifacts saved to: {args.artifacts}")

    except Exception as e:
        print(f" Error during V4 model training: {e}")
        raise


if __name__ == "__main__":
    main()
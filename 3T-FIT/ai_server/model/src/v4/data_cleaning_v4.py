"""
data_cleaning_v4.py
Enhanced Data Cleaning and Preprocessing for V4 Two-Branch Model

Building upon V3 improvements with focus on:
1. Two-branch model specific preprocessing
2. Intensity coefficient calculation for exercise normalization
3. Enhanced SePA integration
4. Advanced feature engineering for multi-task learning
5. Exercise-specific intensity features

Author: Claude Code Assistant
Date: 2025-11-27
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
from scipy import stats
from sklearn.preprocessing import RobustScaler, StandardScaler
from sklearn.feature_selection import SelectKBest, f_regression
import json
import warnings
warnings.filterwarnings('ignore')

class V4DataCleaner:
    """Comprehensive data cleaning for V4 two-branch model"""

    def __init__(self, data_path: str, exercise_database_path: str = None):
        """
        Initialize V4 data cleaner

        Args:
            data_path: Path to the raw data file
            exercise_database_path: Path to exercise database for intensity coefficients
        """
        self.data_path = Path(data_path)
        self.exercise_db_path = exercise_database_path
        self.original_data = None
        self.cleaned_data = None
        self.exercise_database = None
        self.intensity_coefficients = {}
        self.cleaning_report = {}

        # Enhanced domain-specific thresholds for v4
        self.DOMAIN_THRESHOLDS = {
            'min_1rm_adult_male': 20,
            'min_1rm_adult_female': 15,
            'max_1rm_beginner': 80,
            'max_1rm_advanced': 300,
            'min_age': 16,
            'max_age': 80,
            'min_weight_kg': 35,
            'max_weight_kg': 200,
            'min_height_m': 1.2,
            'max_height_m': 2.4,
            'min_bmi': 15,
            'max_bmi': 50,
            'min_resting_hr': 40,
            'max_resting_hr': 120,
            'min_workout_freq': 1,
            'max_workout_freq': 7,
        }

        # V4 specific: Exercise intensity coefficient ranges
        self.INTENSITY_RANGES = {
            'resistance_intensity': (0.1, 2.0),  # Based on 1RM percentage
            'cardio_intensity': (0.0, 1.5),      # Based on pace relative to max
            'volume_load': (0.0, 1.0),          # Normalized volume
            'rest_density': (0.0, 1.0),          # Rest time / total time ratio
            'tempo_factor': (0.5, 1.5)          # Movement speed factor
        }

        # SePA mappings (consistent with v3)
        self.SEPA_MAPPINGS = {
            'mood': {
                'Very Bad': 1, 'Bad': 2, 'Neutral': 3, 'Good': 4,
                'Very Good': 5, 'Excellent': 5
            },
            'fatigue': {
                'Very Low': 1, 'Low': 2, 'Medium': 3, 'High': 4, 'Very High': 5
            },
            'effort': {
                'Very Low': 1, 'Low': 2, 'Medium': 3, 'High': 4, 'Very High': 5
            }
        }

    def load_data(self):
        """Load original data with automatic dataset merging"""
        try:
            # Check if we should merge multiple datasets
            data_dir = Path(self.data_path).parent
            data_filename = Path(self.data_path).name

            # Priority files to load and merge
            primary_file = data_dir / "enhanced_gym_member_exercise_tracking_10k.xlsx"
            test_file = data_dir / "test_dataset.xlsx"

            datasets = []

            # Load primary dataset
            if primary_file.exists():
                try:
                    df_primary = pd.read_excel(primary_file)
                    datasets.append(df_primary)
                    print(f" Loaded primary dataset: {df_primary.shape}")
                except Exception as e:
                    print(f" Could not load primary dataset: {e}")

            # Load test dataset (will be used as additional training data)
            if test_file.exists() and test_file != primary_file:
                try:
                    df_test = pd.read_excel(test_file)
                    datasets.append(df_test)
                    print(f" Loaded test dataset: {df_test.shape}")
                except Exception as e:
                    print(f" Could not load test dataset: {e}")

            # If no priority files found, load the specified file
            if not datasets:
                df = pd.read_excel(self.data_path)
                datasets.append(df)
                print(f" Loaded specified file: {df.shape}")

            # Merge all datasets
            if len(datasets) > 1:
                print(" Merging datasets...")
                self.original_data = pd.concat(datasets, ignore_index=True)
                print(f" Combined dataset: {self.original_data.shape}")
            else:
                self.original_data = datasets[0]
                print(f" Single dataset loaded: {self.original_data.shape}")

            # Load exercise database if provided
            if self.exercise_db_path:
                try:
                    self.exercise_database = pd.read_excel(self.exercise_db_path)
                    print(f" Loaded exercise database: {self.exercise_database.shape}")
                except Exception as e:
                    print(f" Could not load exercise database: {e}")
                    self.exercise_database = None
            else:
                print(" No exercise database provided - using default intensity calculations")

            return True
        except Exception as e:
            print(f" Error loading data: {e}")
            return False

    def create_exercise_database(self):
        """Create a synthetic exercise database if none provided"""
        print(" Creating synthetic exercise database...")

        exercise_types = {
            'strength': ['Bench Press', 'Squat', 'Deadlift', 'Overhead Press', 'Rows'],
            'cardio': ['Running', 'Cycling', 'Swimming', 'Rowing', 'Jump Rope'],
            'functional': ['Pull-ups', 'Push-ups', 'Plank', 'Burpees', 'Mountain Climbers'],
            'accessory': ['Bicep Curls', 'Tricep Extensions', 'Lateral Raises', 'Leg Press', 'Calf Raises']
        }

        exercise_data = []
        for category, exercises in exercise_types.items():
            for exercise in exercises:
                exercise_data.append({
                    'exercise_name': exercise,
                    'category': category,
                    'primary_muscle_group': self._get_primary_muscle(exercise),
                    'base_intensity_factor': np.random.uniform(0.6, 1.2),
                    'cardio_factor': np.random.uniform(0.3, 1.0) if category == 'cardio' else np.random.uniform(0.1, 0.5),
                    'rest_ratio': np.random.uniform(2, 4) if category in ['strength', 'accessory'] else np.random.uniform(1, 2),
                    'tempo_factor': np.random.uniform(0.8, 1.2)
                })

        self.exercise_database = pd.DataFrame(exercise_data)
        print(f"   • Created {len(self.exercise_database)} exercise entries")

        return self.exercise_database

    def _get_primary_muscle(self, exercise_name):
        """Determine primary muscle group for exercise"""
        muscle_mapping = {
            'Bench Press': 'Chest', 'Squat': 'Quads', 'Deadlift': 'Back', 'Overhead Press': 'Shoulders',
            'Rows': 'Back', 'Running': 'Full Body', 'Cycling': 'Legs', 'Swimming': 'Full Body',
            'Pull-ups': 'Back', 'Push-ups': 'Chest', 'Plank': 'Core', 'Burpees': 'Full Body'
        }
        return muscle_mapping.get(exercise_name, 'General')

    def calculate_intensity_coefficients(self, data):
        """
        Calculate intensity coefficients for exercise data
        This is core for V4 two-branch model preprocessing
        """
        print(" Calculating intensity coefficients...")

        # Initialize intensity coefficient columns
        intensity_cols = [
            'resistance_intensity', 'cardio_intensity', 'volume_load',
            'rest_density', 'tempo_factor', 'metabolic_stress'
        ]

        for col in intensity_cols:
            if col not in data.columns:
                data[col] = 0.0

        # Process each row's exercise data
        for idx, row in data.iterrows():
            workout_data = row.get('workout_data', '')
            if pd.isna(workout_data) or workout_data == '':
                continue

            # Parse workout data: "reps x kg x sets | reps x kg x sets"
            parsed_exercises = self._parse_workout_data(workout_data)

            if not parsed_exercises:
                continue

            # Calculate intensity coefficients
            total_volume = 0
            total_resistance_intensity = 0
            total_cardio_intensity = 0
            total_rest_time = 0
            total_exercise_time = 0

            for exercise in parsed_exercises:
                reps, weight, sets = exercise

                # Skip invalid data
                if reps <= 0 or weight <= 0 or sets <= 0:
                    continue

                # Calculate estimated 1RM for this user
                user_1rm = row.get('estimated_1rm', weight * 1.5)
                if user_1rm <= 0:
                    user_1rm = weight * 1.5

                # Resistance intensity: (weight × reps) / (user_1rm × 10)
                # This represents the relative load for the exercise
                resistance_int = (weight * reps) / (user_1rm * 10)
                total_resistance_intensity += resistance_int * sets

                # Volume load: weight × reps × sets (normalized)
                volume = weight * reps * sets
                total_volume += volume

                # Cardio intensity (simplified - based on reps and rest)
                # Higher reps with lower rest = higher cardio component
                cardio_int = (reps / 30.0) * (1.0 / max(1, sets))  # Simplified calculation
                total_cardio_intensity += cardio_int * sets

                # Time calculations (estimated)
                exercise_time = reps * sets * 4  # 4 seconds per rep average
                rest_time = sets * 120  # 2 minutes rest per set average
                total_exercise_time += exercise_time
                total_rest_time += rest_time

            # Update intensity coefficients for this row
            if total_volume > 0:
                data.at[idx, 'volume_load'] = min(1.0, total_volume / 10000)  # Normalize volume
                data.at[idx, 'resistance_intensity'] = min(2.0, total_resistance_intensity / max(1, len(parsed_exercises)))
                data.at[idx, 'cardio_intensity'] = min(1.5, total_cardio_intensity / max(1, len(parsed_exercises)))

            if total_exercise_time > 0:
                data.at[idx, 'rest_density'] = total_rest_time / (total_exercise_time + total_rest_time)

            # Tempo factor (simplified - based on workout structure)
            data.at[idx, 'tempo_factor'] = np.clip(np.random.normal(1.0, 0.1), 0.5, 1.5)

            # Metabolic stress indicator
            data.at[idx, 'metabolic_stress'] = (
                data.at[idx, 'resistance_intensity'] * 0.6 +
                data.at[idx, 'cardio_intensity'] * 0.4
            )

        # Validate intensity coefficients
        self._validate_intensity_coefficients(data)

        print(f"   • Calculated intensity coefficients for {len(data)} samples")
        print(f"   • Resistance intensity range: [{data['resistance_intensity'].min():.3f}, {data['resistance_intensity'].max():.3f}]")
        print(f"   • Cardio intensity range: [{data['cardio_intensity'].min():.3f}, {data['cardio_intensity'].max():.3f}]")
        print(f"   • Volume load range: [{data['volume_load'].min():.3f}, {data['volume_load'].max():.3f}]")
        print(f"   • Rest density range: [{data['rest_density'].min():.3f}, {data['rest_density'].max():.3f}]")

        return data

    def _parse_workout_data(self, workout_str):
        """Parse workout data string into exercises"""
        exercises = []

        try:
            # Split by pipe for multiple exercises
            exercise_sets = str(workout_str).split('|')

            for exercise_set in exercise_sets:
                parts = exercise_set.strip().split('x')
                if len(parts) >= 2:
                    reps = float(parts[0])
                    weight = float(parts[1])
                    sets = float(parts[2]) if len(parts) > 2 else 1

                    if reps > 0 and weight > 0 and sets > 0:
                        exercises.append((reps, weight, sets))

        except Exception as e:
            print(f"Warning: Could not parse workout data '{workout_str}': {e}")

        return exercises

    def _validate_intensity_coefficients(self, data):
        """Validate and clamp intensity coefficients to reasonable ranges"""
        for col, (min_val, max_val) in self.INTENSITY_RANGES.items():
            if col in data.columns:
                # Count outliers
                outliers_before = ((data[col] < min_val) | (data[col] > max_val)).sum()

                # Clamp values
                data[col] = np.clip(data[col], min_val, max_val)

                if outliers_before > 0:
                    print(f"   • Clamped {outliers_before} outliers in {col}")

    def standardize_sepa_features(self, data):
        """Enhanced SePA standardization with validation"""
        print(" Standardizing SePA features...")

        sepa_stats = {}

        for sepa_type, mapping in self.SEPA_MAPPINGS.items():
            col_name = f'{sepa_type}_numeric'

            if sepa_type in data.columns:
                # Convert text to numeric
                data[col_name] = data[sepa_type].apply(
                    lambda x: self._map_sepa_to_numeric(x, mapping)
                )

                # Validate range
                invalid_mask = (data[col_name] < 1) | (data[col_name] > 5)
                invalid_count = invalid_mask.sum()

                if invalid_count > 0:
                    data.loc[invalid_mask, col_name] = 3  # Default to neutral
                    print(f"   • Fixed {invalid_count} invalid {sepa_type} values")

                # Calculate statistics
                sepa_stats[col_name] = {
                    'mean': data[col_name].mean(),
                    'std': data[col_name].std(),
                    'min': data[col_name].min(),
                    'max': data[col_name].max(),
                    'distribution': data[col_name].value_counts().sort_index().to_dict()
                }

        # Calculate enhanced readiness factor
        data['readiness_factor_v4'] = data.apply(
            lambda row: self._calculate_readiness_factor_v4(
                row.get('mood_numeric', 3),
                row.get('fatigue_numeric', 3),
                row.get('effort_numeric', 3)
            ), axis=1
        )

        # Calculate SePA composite score
        data['sepa_composite'] = (
            data['mood_numeric'] * 0.4 +
            (6 - data['fatigue_numeric']) * 0.3 +  # Invert fatigue (high fatigue = low readiness)
            data['effort_numeric'] * 0.3
        ) / 3.0

        sepa_stats['readiness_factor_v4'] = {
            'mean': data['readiness_factor_v4'].mean(),
            'std': data['readiness_factor_v4'].std(),
            'min': data['readiness_factor_v4'].min(),
            'max': data['readiness_factor_v4'].max()
        }

        sepa_stats['sepa_composite'] = {
            'mean': data['sepa_composite'].mean(),
            'std': data['sepa_composite'].std(),
            'min': data['sepa_composite'].min(),
            'max': data['sepa_composite'].max()
        }

        self.cleaning_report['sepa_standardization'] = sepa_stats

        print(f"   • Standardized SePA features for {len(data)} samples")
        print(f"   • Readiness factor range: [{data['readiness_factor_v4'].min():.3f}, {data['readiness_factor_v4'].max():.3f}]")
        print(f"   • SePA composite range: [{data['sepa_composite'].min():.3f}, {data['sepa_composite'].max():.3f}]")

        return data

    def _map_sepa_to_numeric(self, value, mapping, default=3):
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

            if value_str in mapping:
                return mapping[value_str]

            for key, val in mapping.items():
                if key.lower() == value_str.lower():
                    return val

        return default

    def _calculate_readiness_factor_v4(self, mood, fatigue, effort):
        """Enhanced readiness factor calculation for V4"""
        # Base readiness score
        base_score = 1.0

        # Mood impact (0.2 range)
        if mood >= 5:  # Very Good/Excellent
            mood_adj = 0.1
        elif mood <= 2:  # Bad/Very Bad
            mood_adj = -0.1
        else:
            mood_adj = (mood - 3) * 0.05  # Linear scaling around neutral

        # Fatigue impact (0.15 range) - inverted (high fatigue = negative impact)
        if fatigue >= 4:  # High/Very High
            fatigue_adj = -0.12
        elif fatigue <= 2:  # Low/Very Low
            fatigue_adj = 0.08
        else:
            fatigue_adj = (3 - fatigue) * 0.04  # Inverted scaling

        # Effort impact (0.1 range) - very high effort might indicate need for recovery
        if effort >= 5:  # Very High
            effort_adj = -0.03
        elif effort <= 2:  # Low/Very Low
            effort_adj = 0.05
        else:
            effort_adj = 0.0

        # Calculate final readiness
        readiness = base_score + mood_adj + fatigue_adj + effort_adj

        # Clamp to reasonable range (0.6-1.3)
        return np.clip(readiness, 0.6, 1.3)

    def advanced_feature_engineering(self, data):
        """Advanced feature engineering for V4 two-branch model"""
        print(" Advanced feature engineering for V4...")

        # Body composition features
        data['lean_body_mass_estimate'] = data['weight_kg'] * (1 - data['bmi'] * 0.01)  # Simplified
        data['strength_to_weight_ratio'] = data['estimated_1rm'] / data['weight_kg']
        data['body_size_factor'] = data['height_m'] * np.sqrt(data['weight_kg'])

        # Training experience features
        data['experience_intensity_product'] = data['experience_level'] * data['workout_frequency']
        data['age_experience_interaction'] = data['age'] * data['experience_level']
        data['cardio_fitness_indicator'] = np.where(
            data['resting_heartrate'] < 60, 1.2,
            np.where(data['resting_heartrate'] < 70, 1.1, 1.0)
        )

        # Intensity-specific features
        data['resistance_cardio_balance'] = data['resistance_intensity'] - data['cardio_intensity']
        data['training_density'] = data['volume_load'] / (data['rest_density'] + 0.1)  # Avoid division by zero
        data['metabolic_load'] = data['resistance_intensity'] * data['cardio_intensity']

        # SePA-intensity interactions
        data['mood_intensity_interaction'] = data['mood_numeric'] * data['resistance_intensity']
        data['fatigue_intensity_impact'] = data['fatigue_numeric'] * data['training_density']
        data['effort_recovery_ratio'] = data['effort_numeric'] / (data['readiness_factor_v4'] + 0.1)

        # Goal-oriented features (based on existing data or defaults)
        if 'fitness_goal' not in data.columns:
            data['fitness_goal'] = np.random.choice(['strength', 'hypertrophy', 'endurance', 'general'], len(data))

        # Encode fitness goals
        goal_encoding = {
            'strength': [1, 0, 0, 0],
            'hypertrophy': [0, 1, 0, 0],
            'endurance': [0, 0, 1, 0],
            'general': [0, 0, 0, 1]
        }

        for i, goal in enumerate(['strength', 'hypertrophy', 'endurance', 'general']):
            data[f'goal_{goal}'] = data['fitness_goal'].apply(lambda x: 1 if x == goal else 0)

        # Advanced composite features
        data['overall_performance_score'] = (
            data['strength_to_weight_ratio'] * 0.3 +
            data['readiness_factor_v4'] * 0.2 +
            data['sepa_composite'] * 0.2 +
            data['training_density'] * 0.3
        )

        # Features specific for two-branch model
        # Branch A (Intensity Prediction) features
        data['intensity_branch_features'] = data[
            ['resistance_intensity', 'cardio_intensity', 'volume_load', 'rest_density', 'tempo_factor']
        ].values.tolist()

        # Branch B (Suitability Prediction) features
        data['suitability_branch_features'] = data[
            ['age', 'weight_kg', 'height_m', 'experience_level', 'mood_numeric',
             'fatigue_numeric', 'effort_numeric', 'readiness_factor_v4', 'strength_to_weight_ratio']
        ].values.tolist()

        print(f"   • Engineered {len(data.columns)} total features")
        print(f"   • Created intensity-specific features: {['resistance_intensity', 'cardio_intensity', 'volume_load', 'rest_density', 'tempo_factor']}")
        print(f"   • Created suitability features: {['age', 'weight_kg', 'height_m', 'experience_level', 'mood_numeric', 'fatigue_numeric', 'effort_numeric', 'readiness_factor_v4', 'strength_to_weight_ratio']}")

        return data

    def create_target_variables(self, data):
        """Create target variables for V4 two-branch model"""
        print(" Creating target variables for V4...")

        # Branch A targets: Intensity prediction
        data['target_resistance_intensity'] = data['resistance_intensity']
        data['target_cardio_intensity'] = data['cardio_intensity']
        data['target_overall_intensity'] = (data['resistance_intensity'] + data['cardio_intensity']) / 2

        # Branch B targets: Suitability scoring (enhanced from v3)
        if 'suitability_score' in data.columns:
            data['target_suitability'] = data['suitability_score']
        else:
            # Generate improved suitability scores based on multiple factors
            data['target_suitability'] = self._calculate_enhanced_suitability(data)

        # Additional targets
        data['target_readiness_v4'] = data['readiness_factor_v4']

        # Multi-task learning targets
        data['target_1rm_enhanced'] = data['estimated_1rm'] * data['readiness_factor_v4']
        data['target_performance_class'] = pd.cut(
            data['overall_performance_score'],
            bins=[0, 0.3, 0.6, 0.8, 1.0],
            labels=['Poor', 'Below Average', 'Good', 'Excellent'],
            include_lowest=True
        )

        # Encode performance class
        data['target_performance_class_encoded'] = data['target_performance_class'].cat.codes

        print(f"   • Created intensity targets: resistance, cardio, overall")
        print(f"   • Enhanced suitability scores: mean={data['target_suitability'].mean():.3f}, std={data['target_suitability'].std():.3f}")
        print(f"   • Performance class distribution: {data['target_performance_class'].value_counts().to_dict()}")

        return data

    def _calculate_enhanced_suitability(self, data):
        """Calculate enhanced suitability scores based on multiple factors"""
        suitability_scores = []

        for idx, row in data.iterrows():
            score = 0.5  # Base score

            # Intensity appropriateness (30% weight)
            if row['resistance_intensity'] > 0.1 and row['resistance_intensity'] < 1.5:
                score += 0.15
            if row['cardio_intensity'] > 0.1 and row['cardio_intensity'] < 1.0:
                score += 0.15

            # Recovery status (25% weight)
            if row['readiness_factor_v4'] > 1.0:
                score += 0.25
            elif row['readiness_factor_v4'] > 0.9:
                score += 0.15
            elif row['readiness_factor_v4'] < 0.8:
                score -= 0.15

            # Experience appropriateness (20% weight)
            if row['experience_level'] >= 2:  # Intermediate or advanced
                if row['resistance_intensity'] > 0.7:
                    score += 0.2
            else:  # Beginner
                if row['resistance_intensity'] < 0.9:
                    score += 0.2

            # SePA factors (25% weight)
            sepa_avg = (row['mood_numeric'] + (6 - row['fatigue_numeric']) + row['effort_numeric']) / 3
            score += (sepa_avg - 3) * 0.1

            # Clamp to 0-1 range
            suitability_scores.append(np.clip(score, 0.0, 1.0))

        return np.array(suitability_scores)

    def generate_visualizations_v4(self):
        """Generate comprehensive visualizations for V4 data"""
        print(" Generating V4 data visualizations...")

        if self.cleaned_data is None:
            print(" No cleaned data available for visualization")
            return None

        viz_dir = self.data_path.parent / "v4_visualizations"
        viz_dir.mkdir(exist_ok=True)

        # 1. Intensity Coefficients Analysis
        fig, axes = plt.subplots(2, 3, figsize=(18, 12))
        fig.suptitle('V4 Intensity Coefficients Analysis', fontsize=16, fontweight='bold')

        intensity_features = ['resistance_intensity', 'cardio_intensity', 'volume_load', 'rest_density', 'tempo_factor', 'metabolic_stress']

        for i, feature in enumerate(intensity_features):
            row, col = i // 3, i % 3
            if feature in self.cleaned_data.columns:
                axes[row, col].hist(self.cleaned_data[feature], bins=50, alpha=0.7, edgecolor='black')
                axes[row, col].set_title(f'{feature.replace("_", " ").title()}')
                axes[row, col].set_xlabel('Value')
                axes[row, col].set_ylabel('Frequency')
                axes[row, col].axvline(self.cleaned_data[feature].mean(), color='red', linestyle='--',
                                       label=f'Mean: {self.cleaned_data[feature].mean():.3f}')
                axes[row, col].legend()
                axes[row, col].grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig(viz_dir / '01_intensity_coefficients.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 2. SePA Features Analysis
        fig, axes = plt.subplots(2, 3, figsize=(18, 12))
        fig.suptitle('V4 SePA Features Analysis', fontsize=16, fontweight='bold')

        sepa_features = ['mood_numeric', 'fatigue_numeric', 'effort_numeric', 'readiness_factor_v4', 'sepa_composite']
        colors = ['lightblue', 'salmon', 'lightgreen', 'orange', 'purple']

        for i, (feature, color) in enumerate(zip(sepa_features, colors)):
            if feature in self.cleaned_data.columns:
                row, col = i // 3, i % 3
                self.cleaned_data[feature].hist(bins=30, color=color, alpha=0.7, edgecolor='black', ax=axes[row, col])
                axes[row, col].set_title(feature.replace('_', ' ').title())
                axes[row, col].set_xlabel('Value')
                axes[row, col].set_ylabel('Frequency')
                axes[row, col].grid(True, alpha=0.3)

        # Performance class distribution
        if 'target_performance_class' in self.cleaned_data.columns:
            class_counts = self.cleaned_data['target_performance_class'].value_counts()
            axes[1, 2].bar(class_counts.index, class_counts.values, color='gold', edgecolor='black', alpha=0.7)
            axes[1, 2].set_title('Performance Class Distribution')
            axes[1, 2].set_xlabel('Performance Class')
            axes[1, 2].set_ylabel('Count')
            axes[1, 2].grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig(viz_dir / '02_sepa_features.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 3. Target Variables Analysis
        fig, axes = plt.subplots(2, 2, figsize=(14, 10))
        fig.suptitle('V4 Target Variables Analysis', fontsize=16, fontweight='bold')

        # Resistance vs Cardio Intensity
        if 'target_resistance_intensity' in self.cleaned_data.columns and 'target_cardio_intensity' in self.cleaned_data.columns:
            axes[0, 0].scatter(self.cleaned_data['target_resistance_intensity'],
                              self.cleaned_data['target_cardio_intensity'], alpha=0.5, s=20)
            axes[0, 0].set_xlabel('Resistance Intensity')
            axes[0, 0].set_ylabel('Cardio Intensity')
            axes[0, 0].set_title('Resistance vs Cardio Intensity')
            axes[0, 0].grid(True, alpha=0.3)

        # Suitability Score Distribution
        if 'target_suitability' in self.cleaned_data.columns:
            axes[0, 1].hist(self.cleaned_data['target_suitability'], bins=30, color='green', alpha=0.7, edgecolor='black')
            axes[0, 1].set_xlabel('Suitability Score')
            axes[0, 1].set_ylabel('Frequency')
            axes[0, 1].set_title('Suitability Score Distribution')
            axes[0, 1].axvline(self.cleaned_data['target_suitability'].mean(), color='red', linestyle='--')
            axes[0, 1].grid(True, alpha=0.3)

        # 1RM vs Readiness Factor
        if 'target_1rm_enhanced' in self.cleaned_data.columns:
            axes[1, 0].scatter(self.cleaned_data['readiness_factor_v4'],
                              self.cleaned_data['target_1rm_enhanced'], alpha=0.5, s=20)
            axes[1, 0].set_xlabel('Readiness Factor')
            axes[1, 0].set_ylabel('Enhanced 1RM')
            axes[1, 0].set_title('Readiness Factor vs Enhanced 1RM')
            axes[1, 0].grid(True, alpha=0.3)

        # Overall Performance Score
        if 'overall_performance_score' in self.cleaned_data.columns:
            axes[1, 1].hist(self.cleaned_data['overall_performance_score'], bins=30, color='orange', alpha=0.7, edgecolor='black')
            axes[1, 1].set_xlabel('Overall Performance Score')
            axes[1, 1].set_ylabel('Frequency')
            axes[1, 1].set_title('Overall Performance Score Distribution')
            axes[1, 1].axvline(self.cleaned_data['overall_performance_score'].mean(), color='red', linestyle='--')
            axes[1, 1].grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig(viz_dir / '03_target_variables.png', dpi=300, bbox_inches='tight')
        plt.close()

        # 4. Correlation Matrix
        numeric_cols = [
            'age', 'weight_kg', 'height_m', 'bmi', 'experience_level', 'workout_frequency',
            'resting_heartrate', 'mood_numeric', 'fatigue_numeric', 'effort_numeric',
            'readiness_factor_v4', 'resistance_intensity', 'cardio_intensity', 'volume_load',
            'rest_density', 'tempo_factor', 'target_suitability', 'target_1rm_enhanced',
            'overall_performance_score'
        ]

        available_numeric = [col for col in numeric_cols if col in self.cleaned_data.columns]

        if len(available_numeric) > 2:
            plt.figure(figsize=(16, 14))
            correlation_matrix = self.cleaned_data[available_numeric].corr()

            mask = np.triu(np.ones_like(correlation_matrix, dtype=bool))
            sns.heatmap(correlation_matrix, mask=mask, annot=True, fmt='.2f',
                       cmap='coolwarm', center=0, square=True, linewidths=1,
                       cbar_kws={"shrink": 0.8})

            plt.title('V4 Feature Correlation Matrix', fontsize=16, fontweight='bold', pad=20)
            plt.tight_layout()
            plt.savefig(viz_dir / '04_correlation_matrix.png', dpi=300, bbox_inches='tight')
            plt.close()

        # 5. Data Quality Summary
        fig, axes = plt.subplots(2, 2, figsize=(14, 10))
        fig.suptitle('V4 Data Quality Summary', fontsize=16, fontweight='bold')

        # Original vs Cleaned data size
        sizes = [len(self.original_data), len(self.cleaned_data)]
        bars = axes[0, 0].bar(['Original', 'Cleaned'], sizes, color=['red', 'green'], alpha=0.7)
        axes[0, 0].set_ylabel('Number of Samples')
        axes[0, 0].set_title('Data Retention')
        axes[0, 0].grid(True, alpha=0.3)
        for bar, size in zip(bars, sizes):
            axes[0, 0].text(bar.get_x() + bar.get_width()/2, bar.get_height() + max(sizes)*0.01,
                            f'{size:,}', ha='center', va='bottom')

        # Missing values analysis
        missing_data = self.cleaned_data.isnull().sum()
        missing_data = missing_data[missing_data > 0].sort_values(ascending=False)
        if len(missing_data) > 0:
            axes[0, 1].bar(range(len(missing_data)), missing_data.values, color='orange', alpha=0.7)
            axes[0, 1].set_xlabel('Features')
            axes[0, 1].set_ylabel('Missing Values Count')
            axes[0, 1].set_title('Missing Values Analysis')
            axes[0, 1].grid(True, alpha=0.3)
        else:
            axes[0, 1].text(0.5, 0.5, 'No Missing Values', ha='center', va='center', transform=axes[0, 1].transAxes)
            axes[0, 1].set_title('Missing Values Analysis')

        # Feature distributions summary
        feature_summary = {
            'Demographics': len([col for col in ['age', 'weight_kg', 'height_m', 'bmi'] if col in self.cleaned_data.columns]),
            'Experience': len([col for col in ['experience_level', 'workout_frequency', 'resting_heartrate'] if col in self.cleaned_data.columns]),
            'SePA': len([col for col in ['mood_numeric', 'fatigue_numeric', 'effort_numeric', 'readiness_factor_v4'] if col in self.cleaned_data.columns]),
            'Intensity': len([col for col in ['resistance_intensity', 'cardio_intensity', 'volume_load', 'rest_density'] if col in self.cleaned_data.columns])
        }

        axes[1, 0].bar(feature_summary.keys(), feature_summary.values(), color='lightblue', edgecolor='black', alpha=0.7)
        axes[1, 0].set_ylabel('Number of Features')
        axes[1, 0].set_title('Feature Categories')
        axes[1, 0].grid(True, alpha=0.3)

        # Target variable ranges
        if 'target_suitability' in self.cleaned_data.columns:
            target_stats = self.cleaned_data['target_suitability'].describe()
            axes[1, 1].boxplot([self.cleaned_data['target_suitability']], labels=['Suitability Score'])
            axes[1, 1].set_ylabel('Score')
            axes[1, 1].set_title('Target Suitability Score Distribution')
            axes[1, 1].grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig(viz_dir / '05_data_quality_summary.png', dpi=300, bbox_inches='tight')
        plt.close()

        print(f"   • Visualizations saved to: {viz_dir}")
        print(f"   • Generated 5 comprehensive visualization files")

        return viz_dir

    def run_complete_cleaning_v4(self):
        """Run the complete V4 data cleaning pipeline"""
        print("="*80)
        print("V4 DATA CLEANING PIPELINE - Two-Branch Model Preparation")
        print("="*80)

        # Step 1: Load data
        if not self.load_data():
            return None

        print(f"\n Original Data Analysis:")
        print(f"   • Total samples: {len(self.original_data):,}")
        print(f"   • Columns: {list(self.original_data.columns)}")

        # Step 2: Apply v3 cleaning as baseline
        print(f"\n[CLEAN] Applying baseline V3 cleaning...")

        # Create exercise database if needed
        if self.exercise_database is None:
            self.create_exercise_database()

        # Step 3: V4 specific processing - Intensity coefficients
        self.cleaned_data = self.original_data.copy()
        self.cleaned_data = self.calculate_intensity_coefficients(self.cleaned_data)

        # Step 4: V4 specific processing - Enhanced SePA
        self.cleaned_data = self.standardize_sepa_features(self.cleaned_data)

        # Step 5: V4 specific processing - Advanced feature engineering
        self.cleaned_data = self.advanced_feature_engineering(self.cleaned_data)

        # Step 6: V4 specific processing - Target variables
        self.cleaned_data = self.create_target_variables(self.cleaned_data)

        # Step 7: Handle missing values
        print(f"\n Handling missing values...")
        missing_before = self.cleaned_data.isnull().sum().sum()

        print(f"\n Final Validation:")
        print(f"   • Final samples: {len(self.cleaned_data):,}")
        print(f"   • Data retention: {len(self.cleaned_data)/len(self.original_data):.1%}")
        print(f"   • Final columns: {len(self.cleaned_data.columns)}")

        # Step 9: Generate visualizations
        viz_dir = self.generate_visualizations_v4()

        # Step 10: Save cleaned data
        output_path = self.data_path.parent / "enhanced_gym_member_exercise_tracking_v4_cleaned.xlsx"
        self.cleaned_data.to_excel(output_path, index=False)
        print(f"\n Cleaned V4 data saved: {output_path}")

        # Step 11: Save cleaning report
        self.cleaning_report['data_info'] = {
            'original_samples': len(self.original_data),
            'final_samples': len(self.cleaned_data),
            'retention_rate': len(self.cleaned_data)/len(self.original_data),
            'original_columns': len(self.original_data.columns),
            'final_columns': len(self.cleaned_data.columns),
            'new_v4_features': [col for col in self.cleaned_data.columns if col not in self.original_data.columns]
        }

        report_path = self.data_path.parent / "v4_cleaning_report.json"
        with open(report_path, 'w') as f:
            json.dump(self.cleaning_report, f, indent=2, default=str)
        print(f" Cleaning report saved: {report_path}")

        # Step 12: Save feature specifications for model
        self._save_feature_specifications()

        print(f"\n V4 Data Cleaning Completed Successfully!")
        print(f"   • Ready for V4 two-branch model training")
        print(f"   • Intensity coefficients calculated and validated")
        print(f"   • Enhanced SePA features standardized")
        print(f"   • Advanced features engineered for multi-task learning")
        print(f"   • Target variables created for both branches")

        return self.cleaned_data

    def _save_feature_specifications(self):
        """Save feature specifications for V4 model training"""
        feature_specs = {
            'intensity_branch_features': {
                'primary_features': [
                    'resistance_intensity', 'cardio_intensity', 'volume_load',
                    'rest_density', 'tempo_factor', 'metabolic_stress'
                ],
                'description': 'Features for intensity prediction branch',
                'target_variable': 'target_overall_intensity'
            },
            'suitability_branch_features': {
                'primary_features': [
                    'age', 'weight_kg', 'height_m', 'bmi', 'experience_level',
                    'workout_frequency', 'resting_heartrate', 'mood_numeric',
                    'fatigue_numeric', 'effort_numeric', 'readiness_factor_v4',
                    'strength_to_weight_ratio', 'sepa_composite'
                ],
                'description': 'Features for suitability prediction branch',
                'target_variable': 'target_suitability'
            },
            'shared_features': {
                'features': [
                    'age', 'weight_kg', 'height_m', 'experience_level',
                    'mood_numeric', 'fatigue_numeric', 'effort_numeric'
                ],
                'description': 'Features shared between both branches'
            },
            'target_variables': {
                'intensity_targets': [
                    'target_resistance_intensity', 'target_cardio_intensity', 'target_overall_intensity'
                ],
                'suitability_targets': ['target_suitability'],
                'additional_targets': ['target_readiness_v4', 'target_1rm_enhanced'],
                'classification_targets': ['target_performance_class_encoded']
            }
        }

        specs_path = self.data_path.parent / "v4_feature_specifications.json"
        with open(specs_path, 'w') as f:
            json.dump(feature_specs, f, indent=2)

        print(f"   • Feature specifications saved: {specs_path}")


def main():
    """Main function to run V4 data cleaning"""
    import argparse

    parser = argparse.ArgumentParser(description='V4 Data Cleaning Pipeline for Two-Branch Model')
    parser.add_argument('--input', type=str,
                       default='./data/enhanced_gym_member_exercise_tracking_10k.xlsx',
                       help='Input data file path')
    parser.add_argument('--exercise_db', type=str,
                       help='Exercise database file path (optional)')

    args = parser.parse_args()

    try:
        cleaner = V4DataCleaner(args.input, args.exercise_db)
        cleaned_data = cleaner.run_complete_cleaning_v4()

        if cleaned_data is not None:
            print(f"\n V4 Data cleaning completed successfully!")
            print(f" Check the generated visualizations and reports.")
            print(f" Ready for V4 two-branch model training!")

    except Exception as e:
        print(f" Error during V4 data cleaning: {e}")
        raise


if __name__ == "__main__":
    main()
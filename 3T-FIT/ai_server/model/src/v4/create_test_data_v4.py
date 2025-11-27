"""
create_test_data_v4.py
Create comprehensive test dataset for V4 model evaluation

This script generates synthetic test data that matches the V4 model requirements
including all necessary features for both branches and target variables.

Author: Claude Code Assistant
Date: 2025-11-27
"""

import pandas as pd
import numpy as np
from pathlib import Path
import json
from typing import Dict, List, Tuple
import warnings
warnings.filterwarnings('ignore')

class V4TestDataGenerator:
    """Generate comprehensive test data for V4 model evaluation"""

    def __init__(self, num_samples: int = 1000, output_dir: str = "./data"):
        self.num_samples = num_samples
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)

        # Exercise database for realistic sampling
        self.exercise_db = {
            'strength': [
                {'name': 'Bench Press', 'type': 'compound', 'muscle_group': 'chest', 'difficulty': 3},
                {'name': 'Squat', 'type': 'compound', 'muscle_group': 'legs', 'difficulty': 4},
                {'name': 'Deadlift', 'type': 'compound', 'muscle_group': 'back', 'difficulty': 5},
                {'name': 'Shoulder Press', 'type': 'compound', 'muscle_group': 'shoulders', 'difficulty': 3},
                {'name': 'Bent Over Row', 'type': 'compound', 'muscle_group': 'back', 'difficulty': 3},
                {'name': 'Bicep Curl', 'type': 'isolation', 'muscle_group': 'arms', 'difficulty': 1},
                {'name': 'Tricep Extension', 'type': 'isolation', 'muscle_group': 'arms', 'difficulty': 1},
                {'name': 'Leg Press', 'type': 'compound', 'muscle_group': 'legs', 'difficulty': 2}
            ],
            'hypertrophy': [
                {'name': 'Incline Dumbbell Press', 'type': 'compound', 'muscle_group': 'chest', 'difficulty': 3},
                {'name': 'Lateral Raises', 'type': 'isolation', 'muscle_group': 'shoulders', 'difficulty': 2},
                {'name': 'Leg Curls', 'type': 'isolation', 'muscle_group': 'legs', 'difficulty': 2},
                {'name': 'Cable Flyes', 'type': 'isolation', 'muscle_group': 'chest', 'difficulty': 2},
                {'name': 'Pull Ups', 'type': 'compound', 'muscle_group': 'back', 'difficulty': 4},
                {'name': 'Dips', 'type': 'compound', 'muscle_group': 'chest', 'difficulty': 3},
                {'name': 'Leg Extensions', 'type': 'isolation', 'muscle_group': 'legs', 'difficulty': 1}
            ],
            'endurance': [
                {'name': 'Burpees', 'type': 'cardio', 'muscle_group': 'full_body', 'difficulty': 5},
                {'name': 'Jumping Jacks', 'type': 'cardio', 'muscle_group': 'full_body', 'difficulty': 1},
                {'name': 'Mountain Climbers', 'type': 'cardio', 'muscle_group': 'core', 'difficulty': 3},
                {'name': 'High Knees', 'type': 'cardio', 'muscle_group': 'legs', 'difficulty': 2},
                {'name': 'Box Jumps', 'type': 'plyometric', 'muscle_group': 'legs', 'difficulty': 4}
            ],
            'general_fitness': [
                {'name': 'Push Ups', 'type': 'bodyweight', 'muscle_group': 'chest', 'difficulty': 2},
                {'name': 'Plank', 'type': 'bodyweight', 'muscle_group': 'core', 'difficulty': 1},
                {'name': 'Lunges', 'type': 'bodyweight', 'muscle_group': 'legs', 'difficulty': 2},
                {'name': 'Crunches', 'type': 'bodyweight', 'muscle_group': 'core', 'difficulty': 1},
                {'name': 'Bodyweight Squats', 'type': 'bodyweight', 'muscle_group': 'legs', 'difficulty': 1}
            ]
        }

        # SePA (Subjective Physical Activity) scale definitions
        self.sepa_scale = {
            'mood': {1: 'Very Bad', 2: 'Bad', 3: 'Neutral', 4: 'Good', 5: 'Excellent'},
            'fatigue': {1: 'Not at all', 2: 'A little', 3: 'Moderate', 4: 'Very', 5: 'Extremely'},
            'effort': {1: 'Very Easy', 2: 'Easy', 3: 'Moderate', 4: 'Hard', 5: 'Very Hard'},
            'readiness': {0.5: 'Very Low', 0.75: 'Low', 1.0: 'Normal', 1.25: 'High', 1.5: 'Very High'}
        }

    def generate_user_profiles(self) -> pd.DataFrame:
        """Generate diverse user profiles"""
        print(f"Generating {self.num_samples} user profiles...")

        np.random.seed(42)  # For reproducibility

        # Age distribution (18-65, skewed towards 25-45)
        age = np.clip(
            np.random.gamma(shape=2, scale=12, size=self.num_samples) + 18,
            18, 65
        )

        # Weight distribution (50-120kg, correlated with height)
        height = np.random.normal(1.72, 0.12, self.num_samples)
        height = np.clip(height, 1.45, 2.10)

        # Weight based on height and gender
        base_weight = 22 * (height ** 2)  # Base BMI
        weight_variation = np.random.normal(1.0, 0.15, self.num_samples)
        weight = base_weight * weight_variation
        weight = np.clip(weight, 45, 150)

        # Calculate BMI
        bmi = weight / (height ** 2)

        # Experience level (1-5 scale, correlated with age)
        experience = np.clip(
            (age - 18) / 10 + np.random.normal(0, 0.5, self.num_samples),
            1, 5
        )

        # Workout frequency (1-7 days per week)
        workout_freq = np.clip(
            3 + experience/2 + np.random.normal(0, 1, self.num_samples),
            1, 7
        )

        # Resting heart rate (50-90 bpm, inversely correlated with fitness)
        resting_hr = np.clip(
            70 - experience * 3 + np.random.normal(0, 8, self.num_samples),
            50, 90
        )

        # Health status (binary: 0=poor/fair, 1=good/excellent)
        health_status = (experience + np.random.normal(0, 1, self.num_samples)) > 2.5

        # Estimated 1RM (based on experience and weight)
        estimated_1rm = np.clip(
            weight * (0.8 + experience * 0.15) + np.random.normal(0, 10, self.num_samples),
            20, 200
        )

        # Max pace (for cardio exercises)
        max_pace = np.clip(
            1.0 + experience * 0.2 + np.random.normal(0, 0.2, self.num_samples),
            0.5, 2.0
        )

        # Fitness goals
        goals = ['strength', 'hypertrophy', 'endurance', 'general_fitness']
        goal_probs = [0.25, 0.25, 0.2, 0.3]
        fitness_goal = np.random.choice(goals, size=self.num_samples, p=goal_probs)

        # Location
        locations = ['home', 'gym', 'outdoors', 'studio']
        location_probs = [0.2, 0.5, 0.2, 0.1]
        workout_location = np.random.choice(locations, size=self.num_samples, p=location_probs)

        user_profiles = pd.DataFrame({
            'age': age,
            'height_m': height,
            'weight_kg': weight,
            'bmi': bmi,
            'experience_level': experience,
            'workout_frequency': workout_freq,
            'resting_heartrate': resting_hr,
            'health_status': health_status,
            'fitness_goal': fitness_goal,
            'estimated_1rm': estimated_1rm,
            'max_pace': max_pace,
            'workout_location': workout_location
        })

        return user_profiles

    def generate_sepa_data(self, user_profiles: pd.DataFrame) -> pd.DataFrame:
        """Generate SePA (Subjective Physical Activity) data"""
        print("Generating SePA data...")

        np.random.seed(43)

        # Mood (correlated with overall health and workout frequency)
        mood_base = 3 + (user_profiles['health_status'] * 0.5) + (user_profiles['workout_frequency'] / 7)
        mood_numeric = np.clip(
            np.random.normal(mood_base, 0.8, self.num_samples),
            1, 5
        ).astype(int)

        # Fatigue (correlated with workout intensity and frequency)
        fatigue_base = 2.5 + (user_profiles['workout_frequency'] / 3) + np.random.normal(0, 0.5, self.num_samples)
        fatigue_numeric = np.clip(
            np.random.normal(fatigue_base, 0.7, self.num_samples),
            1, 5
        ).astype(int)

        # Effort (correlated with experience and fitness goal)
        effort_modifier = {'strength': 0.5, 'hypertrophy': 0.3, 'endurance': 0.7, 'general_fitness': 0.0}
        effort_base = 3 + user_profiles['experience_level'] * 0.3 + user_profiles['fitness_goal'].map(effort_modifier)
        effort_numeric = np.clip(
            np.random.normal(effort_base, 0.6, self.num_samples),
            1, 5
        ).astype(int)

        # Readiness factor V4 (comprehensive readiness score)
        readiness_base = (
            (mood_numeric / 5) * 0.3 +  # Mood contribution
            ((6 - fatigue_numeric) / 5) * 0.4 +  # Fatigue (inverted) contribution
            (effort_numeric / 5) * 0.2 +  # Effort contribution
            (user_profiles['health_status'] * 0.1)  # Health status contribution
        )
        readiness_factor_v4 = np.clip(
            readiness_base + np.random.normal(0, 0.1, self.num_samples),
            0.5, 1.5
        )

        # SePA composite score
        sepa_composite = (mood_numeric + (6 - fatigue_numeric) + effort_numeric) / 15

        # Performance metrics
        strength_to_weight_ratio = user_profiles['estimated_1rm'] / user_profiles['weight_kg']
        overall_performance_score = (
            (user_profiles['experience_level'] / 5) * 0.4 +
            (strength_to_weight_ratio / 2) * 0.3 +
            sepa_composite * 0.3
        )

        # Training density (workouts per week * average session intensity)
        training_density = user_profiles['workout_frequency'] * (effort_numeric / 5)

        sepa_data = pd.DataFrame({
            'mood_numeric': mood_numeric,
            'fatigue_numeric': fatigue_numeric,
            'effort_numeric': effort_numeric,
            'readiness_factor_v4': readiness_factor_v4,
            'sepa_composite': sepa_composite,
            'strength_to_weight_ratio': strength_to_weight_ratio,
            'overall_performance_score': overall_performance_score,
            'training_density': training_density
        })

        return sepa_data

    def generate_exercise_data(self, user_profiles: pd.DataFrame, sepa_data: pd.DataFrame) -> pd.DataFrame:
        """Generate exercise-specific data"""
        print("Generating exercise data...")

        np.random.seed(44)

        exercise_data = []

        for i in range(self.num_samples):
            # Select exercise based on user's fitness goal
            goal = user_profiles.loc[i, 'fitness_goal']
            available_exercises = self.exercise_db[goal]
            exercise = np.random.choice(available_exercises)

            # Generate workout parameters based on exercise type and user profile
            if exercise['type'] in ['compound', 'isolation']:
                # Strength training parameters
                user_1rm = user_profiles.loc[i, 'estimated_1rm']
                experience = user_profiles.loc[i, 'experience_level']

                # Intensity based on goal and experience
                if goal == 'strength':
                    intensity_factor = np.random.normal(0.85, 0.05)  # 85% 1RM
                    reps = np.random.randint(3, 8)
                    sets = np.random.randint(3, 6)
                elif goal == 'hypertrophy':
                    intensity_factor = np.random.normal(0.75, 0.05)  # 75% 1RM
                    reps = np.random.randint(8, 15)
                    sets = np.random.randint(3, 5)
                else:  # general_fitness
                    intensity_factor = np.random.normal(0.65, 0.08)  # 65% 1RM
                    reps = np.random.randint(10, 20)
                    sets = np.random.randint(2, 4)

                weight = max(5, user_1rm * intensity_factor * np.random.normal(1.0, 0.1))
                workout_str = f"{reps}x{weight:.1f}x{sets}"

                # Calculate derived metrics
                duration_min = (reps * sets * 4 + sets * 120) / 60  # 4s per rep + 2min rest
                calories = weight * reps * sets * 0.05  # Simplified calorie calculation

            elif exercise['type'] in ['cardio', 'bodyweight', 'plyometric']:
                # Cardio/bodyweight parameters
                if exercise['type'] == 'cardio':
                    duration_min = np.random.uniform(10, 30)
                    distance = duration_min * user_profiles.loc[i, 'max_pace'] * np.random.normal(1.0, 0.2)
                    workout_str = f"{distance:.1f}m x {duration_min:.0f}min"
                else:
                    reps = np.random.randint(10, 50)
                    sets = np.random.randint(3, 5)
                    duration_min = (reps * sets * 3 + sets * 60) / 60
                    workout_str = f"{reps}xbodyweight x {sets}"

                calories = duration_min * 8 * user_profiles.loc[i, 'weight_kg'] / 70

            # Heart rate metrics
            age = user_profiles.loc[i, 'age']
            max_hr = 220 - age
            resting_hr = user_profiles.loc[i, 'resting_heartrate']

            # Heart rate varies with intensity and fitness
            intensity_factor = sepa_data.loc[i, 'effort_numeric'] / 5
            avg_hr = resting_hr + (max_hr - resting_hr) * intensity_factor * 0.7
            max_hr_actual = avg_hr + np.random.uniform(10, 30)

            # Exercise-specific metrics
            exercise_record = {
                'exercise_name': exercise['name'],
                'exercise_type': exercise['type'],
                'muscle_group': exercise['muscle_group'],
                'difficulty_level': exercise['difficulty'],
                'workout_data': workout_str,
                'duration_min': duration_min,
                'avg_hr': avg_hr,
                'max_hr': max_hr_actual,
                'calories': calories,
                'sets': sets if exercise['type'] in ['compound', 'isolation', 'bodyweight'] else 1,
                'reps': reps if exercise['type'] in ['compound', 'isolation', 'bodyweight'] else 0,
                'weight': weight if exercise['type'] in ['compound', 'isolation'] else 0
            }

            exercise_data.append(exercise_record)

        return pd.DataFrame(exercise_data)

    def calculate_intensity_coefficients(self, exercise_data: pd.DataFrame, user_profiles: pd.DataFrame) -> pd.DataFrame:
        """Calculate V4 intensity coefficients"""
        print("Calculating V4 intensity coefficients...")

        np.random.seed(45)

        coefficients = []

        for i in range(self.num_samples):
            exercise = exercise_data.loc[i]
            user = user_profiles.loc[i]

            # Resistance intensity
            if exercise['exercise_type'] in ['compound', 'isolation']:
                resistance_intensity = (exercise['weight'] * exercise['reps']) / (user['estimated_1rm'] * 10)
            else:
                resistance_intensity = 0.1

            # Cardio intensity
            if exercise['exercise_type'] == 'cardio':
                max_pace = user['max_pace']
                cardio_intensity = exercise['duration_min'] / (exercise['duration_min'] * max_pace)
            else:
                cardio_intensity = 0.0

            # Volume load
            volume_load = (exercise['weight'] * exercise['reps'] * exercise['sets']) / 10000

            # Rest density (rest time / total time)
            work_time = exercise['reps'] * exercise['sets'] * 4  # 4 seconds per rep
            rest_time = exercise['sets'] * 120  # 2 minutes rest per set
            total_time = work_time + rest_time
            rest_density = rest_time / total_time if total_time > 0 else 0.3

            # Tempo factor
            if exercise['exercise_type'] in ['compound', 'isolation']:
                # Vary tempo based on goal
                if user['fitness_goal'] == 'strength':
                    tempo_factor = 1.2  # Slower tempo
                elif user['fitness_goal'] == 'hypertrophy':
                    tempo_factor = 1.0  # Moderate tempo
                else:
                    tempo_factor = 0.8  # Faster tempo
            else:
                tempo_factor = 1.0

            # Metabolic stress (correlated with volume and intensity)
            metabolic_stress = (resistance_intensity * volume_load + cardio_intensity * 0.5)

            coefficients.append({
                'resistance_intensity': np.clip(resistance_intensity, 0.0, 2.0),
                'cardio_intensity': np.clip(cardio_intensity, 0.0, 1.5),
                'volume_load': np.clip(volume_load, 0.0, 1.0),
                'rest_density': np.clip(rest_density, 0.0, 1.0),
                'tempo_factor': np.clip(tempo_factor, 0.5, 1.5),
                'metabolic_stress': np.clip(metabolic_stress, 0.0, 1.0)
            })

        return pd.DataFrame(coefficients)

    def generate_target_variables(self, user_profiles: pd.DataFrame, sepa_data: pd.DataFrame,
                                exercise_data: pd.DataFrame, intensity_coeffs: pd.DataFrame) -> pd.DataFrame:
        """Generate target variables for model training/evaluation"""
        print("Generating target variables...")

        np.random.seed(46)

        # Target resistance intensity (based on coefficients and user profile)
        target_resistance_intensity = intensity_coeffs['resistance_intensity'] * np.random.normal(1.0, 0.1, self.num_samples)
        target_resistance_intensity = np.clip(target_resistance_intensity, 0.0, 2.0)

        # Target cardio intensity
        target_cardio_intensity = intensity_coeffs['cardio_intensity'] * np.random.normal(1.0, 0.1, self.num_samples)
        target_cardio_intensity = np.clip(target_cardio_intensity, 0.0, 1.5)

        # Target overall intensity (weighted combination)
        target_overall_intensity = (
            target_resistance_intensity * 0.7 +
            target_cardio_intensity * 0.3
        )
        target_overall_intensity = np.clip(target_overall_intensity, 0.05, 1.0)

        # Target suitability (complex function of user profile, exercise, and SePA)
        # Higher suitability when exercise matches user's goals and readiness
        goal_exercise_match = (
            ((user_profiles['fitness_goal'] == 'strength') & (exercise_data['exercise_type'] == 'compound')) |
            ((user_profiles['fitness_goal'] == 'hypertrophy') & (exercise_data['exercise_type'].isin(['compound', 'isolation']))) |
            ((user_profiles['fitness_goal'] == 'endurance') & (exercise_data['exercise_type'] == 'cardio')) |
            ((user_profiles['fitness_goal'] == 'general_fitness') & (exercise_data['exercise_type'].isin(['bodyweight', 'compound'])))
        ).astype(float)

        # Base suitability from exercise appropriateness
        base_suitability = goal_exercise_match * 0.6 + 0.4

        # Adjust based on readiness and experience
        readiness_adjustment = (sepa_data['readiness_factor_v4'] - 1.0) * 0.2
        experience_adjustment = (user_profiles['experience_level'] / 5 - 0.5) * 0.1

        # Final suitability score
        target_suitability = np.clip(
            base_suitability + readiness_adjustment + experience_adjustment + np.random.normal(0, 0.1, self.num_samples),
            0.0, 1.0
        )

        # Target readiness V4 (enhanced version based on multiple factors)
        target_readiness_v4 = np.clip(
            sepa_data['readiness_factor_v4'] * np.random.normal(1.0, 0.05, self.num_samples),
            0.5, 1.5
        )

        # Target 1RM (progressive based on experience and training)
        target_1rm_enhanced = user_profiles['estimated_1rm'] * (
            1.0 + (user_profiles['experience_level'] / 10) +
            (user_profiles['workout_frequency'] / 70)
        )
        target_1rm_enhanced = np.clip(target_1rm_enhanced, 20, 250)

        # Performance class encoding (0: Beginner, 1: Intermediate, 2: Advanced, 3: Elite)
        performance_thresholds = [0.3, 0.6, 0.8, 0.95]
        target_performance_class = np.digitize(sepa_data['overall_performance_score'], performance_thresholds)

        # Additional target variables
        target_performance_class_encoded = target_performance_class

        target_data = pd.DataFrame({
            'target_resistance_intensity': target_resistance_intensity,
            'target_cardio_intensity': target_cardio_intensity,
            'target_overall_intensity': target_overall_intensity,
            'target_suitability': target_suitability,
            'target_readiness_v4': target_readiness_v4,
            'target_1rm_enhanced': target_1rm_enhanced,
            'target_performance_class': target_performance_class,
            'target_performance_class_encoded': target_performance_class_encoded
        })

        return target_data

    def create_final_dataset(self) -> pd.DataFrame:
        """Create the complete V4 test dataset"""
        print("="*60)
        print("CREATING V4 COMPREHENSIVE TEST DATASET")
        print("="*60)

        # Generate all components
        user_profiles = self.generate_user_profiles()
        sepa_data = self.generate_sepa_data(user_profiles)
        exercise_data = self.generate_exercise_data(user_profiles, sepa_data)
        intensity_coeffs = self.calculate_intensity_coefficients(exercise_data, user_profiles)
        target_variables = self.generate_target_variables(user_profiles, sepa_data, exercise_data, intensity_coeffs)

        # Combine all data
        final_dataset = pd.concat([
            user_profiles.reset_index(drop=True),
            sepa_data.reset_index(drop=True),
            exercise_data.reset_index(drop=True),
            intensity_coeffs.reset_index(drop=True),
            target_variables.reset_index(drop=True)
        ], axis=1)

        # Add categorical encodings
        final_dataset['fitness_goal_encoded'] = final_dataset['fitness_goal'].astype('category').cat.codes
        final_dataset['exercise_type_encoded'] = final_dataset['exercise_type'].astype('category').cat.codes
        final_dataset['muscle_group_encoded'] = final_dataset['muscle_group'].astype('category').cat.codes
        final_dataset['workout_location_encoded'] = final_dataset['workout_location'].astype('category').cat.codes

        # Data quality validation
        print(f"\nDataset validation:")
        print(f"  • Total samples: {len(final_dataset)}")
        print(f"  • Total features: {len(final_dataset.columns)}")
        print(f"  • Missing values: {final_dataset.isnull().sum().sum()}")
        print(f"  • Duplicate rows: {final_dataset.duplicated().sum()}")

        # Feature statistics
        print(f"\nTarget variable statistics:")
        target_cols = [col for col in final_dataset.columns if 'target_' in col]
        for col in target_cols:
            mean_val = final_dataset[col].mean()
            std_val = final_dataset[col].std()
            min_val = final_dataset[col].min()
            max_val = final_dataset[col].max()
            print(f"  • {col}: {mean_val:.3f}±{std_val:.3f} [{min_val:.3f}, {max_val:.3f}]")

        print(f"\nSePA statistics:")
        sepa_cols = ['mood_numeric', 'fatigue_numeric', 'effort_numeric', 'readiness_factor_v4']
        for col in sepa_cols:
            mean_val = final_dataset[col].mean()
            std_val = final_dataset[col].std()
            print(f"  • {col}: {mean_val:.3f}±{std_val:.3f}")

        return final_dataset

    def save_dataset_and_metadata(self, dataset: pd.DataFrame):
        """Save dataset and comprehensive metadata"""
        print(f"\nSaving V4 test dataset and metadata...")

        # Main dataset
        dataset_path = self.output_dir / 'enhanced_gym_member_exercise_tracking_v4_test.xlsx'
        dataset.to_excel(dataset_path, index=False)
        print(f"  • Main dataset: {dataset_path}")

        # Feature specifications for the dataset
        feature_specs = {
            "intensity_branch_features": {
                "primary_features": [
                    "resistance_intensity",
                    "cardio_intensity",
                    "volume_load",
                    "rest_density",
                    "tempo_factor",
                    "metabolic_stress"
                ],
                "description": "Features for intensity prediction branch",
                "target_variable": "target_overall_intensity"
            },
            "suitability_branch_features": {
                "primary_features": [
                    "age", "weight_kg", "height_m", "bmi", "experience_level",
                    "workout_frequency", "resting_heartrate", "mood_numeric",
                    "fatigue_numeric", "effort_numeric", "readiness_factor_v4",
                    "strength_to_weight_ratio", "sepa_composite"
                ],
                "description": "Features for suitability prediction branch",
                "target_variable": "target_suitability"
            },
            "shared_features": {
                "features": [
                    "age", "weight_kg", "height_m", "experience_level",
                    "mood_numeric", "fatigue_numeric", "effort_numeric"
                ],
                "description": "Features shared between both branches"
            },
            "target_variables": {
                "intensity_targets": [
                    "target_resistance_intensity",
                    "target_cardio_intensity",
                    "target_overall_intensity"
                ],
                "suitability_targets": ["target_suitability"],
                "additional_targets": [
                    "target_readiness_v4",
                    "target_1rm_enhanced"
                ],
                "classification_targets": [
                    "target_performance_class_encoded"
                ]
            },
            "dataset_statistics": {
                "total_samples": len(dataset),
                "total_features": len(dataset.columns),
                "exercise_types": dataset['exercise_type'].value_counts().to_dict(),
                "fitness_goals": dataset['fitness_goal'].value_counts().to_dict(),
                "muscle_groups": dataset['muscle_group'].value_counts().to_dict()
            }
        }

        specs_path = self.output_dir / 'v4_test_feature_specifications.json'
        with open(specs_path, 'w') as f:
            json.dump(feature_specs, f, indent=2, default=str)
        print(f"  • Feature specifications: {specs_path}")

        # Data generation report
        report = {
            "generation_info": {
                "timestamp": pd.Timestamp.now().isoformat(),
                "num_samples": self.num_samples,
                "generator_version": "V4.0",
                "random_seeds": [42, 43, 44, 45, 46]
            },
            "data_characteristics": {
                "age_range": [float(dataset['age'].min()), float(dataset['age'].max())],
                "weight_range": [float(dataset['weight_kg'].min()), float(dataset['weight_kg'].max())],
                "experience_levels": sorted(dataset['experience_level'].unique().tolist()),
                "suitability_distribution": {
                    "low": float((dataset['target_suitability'] < 0.4).sum()),
                    "moderate": float(((dataset['target_suitability'] >= 0.4) & (dataset['target_suitability'] < 0.75)).sum()),
                    "high": float((dataset['target_suitability'] >= 0.75).sum())
                }
            },
            "sepa_analysis": {
                "mood_distribution": dataset['mood_numeric'].value_counts().sort_index().to_dict(),
                "fatigue_distribution": dataset['fatigue_numeric'].value_counts().sort_index().to_dict(),
                "effort_distribution": dataset['effort_numeric'].value_counts().sort_index().to_dict(),
                "readiness_stats": {
                    "mean": float(dataset['readiness_factor_v4'].mean()),
                    "std": float(dataset['readiness_factor_v4'].std()),
                    "min": float(dataset['readiness_factor_v4'].min()),
                    "max": float(dataset['readiness_factor_v4'].max())
                }
            },
            "exercise_analysis": {
                "exercise_count": len(dataset['exercise_name'].unique()),
                "most_common_exercises": dataset['exercise_name'].value_counts().head(10).to_dict(),
                "type_distribution": dataset['exercise_type'].value_counts().to_dict(),
                "difficulty_distribution": dataset['difficulty_level'].value_counts().to_dict()
            }
        }

        report_path = self.output_dir / 'v4_test_generation_report.json'
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2, default=str)
        print(f"  • Generation report: {report_path}")

        # Create a smaller sample dataset for quick testing
        sample_size = min(100, len(dataset))
        sample_dataset = dataset.sample(n=sample_size, random_state=42)
        sample_path = self.output_dir / 'enhanced_gym_member_exercise_tracking_v4_test_sample.xlsx'
        sample_dataset.to_excel(sample_path, index=False)
        print(f"  • Sample dataset ({sample_size} samples): {sample_path}")

        print(f"\n✅ V4 Test dataset creation completed!")
        print(f"📁 All files saved to: {self.output_dir.absolute()}")

        return {
            'main_dataset': str(dataset_path),
            'feature_specifications': str(specs_path),
            'generation_report': str(report_path),
            'sample_dataset': str(sample_path)
        }

def main():
    """Main function to generate V4 test data"""
    # Configuration
    NUM_SAMPLES = 2000  # Generate comprehensive test dataset
    OUTPUT_DIR = "./data"

    print("="*80)
    print("V4 MODEL TEST DATA GENERATOR")
    print("="*80)
    print(f"Generating {NUM_SAMPLES} synthetic test samples...")
    print(f"Output directory: {OUTPUT_DIR}")

    # Create data generator
    generator = V4TestDataGenerator(num_samples=NUM_SAMPLES, output_dir=OUTPUT_DIR)

    # Generate complete dataset
    dataset = generator.create_final_dataset()

    # Save dataset and metadata
    saved_files = generator.save_dataset_and_metadata(dataset)

    print(f"\n🎉 V4 Test Data Generation Completed Successfully!")
    print(f"📊 Dataset shape: {dataset.shape}")
    print(f"📁 Files created:")
    for file_type, file_path in saved_files.items():
        print(f"  • {file_type}: {file_path}")

    print(f"\n🚀 Ready for V4 model evaluation!")

    return dataset, saved_files

if __name__ == "__main__":
    dataset, files = main()
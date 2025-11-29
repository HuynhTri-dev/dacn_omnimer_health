#!/usr/bin/env python3
"""
Utility script for loading and using the processed 3T-FIT dataset

This provides easy access to:
- Load the final processed dataset
- Split data for training/testing
- Get feature and target matrices for ML models
- Calculate suitability scores for new data
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from typing import Dict, Tuple, List, Optional
import joblib
import os

class DatasetLoader:
    """Utility class for loading and using the 3T-FIT dataset"""

    def __init__(self, dataset_path: str = "../personal_final_dataset.xlsx"):
        """
        Initialize the dataset loader

        Args:
            dataset_path: Path to the final processed dataset
        """
        self.dataset_path = dataset_path
        self.data = None
        self.feature_columns = []
        self.target_columns = []

    def load_dataset(self) -> pd.DataFrame:
        """Load the processed dataset"""
        try:
            self.data = pd.read_excel(self.dataset_path)
            print(f"Dataset loaded successfully: {self.data.shape}")
            return self.data
        except Exception as e:
            print(f"Error loading dataset: {e}")
            raise

    def get_feature_target_split(self) -> Tuple[pd.DataFrame, pd.DataFrame]:
        """
        Split dataset into features and targets for ML training

        Returns:
            X: Feature matrix
            y: Target matrix (enhanced_suitability, is_suitable)
        """
        if self.data is None:
            self.load_dataset()

        # Define feature columns (exclude non-predictive and target columns)
        exclude_columns = [
            'exercise_name', 'workout_type', 'location', 'data_source',
            'enhanced_suitability', 'is_suitable'
        ]

        # Also exclude encoded versions that are already handled
        exclude_columns.extend([
            'exercise_name_encoded', 'workout_type_encoded', 'location_encoded'
        ])

        # Get feature columns
        self.feature_columns = [col for col in self.data.columns
                               if col not in exclude_columns]

        # Target columns
        self.target_columns = ['enhanced_suitability', 'is_suitable']

        X = self.data[self.feature_columns]
        y = self.data[self.target_columns]

        print(f"Feature matrix shape: {X.shape}")
        print(f"Target matrix shape: {y.shape}")

        return X, y

    def get_train_test_split(self, test_size: float = 0.2, random_state: int = 42) -> Dict:
        """
        Split dataset into training and testing sets

        Args:
            test_size: Proportion of data for testing
            random_state: Random seed for reproducibility

        Returns:
            Dictionary containing train/test splits for both regression and classification
        """
        X, y = self.get_feature_target_split()

        # Split for regression (enhanced_suitability)
        X_train, X_test, y_reg_train, y_reg_test = train_test_split(
            X, y['enhanced_suitability'],
            test_size=test_size, random_state=random_state
        )

        # Split for classification (is_suitable)
        _, _, y_cls_train, y_cls_test = train_test_split(
            X, y['is_suitable'],
            test_size=test_size, random_state=random_state
        )

        return {
            'X_train': X_train,
            'X_test': X_test,
            'y_reg_train': y_reg_train,  # Regression target
            'y_reg_test': y_reg_test,
            'y_cls_train': y_cls_train,  # Classification target
            'y_cls_test': y_cls_test,
            'feature_columns': self.feature_columns,
            'target_columns': self.target_columns
        }

    def get_suitable_exercises(self, threshold: float = 0.7, limit: Optional[int] = None) -> pd.DataFrame:
        """
        Get exercises with suitability scores above threshold

        Args:
            threshold: Minimum suitability score
            limit: Maximum number of exercises to return

        Returns:
            DataFrame of suitable exercises
        """
        if self.data is None:
            self.load_dataset()

        suitable = self.data[self.data['enhanced_suitability'] >= threshold].copy()

        # Sort by suitability score (descending)
        suitable = suitable.sort_values('enhanced_suitability', ascending=False)

        if limit:
            suitable = suitable.head(limit)

        # Return key columns for readability
        key_columns = [
            'exercise_name', 'workout_type', 'enhanced_suitability', 'is_suitable',
            'duration_min', 'avg_hr', 'calories', 'intensity_score', 'data_source'
        ]

        available_columns = [col for col in key_columns if col in suitable.columns]

        return suitable[available_columns]

    def get_exercise_recommendations(self,
                                   workout_type: Optional[str] = None,
                                   min_duration: Optional[float] = None,
                                   max_duration: Optional[float] = None,
                                   min_suitability: float = 0.7,
                                   limit: int = 10) -> pd.DataFrame:
        """
        Get personalized exercise recommendations

        Args:
            workout_type: Filter by workout type (e.g., 'Strength', 'Cardio')
            min_duration: Minimum exercise duration in minutes
            max_duration: Maximum exercise duration in minutes
            min_suitability: Minimum suitability score
            limit: Maximum number of recommendations

        Returns:
            DataFrame of recommended exercises
        """
        if self.data is None:
            self.load_dataset()

        # Start with all suitable exercises
        recommendations = self.data[self.data['enhanced_suitability'] >= min_suitability].copy()

        # Apply filters
        if workout_type:
            recommendations = recommendations[recommendations['workout_type'] == workout_type]

        if min_duration:
            recommendations = recommendations[recommendations['duration_min'] >= min_duration]

        if max_duration:
            recommendations = recommendations[recommendations['duration_min'] <= max_duration]

        # Sort by suitability score
        recommendations = recommendations.sort_values('enhanced_suitability', ascending=False)

        # Limit results
        recommendations = recommendations.head(limit)

        # Return key columns
        key_columns = [
            'exercise_name', 'workout_type', 'enhanced_suitability',
            'duration_min', 'avg_hr', 'calories', 'intensity_score',
            'resistance_intensity', 'cardio_intensity'
        ]

        available_columns = [col for col in key_columns if col in recommendations.columns]

        return recommendations[available_columns]

    def get_dataset_statistics(self) -> Dict:
        """Get comprehensive dataset statistics"""
        if self.data is None:
            self.load_dataset()

        stats = {
            'shape': self.data.shape,
            'columns': list(self.data.columns),
            'data_sources': self.data['data_source'].value_counts().to_dict(),
            'workout_types': self.data['workout_type'].value_counts().to_dict(),
            'suitability_stats': {
                'mean': float(self.data['enhanced_suitability'].mean()),
                'std': float(self.data['enhanced_suitability'].std()),
                'min': float(self.data['enhanced_suitability'].min()),
                'max': float(self.data['enhanced_suitability'].max()),
                'median': float(self.data['enhanced_suitability'].median())
            },
            'exercise_count': len(self.data['exercise_name'].unique()),
            'suitable_percentage': float((self.data['enhanced_suitability'] >= 0.7).mean() * 100)
        }

        return stats

    def save_training_data(self, output_dir: str = "../personal_training_data"):
        """
        Save processed data in ML-ready format

        Args:
            output_dir: Directory to save training data
        """
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        # Get train/test split
        splits = self.get_train_test_split()

        # Save training data
        train_data = pd.concat([splits['X_train'],
                               splits['y_reg_train'].rename('enhanced_suitability'),
                               splits['y_cls_train'].rename('is_suitable')], axis=1)
        train_data.to_excel(os.path.join(output_dir, 'train_data.xlsx'), index=False)

        # Save testing data
        test_data = pd.concat([splits['X_test'],
                              splits['y_reg_test'].rename('enhanced_suitability'),
                              splits['y_cls_test'].rename('is_suitable')], axis=1)
        test_data.to_excel(os.path.join(output_dir, 'test_data.xlsx'), index=False)

        # Save metadata
        metadata = {
            'feature_columns': splits['feature_columns'],
            'target_columns': splits['target_columns'],
            'train_shape': train_data.shape,
            'test_shape': test_data.shape
        }

        joblib.dump(metadata, os.path.join(output_dir, 'metadata.pkl'))

        print(f"Training data saved to: {output_dir}")
        print(f"Training set: {train_data.shape}")
        print(f"Testing set: {test_data.shape}")


def main():
    """Demo of the dataset loader functionality"""
    print("3T-FIT Dataset Loader Demo")
    print("=" * 40)

    # Initialize loader
    loader = DatasetLoader()

    # Load dataset
    loader.load_dataset()

    # Get statistics
    stats = loader.get_dataset_statistics()
    print(f"\nDataset Statistics:")
    print(f"- Total records: {stats['shape'][0]:,}")
    print(f"- Total features: {stats['shape'][1]}")
    print(f"- Unique exercises: {stats['exercise_count']:,}")
    print(f"- Suitable exercises: {stats['suitable_percentage']:.1f}%")

    # Get train/test split
    splits = loader.get_train_test_split()
    print(f"\nTraining/Testing Split:")
    print(f"- Training samples: {len(splits['X_train']):,}")
    print(f"- Testing samples: {len(splits['X_test']):,}")
    print(f"- Features: {len(splits['feature_columns'])}")

    # Get top suitable exercises
    top_exercises = loader.get_suitable_exercises(limit=5)
    print(f"\nTop 5 Suitable Exercises:")
    for idx, row in top_exercises.iterrows():
        print(f"- {row['exercise_name']} (Score: {row['enhanced_suitability']:.3f}, Type: {row['workout_type']})")

    # Get recommendations for strength training
    strength_recs = loader.get_exercise_recommendations(
        workout_type='Strength',
        min_duration=5,
        max_duration=30,
        limit=3
    )
    print(f"\nStrength Training Recommendations:")
    for idx, row in strength_recs.iterrows():
        print(f"- {row['exercise_name']} (Duration: {row['duration_min']:.1f}min, Score: {row['enhanced_suitability']:.3f})")

    # Save training data
    loader.save_training_data()


if __name__ == "__main__":
    main()
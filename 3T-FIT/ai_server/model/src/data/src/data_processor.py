#!/usr/bin/env python3
"""
Data Processing Script for 3T-FIT AI Recommendation System

This script combines and processes two datasets:
1. kaggle_dataset.xlsx (10,000 records) - Synthetic data from Kaggle
2. real_dataset.xlsx (200 records) - Real-world collected data

Output: final_dataset.xlsx - Cleaned, normalized, and combined dataset ready for ML training
"""

import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler, StandardScaler, LabelEncoder
from typing import Dict, Tuple, List
import warnings
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class DataProcessor:
    """Data processor for 3T-FIT exercise datasets"""

    def __init__(self):
        self.scalers = {}
        self.encoders = {}
        self.processed_data = None

        # Define feature categories based on README.md
        self.numerical_features = [
            'duration_min', 'avg_hr', 'max_hr', 'calories', 'fatigue', 'effort',
            'mood', 'age', 'height_m', 'weight_kg', 'bmi', 'fat_percentage',
            'resting_heartrate', 'experience_level', 'workout_frequency',
            'session_duration', 'estimated_1rm', 'pace', 'duration_capacity',
            'rest_period', 'intensity_score'
        ]

        self.categorical_features = [
            'exercise_name', 'workout_type', 'location'
        ]

        self.target_features = [
            'suitability_x'
        ]

        # Define valid ranges for data cleaning (based on exercise science standards)
        self.valid_ranges = {
            'age': (10, 80),
            'height_m': (1.2, 2.3),
            'weight_kg': (30, 200),
            'bmi': (15, 40),
            'fat_percentage': (5, 50),
            'resting_heartrate': (40, 100),
            'avg_hr': (50, 220),
            'max_hr': (60, 220),
            'duration_min': (0.5, 180),
            'calories': (10, 2000),
            'fatigue': (1, 5),
            'effort': (1, 5),
            'mood': (1, 5),
            'experience_level': (1, 3),
            'workout_frequency': (1, 7),
            'session_duration': (5, 300),
            'estimated_1rm': (10, 500),
            'pace': (0, 20),
            'duration_capacity': (1, 100),
            'rest_period': (0, 600),
            'intensity_score': (0, 10),
            'suitability_x': (0, 1)
        }

    def load_data(self, kaggle_path: str, real_path: str) -> Tuple[pd.DataFrame, pd.DataFrame]:
        """Load both datasets"""
        try:
            kaggle_df = pd.read_excel(kaggle_path)
            real_df = pd.read_excel(real_path)

            logger.info(f"Loaded Kaggle dataset: {kaggle_df.shape}")
            logger.info(f"Loaded Real dataset: {real_df.shape}")

            return kaggle_df, real_df

        except Exception as e:
            logger.error(f"Error loading datasets: {e}")
            raise

    def clean_data(self, df: pd.DataFrame, dataset_name: str) -> pd.DataFrame:
        """Clean and validate data"""
        logger.info(f"Cleaning {dataset_name} dataset...")

        initial_shape = df.shape
        cleaned_df = df.copy()

        # 1. Handle missing values
        logger.info("Checking for missing values...")
        missing_values = cleaned_df.isnull().sum()
        if missing_values.sum() > 0:
            logger.warning(f"Missing values found:\n{missing_values[missing_values > 0]}")

            # Fill numerical missing values with median
            for col in self.numerical_features:
                if col in cleaned_df.columns and cleaned_df[col].isnull().sum() > 0:
                    median_val = cleaned_df[col].median()
                    cleaned_df[col].fillna(median_val, inplace=True)
                    logger.info(f"Filled {col} missing values with median: {median_val}")

            # Fill categorical missing values with mode
            for col in self.categorical_features:
                if col in cleaned_df.columns and cleaned_df[col].isnull().sum() > 0:
                    mode_val = cleaned_df[col].mode()[0]
                    cleaned_df[col].fillna(mode_val, inplace=True)
                    logger.info(f"Filled {col} missing values with mode: {mode_val}")

        # 2. Remove duplicates
        duplicates = cleaned_df.duplicated().sum()
        if duplicates > 0:
            logger.info(f"Removing {duplicates} duplicate rows...")
            cleaned_df.drop_duplicates(inplace=True)

        # 3. Validate and fix out-of-range values
        logger.info("Validating data ranges...")
        out_of_range_count = 0

        for col, (min_val, max_val) in self.valid_ranges.items():
            if col in cleaned_df.columns:
                # Count out-of-range values
                out_of_range = ((cleaned_df[col] < min_val) | (cleaned_df[col] > max_val)).sum()
                if out_of_range > 0:
                    logger.info(f"Found {out_of_range} out-of-range values in {col}")
                    out_of_range_count += out_of_range

                    # Clip values to valid range
                    cleaned_df[col] = np.clip(cleaned_df[col], min_val, max_val)

        logger.info(f"Fixed {out_of_range_count} out-of-range values")

        # 4. Validate physiological relationships
        logger.info("Validating physiological relationships...")

        # max_hr should be >= avg_hr
        invalid_hr = (cleaned_df['max_hr'] < cleaned_df['avg_hr']).sum()
        if invalid_hr > 0:
            logger.info(f"Fixing {invalid_hr} records where max_hr < avg_hr")
            # Swap values where max_hr < avg_hr
            mask = cleaned_df['max_hr'] < cleaned_df['avg_hr']
            cleaned_df.loc[mask, ['avg_hr', 'max_hr']] = cleaned_df.loc[mask, ['max_hr', 'avg_hr']].values

        # BMI should be roughly consistent with height and weight
        # Calculate expected BMI and fix if difference is too large
        if all(col in cleaned_df.columns for col in ['height_m', 'weight_kg', 'bmi']):
            expected_bmi = cleaned_df['weight_kg'] / (cleaned_df['height_m'] ** 2)
            bmi_diff = abs(cleaned_df['bmi'] - expected_bmi)
            inconsistent_bmi = bmi_diff > 5  # Allow some tolerance

            if inconsistent_bmi.sum() > 0:
                logger.info(f"Fixing {inconsistent_bmi.sum()} inconsistent BMI values")
                cleaned_df.loc[inconsistent_bmi, 'bmi'] = expected_bmi[inconsistent_bmi]

        final_shape = cleaned_df.shape
        logger.info(f"Cleaning complete: {initial_shape} -> {final_shape} rows")

        return cleaned_df

    def calculate_derived_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """Calculate derived features for ML model"""
        logger.info("Calculating derived features...")

        df = df.copy()

        # 1. Resistance Intensity (RI) = (Reps * Weight) / Estimated_1RM
        # Since we don't have reps directly, we'll use intensity_score as proxy
        if 'estimated_1rm' in df.columns and 'intensity_score' in df.columns:
            # Avoid division by zero
            df['resistance_intensity'] = np.where(
                df['estimated_1rm'] > 0,
                df['intensity_score'] / df['estimated_1rm'],
                0
            )
        else:
            df['resistance_intensity'] = 0

        # 2. Cardio Intensity Proxy = avg_hr / max_hr
        if 'avg_hr' in df.columns and 'max_hr' in df.columns:
            # Avoid division by zero
            df['cardio_intensity'] = np.where(
                df['max_hr'] > 0,
                df['avg_hr'] / df['max_hr'],
                0
            )
        else:
            df['cardio_intensity'] = 0

        # 3. Volume Load Proxy = intensity_score * duration_min
        if 'intensity_score' in df.columns and 'duration_min' in df.columns:
            df['volume_load'] = df['intensity_score'] * df['duration_min']
        else:
            df['volume_load'] = 0

        # 4. Rest Density = rest_period / (rest_period + duration_min)
        if 'rest_period' in df.columns and 'duration_min' in df.columns:
            total_time = df['rest_period'] + df['duration_min']
            df['rest_density'] = np.where(
                total_time > 0,
                df['rest_period'] / total_time,
                0
            )
        else:
            df['rest_density'] = 0

        # 5. HR Reserve = (avg_hr - resting_heartrate) / (max_hr - resting_heartrate)
        if all(col in df.columns for col in ['avg_hr', 'max_hr', 'resting_heartrate']):
            hr_reserve_denominator = df['max_hr'] - df['resting_heartrate']
            df['hr_reserve'] = np.where(
                hr_reserve_denominator > 0,
                (df['avg_hr'] - df['resting_heartrate']) / hr_reserve_denominator,
                0
            )
        else:
            df['hr_reserve'] = 0

        # 6. Calorie Efficiency = calories / duration_min
        if 'calories' in df.columns and 'duration_min' in df.columns:
            df['calorie_efficiency'] = np.where(
                df['duration_min'] > 0,
                df['calories'] / df['duration_min'],
                0
            )
        else:
            df['calorie_efficiency'] = 0

        # Add new features to numerical features list
        new_features = [
            'resistance_intensity', 'cardio_intensity', 'volume_load',
            'rest_density', 'hr_reserve', 'calorie_efficiency'
        ]

        self.numerical_features.extend(new_features)

        logger.info(f"Added {len(new_features)} derived features")

        return df

    def normalize_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """Normalize numerical features using MinMax scaling"""
        logger.info("Normalizing numerical features...")

        df = df.copy()

        # MinMax scaling for most numerical features
        features_to_scale = [col for col in self.numerical_features
                          if col in df.columns and col not in ['suitability_x']]

        if features_to_scale:
            scaler = MinMaxScaler()
            df[features_to_scale] = scaler.fit_transform(df[features_to_scale])
            self.scalers['minmax'] = scaler

            logger.info(f"Scaled {len(features_to_scale)} numerical features using MinMax")

        return df

    def encode_categorical_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """Encode categorical features using label encoding"""
        logger.info("Encoding categorical features...")

        df = df.copy()

        for col in self.categorical_features:
            if col in df.columns:
                encoder = LabelEncoder()
                df[col + '_encoded'] = encoder.fit_transform(df[col].astype(str))
                self.encoders[col] = encoder

                logger.info(f"Encoded {col} with {len(encoder.classes_)} unique values")

        return df

    def calculate_suitability_score(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Calculate enhanced suitability score based on the formula in README.md

        Formula: SuitabilityScore = (0.4 * P_psych) + (0.3 * P_physio) + (0.3 * P_perf)
        """
        logger.info("Calculating enhanced suitability scores...")

        df = df.copy()
        n_samples = len(df)

        # 1. Psychological Component (40%) - based on mood and fatigue
        if 'mood' in df.columns and 'fatigue' in df.columns:
            # Normalize to 0-1 scale (assuming 1-5 scale)
            norm_mood = (df['mood'] - 1) / 4  # Convert 1-5 to 0-1
            norm_fatigue = (df['fatigue'] - 1) / 4  # Convert 1-5 to 0-1

            # Higher mood is better, lower fatigue is better
            p_psych = (norm_mood * 0.7) + ((1 - norm_fatigue) * 0.3)
        else:
            p_psych = 0.5  # Default middle value

        # 2. Physiological Component (30%) - based on heart rate zones
        if 'avg_hr' in df.columns and 'max_hr' in df.columns:
            hr_ratio = df['avg_hr'] / df['max_hr']
            # Optimal zone is around 70-80% of max HR
            optimal_zone = 0.75
            p_physio = 1 - np.abs(hr_ratio - optimal_zone)
            p_physio = np.clip(p_physio, 0, 1)
        else:
            p_physio = 0.5  # Default middle value

        # 3. Performance Component (30%) - based on efficiency
        if 'calorie_efficiency' in df.columns:
            # Use the calculated calorie efficiency
            p_perf = np.clip(df['calorie_efficiency'], 0, 1)
        elif 'calories' in df.columns and 'duration_min' in df.columns:
            # Calculate calories per minute and normalize
            calories_per_min = df['calories'] / df['duration_min']
            # Typical range: 5-15 cal/min, normalize to 0-1
            p_perf = np.clip((calories_per_min - 5) / 10, 0, 1)
        else:
            p_perf = 0.5  # Default middle value

        # Calculate final suitability score
        df['enhanced_suitability'] = (0.4 * p_psych) + (0.3 * p_physio) + (0.3 * p_perf)
        df['enhanced_suitability'] = np.clip(df['enhanced_suitability'], 0, 1)

        # Create binary classification label (threshold = 0.7)
        df['is_suitable'] = (df['enhanced_suitability'] >= 0.7).astype(int)

        logger.info(f"Enhanced suitability scores calculated:")
        logger.info(f"  Mean: {df['enhanced_suitability'].mean():.3f}")
        logger.info(f"  Std: {df['enhanced_suitability'].std():.3f}")
        logger.info(f"  Suitable (>=0.7): {df['is_suitable'].sum()} ({df['is_suitable'].mean()*100:.1f}%)")

        return df

    def inject_noise(self, df: pd.DataFrame, noise_level: float = 0.15) -> pd.DataFrame:
        """
        Inject random noise into numerical features to augment data
        and help model learn to handle variability.
        """
        logger.info(f"Injecting {noise_level*100:.1f}% random noise into numerical features...")

        df = df.copy()
        
        # Filter features that exist in current dataframe
        features_to_noise = [f for f in self.numerical_features if f in df.columns]

        for col in features_to_noise:
            if pd.api.types.is_numeric_dtype(df[col]):
                # Calculate noise scale based on feature standard deviation
                scale = df[col].std() * noise_level
                if scale == 0:
                    continue
                    
                noise = np.random.normal(loc=0, scale=scale, size=len(df))
                df[col] += noise

                # Enforce valid ranges
                if col in self.valid_ranges:
                    min_val, max_val = self.valid_ranges[col]
                    df[col] = np.clip(df[col], min_val, max_val)

        return df

    def process_datasets(self, kaggle_path: str, real_path: str) -> pd.DataFrame:
        """Main processing pipeline"""
        logger.info("Starting data processing pipeline...")

        # 1. Load datasets
        kaggle_df, real_df = self.load_data(kaggle_path, real_path)

        # 2. Clean datasets
        kaggle_clean = self.clean_data(kaggle_df, "Kaggle")
        real_clean = self.clean_data(real_df, "Real")

        # 3. Add dataset source labels
        kaggle_clean['data_source'] = 'kaggle'
        real_clean['data_source'] = 'real'

        # 4. Combine datasets
        combined_df = pd.concat([kaggle_clean, real_clean], ignore_index=True)
        logger.info(f"Combined dataset shape: {combined_df.shape}")

        # 5. Inject noise for data augmentation
        combined_df = self.inject_noise(combined_df, noise_level=0.15)

        # 6. Calculate derived features
        combined_df = self.calculate_derived_features(combined_df)

        # 7. Calculate enhanced suitability scores
        combined_df = self.calculate_suitability_score(combined_df)

        # 8. Encode categorical features
        combined_df = self.encode_categorical_features(combined_df)

        # 9. Normalize numerical features
        combined_df = self.normalize_features(combined_df)

        self.processed_data = combined_df

        logger.info("Data processing pipeline completed successfully!")
        return combined_df

    def save_processed_data(self, output_path: str):
        """Save processed dataset to Excel file"""
        if self.processed_data is None:
            raise ValueError("No processed data to save. Run process_datasets first.")
        try:
            # Save to Excel
            self.processed_data.to_excel(output_path, index=False)
            logger.info(f"Processed dataset saved to: {output_path}")

            # Also save a summary
            summary_path = output_path.replace('.xlsx', '_summary.txt')
            with open(summary_path, 'w', encoding='utf-8') as f:
                f.write("3T-FIT DATASET PROCESSING SUMMARY\n")
                f.write("=" * 50 + "\n\n")
                f.write(f"Final Dataset Shape: {self.processed_data.shape}\n")
                f.write(f"Total Records: {len(self.processed_data)}\n")
                f.write(f"Total Features: {len(self.processed_data.columns)}\n\n")

                f.write("FEATURES:\n")
                f.write("-" * 20 + "\n")
                for i, col in enumerate(self.processed_data.columns, 1):
                    dtype = self.processed_data[col].dtype
                    null_count = self.processed_data[col].isnull().sum()
                    f.write(f"{i:2d}. {col:30s} ({str(dtype):10s}) - Null: {null_count}\n")

                f.write(f"\nDATASET SOURCES:\n")
                f.write("-" * 20 + "\n")
                source_counts = self.processed_data['data_source'].value_counts()
                for source, count in source_counts.items():
                    f.write(f"{source:10s}: {count:6d} records ({count/len(self.processed_data)*100:.1f}%)\n")

                f.write(f"\nSUITABILITY DISTRIBUTION:\n")
                f.write("-" * 30 + "\n")
                f.write(f"Enhanced Suitability - Mean: {self.processed_data['enhanced_suitability'].mean():.3f}\n")
                f.write(f"Enhanced Suitability - Std:  {self.processed_data['enhanced_suitability'].std():.3f}\n")
                f.write(f"Suitable (>=0.7):        {self.processed_data['is_suitable'].sum()} records\n")
                f.write(f"Not Suitable (<0.7):     {(self.processed_data['is_suitable']==0).sum()} records\n")

            logger.info(f"Processing summary saved to: {summary_path}")

        except Exception as e:
            logger.error(f"Error saving processed data: {e}")
            raise

    def get_processing_report(self) -> Dict:
        """Generate a summary report of the processing"""
        if self.processed_data is None:
            return {"error": "No processed data available"}

        report = {
            "shape": self.processed_data.shape,
            "columns": list(self.processed_data.columns),
            "data_sources": self.processed_data['data_source'].value_counts().to_dict(),
            "suitability_stats": {
                "mean": float(self.processed_data['enhanced_suitability'].mean()),
                "std": float(self.processed_data['enhanced_suitability'].std()),
                "min": float(self.processed_data['enhanced_suitability'].min()),
                "max": float(self.processed_data['enhanced_suitability'].max()),
                "suitable_count": int(self.processed_data['is_suitable'].sum()),
                "suitable_percentage": float(self.processed_data['is_suitable'].mean() * 100)
            }
        }

        return report


def main():
    """Main execution function"""
    # Initialize processor
    processor = DataProcessor()

    # Define file paths
    kaggle_path = "../kaggle_dataset.xlsx"
    real_path = "../real_dataset.xlsx"
    output_path = "../personal_final_dataset.xlsx"

    try:
        # Process datasets
        final_dataset = processor.process_datasets(kaggle_path, real_path)

        # Save processed data
        processor.save_processed_data(output_path)

        # Generate and print report
        report = processor.get_processing_report()
        print("\n" + "="*60)
        print("DATASET PROCESSING COMPLETED SUCCESSFULLY!")
        print("="*60)
        print(f"Final Dataset Shape: {report['shape']}")
        print(f"Total Features: {len(report['columns'])}")
        print(f"Data Sources: {report['data_sources']}")
        print(f"Enhanced Suitability - Mean: {report['suitability_stats']['mean']:.3f}")
        print(f"Suitable Exercises (>=0.7): {report['suitability_stats']['suitable_percentage']:.1f}%")
        print(f"Output saved to: {output_path}")
        print("="*60)

    except Exception as e:
        logger.error(f"Error in main execution: {e}")
        raise


if __name__ == "__main__":
    main()
import joblib
import pandas as pd
import numpy as np
import json
import os
from typing import Dict, List, Tuple
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline

# Model v3 paths
MODEL_V3_PATH = "../../model/src/v3/model"
PREPROCESSOR_V3_PATH = os.path.join(MODEL_V3_PATH, "preprocessor_v3.joblib")
META_V3_PATH = os.path.join(MODEL_V3_PATH, "meta_v3.json")

class PreprocessorV3:
    # Preprocessor for Model v3 with enhanced feature engineering
    # Based on Strategy_Analysis.md principles

    def __init__(self):
        self.preprocessor = None
        self.feature_columns = []
        self.numeric_features = []
        self.categorical_features = []
        self.sepa_mapping = {}

    def load_artifacts(self):
        """Load preprocessing artifacts from Model v3 training"""
        try:
            # Load metadata first
            with open(META_V3_PATH, 'r', encoding='utf-8') as f:
                meta_v3 = json.load(f)

            # Extract feature information
            dataset_info = meta_v3.get('dataset_info', {})
            self.feature_columns = dataset_info.get('feature_columns', [])
            self.numeric_features = dataset_info.get('numeric_features', [])
            self.categorical_features = dataset_info.get('categorical_features', [])
            self.sepa_mapping = meta_v3.get('sepa_mapping', {})

            # Load preprocessor
            if os.path.exists(PREPROCESSOR_V3_PATH):
                self.preprocessor = joblib.load(PREPROCESSOR_V3_PATH)
                print("Preprocessor v3 loaded successfully")
            else:
                # Fallback: create basic preprocessor
                self.preprocessor = self._create_fallback_preprocessor()
                print("Warning: Preprocessor v3 not found, using fallback")

            print(f"   - Features: {len(self.feature_columns)}")
            print(f"   - Numeric: {len(self.numeric_features)}")
            print(f"   - Categorical: {len(self.categorical_features)}")

            return True

        except Exception as e:
            print(f"Failed to load preprocessor v3: {e}")
            self.preprocessor = self._create_fallback_preprocessor()
            return False

    def _create_fallback_preprocessor(self):
        """Create a basic preprocessor for fallback"""
        from sklearn.compose import ColumnTransformer
        from sklearn.preprocessing import StandardScaler, OneHotEncoder
        from sklearn.impute import SimpleImputer

        numeric_transformer = Pipeline(steps=[
            ('imputer', SimpleImputer(strategy='median')),
            ('scaler', StandardScaler())
        ])

        categorical_transformer = Pipeline(steps=[
            ('imputer', SimpleImputer(strategy='constant', fill_value='unknown')),
            ('onehot', OneHotEncoder(handle_unknown='ignore'))
        ])

        # Create basic column lists if not available
        if not self.numeric_features:
            self.numeric_features = [
                'age', 'weight_kg', 'height_m', 'bmi',
                'experience_level', 'workout_frequency', 'resting_heartrate'
            ]
        if not self.categorical_features:
            self.categorical_features = ['gender']

        preprocessor = ColumnTransformer(
            transformers=[
                ('num', numeric_transformer, self.numeric_features),
                ('cat', categorical_transformer, self.categorical_features)
            ]
        )

        return preprocessor

    def encode_sepa_scores(self, profile: Dict) -> Dict:
        """
        Encode SePA (Self-Perceived Assessment) scores to numeric values
        Based on Strategy_Analysis.md SePA integration principles
        """
        encoded_profile = profile.copy()

        # Map mood to numeric (1-5 scale)
        if 'mood' in profile and isinstance(profile['mood'], str):
            mood_str = profile['mood'].title()
            if mood_str in self.sepa_mapping.get('mood', {}):
                encoded_profile['mood_numeric'] = self.sepa_mapping['mood'][mood_str]
            else:
                # Default to neutral if not found
                encoded_profile['mood_numeric'] = 3.0
        else:
            # If already numeric or missing, default to neutral
            encoded_profile['mood_numeric'] = float(profile.get('mood_numeric', 3.0))

        # Map fatigue to numeric (1-5 scale)
        if 'fatigue' in profile and isinstance(profile['fatigue'], str):
            fatigue_str = profile['fatigue'].title()
            if fatigue_str in self.sepa_mapping.get('fatigue', {}):
                encoded_profile['fatigue_numeric'] = self.sepa_mapping['fatigue'][fatigue_str]
            else:
                encoded_profile['fatigue_numeric'] = 3.0
        else:
            encoded_profile['fatigue_numeric'] = float(profile.get('fatigue_numeric', 3.0))

        # Map effort to numeric (1-5 scale)
        if 'effort' in profile and isinstance(profile['effort'], str):
            effort_str = profile['effort'].title()
            if effort_str in self.sepa_mapping.get('effort', {}):
                encoded_profile['effort_numeric'] = self.sepa_mapping['effort'][effort_str]
            else:
                encoded_profile['effort_numeric'] = 3.0
        else:
            encoded_profile['effort_numeric'] = float(profile.get('effort_numeric', 3.0))

        return encoded_profile

    def extract_features_from_profile(self, profile: Dict) -> Dict:
        """
        Extract and standardize features from user profile
        Following the feature engineering from Strategy_Analysis.md
        """
        # Start with encoded SePA scores
        features = self.encode_sepa_scores(profile)

        # Standardize field names and extract basic biometric data
        feature_mapping = {
            # Basic demographics
            'age': 'age',
            'gender': 'gender',

            # Physical measurements
            'height_cm': 'height_m',  # Convert to meters
            'weight_kg': 'weight_kg',
            'bmi': 'bmi',
            'body_fat_percentage': 'body_fat_percentage',
            'whr': 'whr',
            'muscle_mass': 'muscle_mass',

            # Fitness parameters
            'resting_hr': 'resting_heartrate',
            'resting_heartrate': 'resting_heartrate',
            'max_weight_lifted_kg': 'max_weight_lifted_kg',
            'activity_level': 'activity_level',

            # Experience and frequency
            'experience_level': 'experience_level',
            'workout_frequency_per_week': 'workout_frequency',
            'workout_frequency': 'workout_frequency',

            # Goal information
            'goal_type': 'goal_type',
            'target_metric': 'target_metric'
        }

        # Map features with standardization
        for input_key, output_key in feature_mapping.items():
            if input_key in profile:
                value = profile[input_key]

                # Convert height to meters if in cm
                if input_key == 'height_cm' and value:
                    features[output_key] = float(value) / 100.0
                # Ensure numeric fields are float
                elif isinstance(value, (int, float)):
                    features[output_key] = float(value)
                else:
                    features[output_key] = value

        # Handle missing values with defaults
        defaults = {
            'age': 30.0,
            'weight_kg': 70.0,
            'height_m': 1.75,
            'bmi': 23.0,
            'resting_heartrate': 70.0,
            'experience_level': 1.0,
            'workout_frequency': 3.0,
            'activity_level': 3.0,
            'mood_numeric': 3.0,
            'fatigue_numeric': 3.0,
            'effort_numeric': 3.0,
            'gender': 'male',
            'goal_type': 'general_fitness'
        }

        for key, default_value in defaults.items():
            if key not in features or features[key] is None:
                features[key] = default_value

        return features

    def transform_profile(self, profile: Dict) -> np.ndarray:
        """
        Transform user profile to model input format
        """
        # Extract and engineer features
        features = self.extract_features_from_profile(profile)

        # Convert to DataFrame
        df = pd.DataFrame([features])

        # Ensure all required columns are present
        for col in self.feature_columns:
            if col not in df.columns:
                df[col] = np.nan

        # Select only the columns used in training
        df = df[self.feature_columns]

        # Convert numeric columns
        for col in self.numeric_features:
            if col in df.columns:
                df[col] = pd.to_numeric(df[col], errors='coerce')

        # Convert categorical columns
        for col in self.categorical_features:
            if col in df.columns:
                df[col] = df[col].astype('object')

        # Apply preprocessing
        try:
            X_transformed = self.preprocessor.transform(df)

            # Handle sparse matrices
            if hasattr(X_transformed, "toarray"):
                X_transformed = X_transformed.toarray()

            return X_transformed.astype("float32")

        except Exception as e:
            print(f"❌ Error in preprocessing: {e}")
            # Fallback: return zeros with appropriate shape
            input_dim = len(self.feature_columns)
            return np.zeros((1, input_dim), dtype="float32")

    def get_feature_info(self) -> Dict:
        """Get information about features used in preprocessing"""
        return {
            "feature_columns": self.feature_columns,
            "numeric_features": self.numeric_features,
            "categorical_features": self.categorical_features,
            "sepa_mapping": self.sepa_mapping,
            "input_dim": len(self.feature_columns)
        }

# Global preprocessor instance
preprocessor_v3 = PreprocessorV3()

def load_preprocessor_v3() -> bool:
    """Load Model v3 preprocessor - call this during app startup"""
    return preprocessor_v3.load_artifacts()

def get_preprocessor_v3():
    """Get the loaded preprocessor v3 instance"""
    if preprocessor_v3.preprocessor is None:
        raise RuntimeError("Preprocessor v3 not loaded. Call load_preprocessor_v3() first.")
    return preprocessor_v3

def transform_profile_v3(profile: Dict) -> np.ndarray:
    """Transform user profile using Model v3 preprocessor"""
    return preprocessor_v3.transform_profile(profile)

def get_feature_info_v3() -> Dict:
    """Get Model v3 feature information"""
    return preprocessor_v3.get_feature_info()

def get_preprocessor_v3():
    """Get the loaded preprocessor v3 instance"""
    if preprocessor_v3.preprocessor is None:
        raise RuntimeError("Preprocessor v3 not loaded. Call load_preprocessor_v3() first.")
    return preprocessor_v3

def transform_profile_v3(profile: Dict) -> np.ndarray:
    """Transform user profile using Model v3 preprocessor"""
    return preprocessor_v3.transform_profile(profile)

def get_feature_info_v3() -> Dict:
    """Get Model v3 feature information"""
    return preprocessor_v3.get_feature_info()
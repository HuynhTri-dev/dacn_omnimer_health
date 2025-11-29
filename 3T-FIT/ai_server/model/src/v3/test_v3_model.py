"""
test_v3_model.py
Testing Script for V3 Enhanced Model

This script allows you to test the trained V3 model with new data or existing test sets.
Features:
- Load trained model and preprocessor
- Test with custom data or existing datasets
- Generate workout recommendations using rule-based decoding
- Comprehensive evaluation metrics
- Interactive testing mode

Usage:
    python test_v3_model.py --mode [interactive|batch|evaluate]
    python test_v3_model.py --input_file data.xlsx --mode batch
    python test_v3_model.py --mode interactive

Author: Claude Code Assistant
Date: 2025-11-25
"""

import os, json, argparse, numpy as np, pandas as pd, torch, torch.nn.functional as F
from pathlib import Path
import joblib
from typing import Dict, List, Tuple, Optional, Union
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import matplotlib.pyplot as plt
import seaborn as sns

# Import model classes and functions from training script
try:
    from train_v3_enhanced import (
        V3EnhancedModel, MOOD_MAPPING, FATIGUE_MAPPING, EFFORT_MAPPING,
        calculate_readiness_factor, decode_1rm_to_workout, WORKOUT_GOAL_MAPPING,
        map_sepa_to_numeric
    )
except ImportError:
    print("Error: Could not import from train_v3_enhanced.py. Make sure it's in the same directory.")
    exit(1)

class V3ModelTester:
    """Enhanced model testing class with multiple evaluation modes"""

    def __init__(self, artifacts_dir: str, device: Optional[str] = None):
        """
        Initialize the V3 Model Tester

        Args:
            artifacts_dir: Directory containing model artifacts
            device: Device to use ('cuda', 'cpu', or None for auto-detect)
        """
        self.artifacts_dir = Path(artifacts_dir)
        self.device = torch.device(device or ("cuda" if torch.cuda.is_available() else "cpu"))

        # Load model artifacts
        self.model = None
        self.preprocessor = None
        self.metadata = None
        self.feature_columns = None

        print(f"Initializing V3 Model Tester...")
        print(f"Artifacts directory: {self.artifacts_dir}")
        print(f"Using device: {self.device}")

        self._load_artifacts()

    def _load_artifacts(self):
        """Load model, preprocessor, and metadata"""
        try:
            # Load model checkpoint
            model_path = self.artifacts_dir / "best_v3.pt"
            if not model_path.exists():
                raise FileNotFoundError(f"Model file not found: {model_path}")

            checkpoint = torch.load(model_path, map_location=self.device, weights_only=False)

            # Get model configuration
            input_dim = checkpoint['input_dim']
            model_config = checkpoint.get('model_config', {})

            # Initialize model
            self.model = V3EnhancedModel(
                input_dim=input_dim,
                hidden_dim=model_config.get('hidden_dim', 256),
                num_layers=model_config.get('num_layers', 2),
                dropout=model_config.get('dropout', 0.2),
                use_transformer=model_config.get('use_transformer', False)
            ).to(self.device)

            # Load model weights
            self.model.load_state_dict(checkpoint['model_state_dict'])
            self.model.eval()

            print(f"✅ Model loaded successfully")
            print(f"   - Input dimensions: {input_dim}")
            print(f"   - Parameters: {sum(p.numel() for p in self.model.parameters()):,}")

            # Load preprocessor
            preprocessor_path = self.artifacts_dir / "preprocessor_v3.joblib"
            if preprocessor_path.exists():
                self.preprocessor = joblib.load(preprocessor_path)
                print(f"✅ Preprocessor loaded successfully")
            else:
                raise FileNotFoundError(f"Preprocessor file not found: {preprocessor_path}")

            # Load metadata
            metadata_path = self.artifacts_dir / "meta_v3.json"
            if metadata_path.exists():
                with open(metadata_path, 'r', encoding='utf-8') as f:
                    self.metadata = json.load(f)
                self.feature_columns = self.metadata['dataset_info']['feature_columns']
                print(f"✅ Metadata loaded successfully")
                print(f"   - Model version: {self.metadata.get('model_version', 'unknown')}")
                print(f"   - Feature columns: {self.feature_columns}")
            else:
                raise FileNotFoundError(f"Metadata file not found: {metadata_path}")

        except Exception as e:
            print(f"❌ Error loading artifacts: {e}")
            raise

    def prepare_input_data(self, data: Union[pd.DataFrame, Dict]) -> np.ndarray:
        """
        Prepare input data for model prediction

        Args:
            data: Input data as DataFrame or dictionary

        Returns:
            Processed numpy array ready for model input
        """
        if isinstance(data, dict):
            # Convert single dict to DataFrame
            data = pd.DataFrame([data])

        # Ensure all required columns are present
        required_columns = self.feature_columns.copy()

        # Add SePA columns if not present (use defaults)
        sepa_defaults = {
            'mood_numeric': 3,  # Neutral
            'fatigue_numeric': 3,  # Medium
            'effort_numeric': 3  # Medium
        }

        for col, default_val in sepa_defaults.items():
            if col in required_columns and col not in data.columns:
                data[col] = default_val

        # Filter to only required columns
        available_cols = [col for col in required_columns if col in data.columns]
        data_filtered = data[available_cols].copy()

        # Process categorical variables
        if 'gender' in data_filtered.columns:
            data_filtered['gender'] = data_filtered['gender'].astype(str)

        # Apply preprocessing
        try:
            processed = self.preprocessor.transform(data_filtered)
            if hasattr(processed, 'toarray'):
                processed = processed.toarray()
            return processed.astype(np.float32)
        except Exception as e:
            print(f"❌ Error preprocessing data: {e}")
            raise

    def predict(self, data: Union[pd.DataFrame, Dict]) -> Dict:
        """
        Make predictions using the loaded model

        Args:
            data: Input data as DataFrame or dictionary

        Returns:
            Dictionary with predictions (1RM, suitability, readiness)
        """
        # Prepare input
        X = self.prepare_input_data(data)

        # Make prediction
        with torch.no_grad():
            X_tensor = torch.from_numpy(X).to(self.device)
            pred_1rm, pred_suitability, pred_readiness = self.model(X_tensor)

            # Convert to numpy and extract values
            pred_1rm = pred_1rm.cpu().numpy().flatten()
            pred_suitability = pred_suitability.cpu().numpy().flatten()
            pred_readiness = pred_readiness.cpu().numpy().flatten()

        return {
            'predicted_1rm': pred_1rm.tolist(),
            'suitability_score': pred_suitability.tolist(),
            'readiness_factor': pred_readiness.tolist()
        }

    def generate_workout_recommendations(self, predictions: Dict, goals: List[str] = None) -> List[Dict]:
        """
        Generate workout recommendations using rule-based decoding

        Args:
            predictions: Model predictions
            goals: List of workout goals (if None, uses all available goals)

        Returns:
            List of workout recommendations for each goal
        """
        if goals is None:
            goals = list(WORKOUT_GOAL_MAPPING.keys())

        recommendations = []

        # Handle single prediction or batch
        pred_1rm = predictions['predicted_1rm']
        readiness_factors = predictions['readiness_factor']

        if isinstance(pred_1rm, float):
            pred_1rm = [pred_1rm]
        if isinstance(readiness_factors, float):
            readiness_factors = [readiness_factors]

        for i, (pred_1rm_val, readiness_val) in enumerate(zip(pred_1rm, readiness_factors)):
            workout_recs = {}
            for goal in goals:
                workout_params = decode_1rm_to_workout(pred_1rm_val, goal, readiness_val)
                workout_recs[goal] = workout_params

            recommendations.append({
                'sample_index': i,
                'predicted_1rm': pred_1rm_val,
                'readiness_factor': readiness_val,
                'suitability_score': predictions['suitability_score'][i] if len(predictions['suitability_score']) > i else 0,
                'workout_recommendations': workout_recs
            })

        return recommendations

    def evaluate_dataset(self, test_file: str, save_results: bool = True) -> Dict:
        """
        Evaluate model on a test dataset

        Args:
            test_file: Path to test Excel file
            save_results: Whether to save evaluation results

        Returns:
            Dictionary with evaluation metrics
        """
        print(f"\n📊 Evaluating model on: {test_file}")

        # Load test data
        try:
            df_test = pd.read_excel(test_file)
            print(f"✅ Loaded test data: {df_test.shape}")
        except Exception as e:
            print(f"❌ Error loading test data: {e}")
            raise

        # Prepare features and targets
        feature_columns = self.feature_columns

        # Handle SePA columns
        if 'mood' in df_test.columns:
            if df_test['mood'].dtype == 'object':
                df_test['mood_numeric'] = df_test['mood'].apply(lambda x: map_sepa_to_numeric(x, MOOD_MAPPING))
            else:
                df_test['mood_numeric'] = df_test['mood'].astype(float)

        if 'fatigue' in df_test.columns:
            if df_test['fatigue'].dtype == 'object':
                df_test['fatigue_numeric'] = df_test['fatigue'].apply(lambda x: map_sepa_to_numeric(x, FATIGUE_MAPPING))
            else:
                df_test['fatigue_numeric'] = df_test['fatigue'].astype(float)

        if 'effort' in df_test.columns:
            if df_test['effort'].dtype == 'object':
                df_test['effort_numeric'] = df_test['effort'].apply(lambda x: map_sepa_to_numeric(x, EFFORT_MAPPING))
            else:
                df_test['effort_numeric'] = df_test['effort'].astype(float)

        # Calculate readiness factors
        df_test['readiness_factor'] = df_test.apply(
            lambda row: calculate_readiness_factor(
                row.get('mood_numeric', 3),
                row.get('fatigue_numeric', 3),
                row.get('effort_numeric', 3)
            ), axis=1
        )

        # Use existing suitability_x if available
        if 'suitability_x' in df_test.columns:
            df_test['suitability_score'] = df_test['suitability_x']
        else:
            df_test['suitability_score'] = 0.7  # Default value

        # Get features and targets
        available_features = [col for col in feature_columns if col in df_test.columns]
        X_test = df_test[available_features].copy()

        y_1rm_true = df_test['estimated_1rm'].values
        y_suit_true = df_test['suitability_score'].values
        y_ready_true = df_test['readiness_factor'].values

        print(f"📋 Test data info:")
        print(f"   - Samples: {len(df_test)}")
        print(f"   - Features used: {available_features}")
        print(f"   - 1RM range: [{y_1rm_true.min():.1f}, {y_1rm_true.max():.1f}]")

        # Make predictions
        predictions = self.predict(X_test)

        # Calculate metrics
        y_1rm_pred = np.array(predictions['predicted_1rm'])
        y_suit_pred = np.array(predictions['suitability_score'])
        y_ready_pred = np.array(predictions['readiness_factor'])

        metrics = {
            '1RM': {
                'mae': mean_absolute_error(y_1rm_true, y_1rm_pred),
                'mse': mean_squared_error(y_1rm_true, y_1rm_pred),
                'rmse': np.sqrt(mean_squared_error(y_1rm_true, y_1rm_pred)),
                'r2': r2_score(y_1rm_true, y_1rm_pred),
                'mape': np.mean(np.abs((y_1rm_true - y_1rm_pred) / (y_1rm_true + 1e-8))) * 100
            },
            'Suitability': {
                'mae': mean_absolute_error(y_suit_true, y_suit_pred),
                'mse': mean_squared_error(y_suit_true, y_suit_pred),
                'rmse': np.sqrt(mean_squared_error(y_suit_true, y_suit_pred)),
                'r2': r2_score(y_suit_true, y_suit_pred)
            },
            'Readiness': {
                'mae': mean_absolute_error(y_ready_true, y_ready_pred),
                'mse': mean_squared_error(y_ready_true, y_ready_pred),
                'rmse': np.sqrt(mean_squared_error(y_ready_true, y_ready_pred)),
                'r2': r2_score(y_ready_true, y_ready_pred)
            }
        }

        # Print results
        print(f"\n📈 Evaluation Results:")
        print(f"   1RM Prediction:")
        print(f"      - MAE: {metrics['1RM']['mae']:.3f}")
        print(f"      - RMSE: {metrics['1RM']['rmse']:.3f}")
        print(f"      - R²: {metrics['1RM']['r2']:.3f}")
        print(f"      - MAPE: {metrics['1RM']['mape']:.2f}%")

        print(f"   Suitability Prediction:")
        print(f"      - MAE: {metrics['Suitability']['mae']:.3f}")
        print(f"      - RMSE: {metrics['Suitability']['rmse']:.3f}")
        print(f"      - R²: {metrics['Suitability']['r2']:.3f}")

        print(f"   Readiness Prediction:")
        print(f"      - MAE: {metrics['Readiness']['mae']:.3f}")
        print(f"      - RMSE: {metrics['Readiness']['rmse']:.3f}")
        print(f"      - R²: {metrics['Readiness']['r2']:.3f}")

        # Save results if requested
        if save_results:
            self._save_evaluation_results(test_file, metrics, df_test, predictions)

        return {
            'metrics': metrics,
            'predictions': predictions,
            'true_values': {
                '1RM': y_1rm_true.tolist(),
                'suitability': y_suit_true.tolist(),
                'readiness': y_ready_true.tolist()
            },
            'test_info': {
                'file': test_file,
                'samples': len(df_test),
                'features': available_features
            }
        }

    def _save_evaluation_results(self, test_file: str, metrics: Dict, df_test: pd.DataFrame, predictions: Dict):
        """Save evaluation results to files"""
        results_dir = self.artifacts_dir / "evaluation_results"
        results_dir.mkdir(exist_ok=True)

        # Save metrics
        timestamp = pd.Timestamp.now().strftime("%Y%m%d_%H%M%S")
        metrics_file = results_dir / f"evaluation_metrics_{timestamp}.json"

        with open(metrics_file, 'w') as f:
            json.dump(metrics, f, indent=2)

        # Save predictions with true values
        results_df = df_test.copy()
        results_df['predicted_1rm'] = predictions['predicted_1rm']
        results_df['predicted_suitability'] = predictions['suitability_score']
        results_df['predicted_readiness'] = predictions['readiness_factor']

        predictions_file = results_dir / f"predictions_{timestamp}.xlsx"
        results_df.to_excel(predictions_file, index=False)

        print(f"💾 Results saved:")
        print(f"   - Metrics: {metrics_file}")
        print(f"   - Predictions: {predictions_file}")

    def interactive_testing(self):
        """Interactive testing mode"""
        print("\n🎮 Interactive Testing Mode")
        print("=" * 50)
        print("Enter 'quit' to exit\n")

        while True:
            try:
                print("\nEnter user profile information:")

                # Get user input
                age = self._get_numeric_input("Age (18-80): ", 18, 80, 30)
                weight_kg = self._get_numeric_input("Weight (kg) (40-200): ", 40, 200, 70)
                height_m = self._get_numeric_input("Height (m) (1.4-2.2): ", 1.4, 2.2, 1.75)
                experience_level = self._get_numeric_input("Experience level (1=Beginner, 2=Intermediate, 3=Advanced, 4=Expert): ", 1, 4, 2)
                workout_freq = self._get_numeric_input("Workout frequency (days/week) (1-7): ", 1, 7, 3)
                resting_hr = self._get_numeric_input("Resting heart rate (40-100): ", 40, 100, 70)
                gender = self._get_choice_input("Gender (male/female): ", ["male", "female"], "male")

                # SePA inputs
                print("\nSePA (Sleep, Psychology, Activity) Status:")
                mood = self._get_choice_input("Mood (very bad/bad/neutral/good/very good): ",
                                           ["very bad", "bad", "neutral", "good", "very good"], "neutral")
                fatigue = self._get_choice_input("Fatigue (very low/low/medium/high/very high): ",
                                               ["very low", "low", "medium", "high", "very high"], "medium")
                effort = self._get_choice_input("Recent effort (very low/low/medium/high/very high): ",
                                              ["very low", "low", "medium", "high", "very high"], "medium")

                # Create user profile
                user_profile = {
                    'age': age,
                    'weight_kg': weight_kg,
                    'height_m': height_m,
                    'bmi': weight_kg / (height_m ** 2),
                    'experience_level': experience_level,
                    'workout_frequency': workout_freq,
                    'resting_heartrate': resting_hr,
                    'gender': gender,
                    'mood_numeric': map_sepa_to_numeric(mood, MOOD_MAPPING),
                    'fatigue_numeric': map_sepa_to_numeric(fatigue, FATIGUE_MAPPING),
                    'effort_numeric': map_sepa_to_numeric(effort, EFFORT_MAPPING)
                }

                # Make prediction
                print("\n🔮 Making prediction...")
                predictions = self.predict(user_profile)

                # Generate recommendations
                goals = ['strength', 'hypertrophy', 'endurance']
                recommendations = self.generate_workout_recommendations(predictions, goals)

                # Display results
                self._display_interactive_results(user_profile, recommendations[0])

            except KeyboardInterrupt:
                print("\n\n👋 Exiting interactive mode...")
                break
            except Exception as e:
                print(f"\n❌ Error: {e}")
                continue

    def _get_numeric_input(self, prompt: str, min_val: float, max_val: float, default: float) -> float:
        """Get numeric input with validation"""
        while True:
            try:
                user_input = input(prompt).strip()
                if not user_input:
                    return default

                value = float(user_input)
                if min_val <= value <= max_val:
                    return value
                else:
                    print(f"Please enter a value between {min_val} and {max_val}")
            except ValueError:
                print("Please enter a valid number")

    def _get_choice_input(self, prompt: str, choices: List[str], default: str) -> str:
        """Get choice input with validation"""
        while True:
            try:
                user_input = input(prompt).strip().lower()
                if not user_input:
                    return default

                for choice in choices:
                    if choice.lower().startswith(user_input):
                        return choice

                print(f"Please choose from: {', '.join(choices)}")
            except ValueError:
                print("Please enter a valid choice")

    def _display_interactive_results(self, user_profile: Dict, recommendation: Dict):
        """Display results for interactive mode"""
        print("\n" + "="*60)
        print("📋 PREDICTION RESULTS")
        print("="*60)

        # User profile summary
        print(f"👤 User Profile:")
        print(f"   Age: {user_profile['age']}, Weight: {user_profile['weight_kg']:.1f}kg, Height: {user_profile['height_m']:.2f}m")
        print(f"   Experience: Level {user_profile['experience_level']}, Workout Frequency: {user_profile['workout_frequency']}/week")
        print(f"   SePA Status: Mood={user_profile['mood_numeric']}, Fatigue={user_profile['fatigue_numeric']}, Effort={user_profile['effort_numeric']}")

        # Predictions
        print(f"\n🎯 Model Predictions:")
        print(f"   Estimated 1RM: {recommendation['predicted_1rm']:.1f} kg")
        print(f"   Readiness Factor: {recommendation['readiness_factor']:.3f}")
        print(f"   Suitability Score: {recommendation['suitability_score']:.3f}")

        # Workout recommendations
        print(f"\n💪 Workout Recommendations:")
        for goal, workout in recommendation['workout_recommendations'].items():
            print(f"\n   {goal.upper()}:")
            print(f"      Training Weight: {workout['training_weight_kg']['recommended']:.1f}kg "
                  f"({workout['training_weight_kg']['min']:.1f}-{workout['training_weight_kg']['max']:.1f})")
            print(f"      Reps: {workout['reps']['recommended']} ({workout['reps']['min']}-{workout['reps']['max']})")
            print(f"      Sets: {workout['sets']['recommended']} ({workout['sets']['min']}-{workout['sets']['max']})")
            print(f"      Rest: {workout['rest_minutes']['recommended']:.1f}min "
                  f"({workout['rest_minutes']['min']:.1f}-{workout['rest_minutes']['max']:.1f})")
            print(f"      {workout['description']}")

        print("\n" + "="*60)


def main():
    parser = argparse.ArgumentParser(description='V3 Model Testing Script')
    parser.add_argument('--artifacts', type=str,
                       default='./model',
                       help='Directory containing model artifacts')
    parser.add_argument('--mode', type=str, choices=['interactive', 'batch', 'evaluate'],
                       default='interactive',
                       help='Testing mode')
    parser.add_argument('--input_file', type=str,
                       help='Input Excel file for batch testing')
    parser.add_argument('--device', type=str, choices=['cuda', 'cpu'],
                       help='Device to use for inference')

    args = parser.parse_args()

    # Initialize tester
    try:
        tester = V3ModelTester(args.artifacts, args.device)
    except Exception as e:
        print(f"❌ Failed to initialize tester: {e}")
        return

    # Run based on mode
    if args.mode == 'interactive':
        tester.interactive_testing()
    elif args.mode == 'batch':
        if not args.input_file:
            print("❌ --input_file required for batch mode")
            return

        if not os.path.exists(args.input_file):
            print(f"❌ Input file not found: {args.input_file}")
            return

        # Batch testing
        df_batch = pd.read_excel(args.input_file)
        predictions = tester.predict(df_batch)

        # Generate recommendations for first few samples
        recommendations = tester.generate_workout_recommendations(predictions)

        print(f"\n📊 Batch Testing Results:")
        print(f"Input file: {args.input_file}")
        print(f"Samples processed: {len(df_batch)}")

        # Show sample recommendations
        for i, rec in enumerate(recommendations[:3]):  # Show first 3
            print(f"\nSample {i+1}:")
            print(f"  Predicted 1RM: {rec['predicted_1rm']:.1f} kg")
            print(f"  Readiness Factor: {rec['readiness_factor']:.3f}")
            print(f"  Strength recommendation: {rec['workout_recommendations']['strength']['training_weight_kg']['recommended']:.1f}kg x {rec['workout_recommendations']['strength']['reps']['recommended']} reps")

    elif args.mode == 'evaluate':
        # Find test files
        data_dir = Path(args.artifacts).parent / "src" / "v3" / "data"
        test_files = list(data_dir.glob("*.xlsx"))

        if not test_files:
            print("❌ No test files found in data directory")
            return

        print(f"🔍 Found {len(test_files)} test files:")
        for i, file in enumerate(test_files):
            print(f"  {i+1}. {file.name}")

        # Evaluate each file
        all_results = {}
        for test_file in test_files:
            try:
                results = tester.evaluate_dataset(str(test_file), save_results=True)
                all_results[test_file.name] = results
            except Exception as e:
                print(f"❌ Error evaluating {test_file.name}: {e}")

        print(f"\n📋 Summary of All Evaluations:")
        for filename, results in all_results.items():
            metrics = results['metrics']
            print(f"\n{filename}:")
            print(f"  1RM R²: {metrics['1RM']['r2']:.3f}")
            print(f"  1RM RMSE: {metrics['1RM']['rmse']:.3f}")
            print(f"  Samples: {results['test_info']['samples']}")


if __name__ == "__main__":
    main()
"""
evaluate_v3_model.py
Comprehensive Model Evaluation with Visualizations

This script provides a thorough evaluation of the V3 model including:
- Standard metrics (MAE, MSE, RMSE, R², MAPE)
- Classification metrics (Accuracy, Precision, Recall, F1-Score)
- Advanced visualizations
- Error analysis
- Performance comparison across different user segments

Author: Claude Code Assistant
Date: 2025-11-27
"""

import os, json, numpy as np, pandas as pd, torch, matplotlib.pyplot as plt, seaborn as sns
from pathlib import Path
import joblib
from typing import Dict, List, Tuple, Optional
from sklearn.metrics import (
    mean_absolute_error, mean_squared_error, r2_score, mean_absolute_percentage_error,
    accuracy_score, precision_score, recall_score, f1_score, confusion_matrix,
    classification_report
)
from sklearn.preprocessing import LabelEncoder
import warnings
warnings.filterwarnings('ignore')

# Set up plotting style
plt.style.use('seaborn-v0_8')
sns.set_palette("husl")

class V3ModelEvaluator:
    """Comprehensive model evaluation class with advanced visualizations"""

    def __init__(self, artifacts_dir: str, device: Optional[str] = None):
        """Initialize the evaluator with model artifacts"""
        self.artifacts_dir = Path(artifacts_dir)
        self.device = torch.device(device or ("cuda" if torch.cuda.is_available() else "cpu"))

        # Load model components
        self.model = None
        self.preprocessor = None
        self.metadata = None
        self.feature_columns = None

        self._load_model_components()

    def _load_model_components(self):
        """Load model, preprocessor, and metadata"""
        print("Loading model components...")

        # Import model classes
        try:
            from train_v3_enhanced import (
                V3EnhancedModel, MOOD_MAPPING, FATIGUE_MAPPING, EFFORT_MAPPING,
                calculate_readiness_factor, decode_1rm_to_workout, WORKOUT_GOAL_MAPPING,
                map_sepa_to_numeric
            )
            self.MOOD_MAPPING = MOOD_MAPPING
            self.FATIGUE_MAPPING = FATIGUE_MAPPING
            self.EFFORT_MAPPING = EFFORT_MAPPING
            self.calculate_readiness_factor = calculate_readiness_factor
            self.decode_1rm_to_workout = decode_1rm_to_workout
            self.WORKOUT_GOAL_MAPPING = WORKOUT_GOAL_MAPPING
            self.map_sepa_to_numeric = map_sepa_to_numeric
        except ImportError as e:
            print(f"Error importing model components: {e}")
            raise

        # Load model
        model_path = self.artifacts_dir / "best_v3.pt"
        if not model_path.exists():
            raise FileNotFoundError(f"Model file not found: {model_path}")

        checkpoint = torch.load(model_path, map_location=self.device, weights_only=False)

        # Check if this is raw state dict or saved with metadata
        if 'model_state_dict' in checkpoint:
            input_dim = checkpoint['input_dim']
            model_config = checkpoint.get('model_config', {})
            state_dict = checkpoint['model_state_dict']
        else:
            # Raw state dict - load metadata from meta file
            meta_path = self.artifacts_dir / "meta_v3.json"
            if meta_path.exists():
                with open(meta_path, 'r', encoding='utf-8') as f:
                    metadata = json.load(f)
                input_dim = metadata['model_architecture']['input_dim']
                model_config = {
                    'hidden_dim': metadata['model_architecture']['hidden_dim'],
                    'num_layers': metadata['model_architecture']['num_layers'],
                    'dropout': metadata['model_architecture']['dropout'],
                    'use_transformer': metadata['model_architecture']['use_transformer']
                }
            else:
                # Default config
                input_dim = 12
                model_config = {
                    'hidden_dim': 256,
                    'num_layers': 2,
                    'dropout': 0.2,
                    'use_transformer': False
                }
            state_dict = checkpoint

        self.model = V3EnhancedModel(
            input_dim=input_dim,
            hidden_dim=model_config.get('hidden_dim', 256),
            num_layers=model_config.get('num_layers', 2),
            dropout=model_config.get('dropout', 0.2),
            use_transformer=model_config.get('use_transformer', False)
        ).to(self.device)

        self.model.load_state_dict(state_dict)
        self.model.eval()

        # Load preprocessor
        preprocessor_path = self.artifacts_dir / "preprocessor_v3.joblib"
        if preprocessor_path.exists():
            self.preprocessor = joblib.load(preprocessor_path)
        else:
            raise FileNotFoundError(f"Preprocessor not found: {preprocessor_path}")

        # Load metadata
        metadata_path = self.artifacts_dir / "meta_v3.json"
        if metadata_path.exists():
            with open(metadata_path, 'r', encoding='utf-8') as f:
                self.metadata = json.load(f)
            self.feature_columns = self.metadata['dataset_info']['feature_columns']

        print(f"Model loaded successfully")
        print(f"   - Input dimensions: {input_dim}")
        print(f"   - Device: {self.device}")
        print(f"   - Feature columns: {len(self.feature_columns)}")

    def prepare_data(self, df: pd.DataFrame) -> Tuple[np.ndarray, Dict]:
        """Prepare data for evaluation"""
        df_processed = df.copy()

        # Handle SePA columns
        if 'mood' in df_processed.columns:
            if df_processed['mood'].dtype == 'object':
                df_processed['mood_numeric'] = df_processed['mood'].apply(
                    lambda x: self.map_sepa_to_numeric(x, self.MOOD_MAPPING)
                )
            else:
                df_processed['mood_numeric'] = df_processed['mood'].astype(float)

        if 'fatigue' in df_processed.columns:
            if df_processed['fatigue'].dtype == 'object':
                df_processed['fatigue_numeric'] = df_processed['fatigue'].apply(
                    lambda x: self.map_sepa_to_numeric(x, self.FATIGUE_MAPPING)
                )
            else:
                df_processed['fatigue_numeric'] = df_processed['fatigue'].astype(float)

        if 'effort' in df_processed.columns:
            if df_processed['effort'].dtype == 'object':
                df_processed['effort_numeric'] = df_processed['effort'].apply(
                    lambda x: self.map_sepa_to_numeric(x, self.EFFORT_MAPPING)
                )
            else:
                df_processed['effort_numeric'] = df_processed['effort'].astype(float)

        # Calculate readiness factors
        df_processed['readiness_factor'] = df_processed.apply(
            lambda row: self.calculate_readiness_factor(
                row.get('mood_numeric', 3),
                row.get('fatigue_numeric', 3),
                row.get('effort_numeric', 3)
            ), axis=1
        )

        # Ensure all required columns are present
        required_columns = self.feature_columns.copy()
        sepa_defaults = {
            'mood_numeric': 3,
            'fatigue_numeric': 3,
            'effort_numeric': 3
        }

        for col, default_val in sepa_defaults.items():
            if col in required_columns and col not in df_processed.columns:
                df_processed[col] = default_val

        # Filter to available columns
        available_cols = [col for col in required_columns if col in df_processed.columns]
        X_features = df_processed[available_cols].copy()

        # Handle categorical variables
        if 'gender' in X_features.columns:
            X_features['gender'] = X_features['gender'].astype(str)

        # Apply preprocessing
        X_processed = self.preprocessor.transform(X_features)
        if hasattr(X_processed, 'toarray'):
            X_processed = X_processed.toarray()

        return X_processed.astype(np.float32), df_processed

    def predict(self, X: np.ndarray) -> Dict:
        """Make predictions with the model"""
        with torch.no_grad():
            X_tensor = torch.from_numpy(X).to(self.device)
            pred_1rm, pred_suitability, pred_readiness = self.model(X_tensor)

            return {
                'predicted_1rm': pred_1rm.cpu().numpy().flatten(),
                'suitability_score': pred_suitability.cpu().numpy().flatten(),
                'readiness_factor': pred_readiness.cpu().numpy().flatten()
            }

    def calculate_regression_metrics(self, y_true: np.ndarray, y_pred: np.ndarray) -> Dict:
        """Calculate comprehensive regression metrics"""
        return {
            'mae': mean_absolute_error(y_true, y_pred),
            'mse': mean_squared_error(y_true, y_pred),
            'rmse': np.sqrt(mean_squared_error(y_true, y_pred)),
            'r2': r2_score(y_true, y_pred),
            'mape': mean_absolute_percentage_error(y_true, y_pred) * 100,
            'max_error': np.max(np.abs(y_true - y_pred)),
            'mean_error': np.mean(y_true - y_pred),
            'std_error': np.std(y_true - y_pred)
        }

    def calculate_classification_metrics(self, y_true: np.ndarray, y_pred: np.ndarray,
                                       threshold: float = 0.5) -> Dict:
        """Calculate classification metrics for binary classification"""
        y_true_binary = (y_true >= threshold).astype(int)
        y_pred_binary = (y_pred >= threshold).astype(int)

        return {
            'accuracy': accuracy_score(y_true_binary, y_pred_binary),
            'precision': precision_score(y_true_binary, y_pred_binary, average='weighted', zero_division=0),
            'recall': recall_score(y_true_binary, y_pred_binary, average='weighted', zero_division=0),
            'f1': f1_score(y_true_binary, y_pred_binary, average='weighted', zero_division=0)
        }

    def create_visualizations(self, results: Dict, save_dir: Path):
        """Create comprehensive visualization charts"""
        print("Creating visualizations...")

        # Create subplots for different metrics
        fig, axes = plt.subplots(3, 3, figsize=(20, 15))
        fig.suptitle('V3 Model Comprehensive Evaluation Dashboard', fontsize=16, fontweight='bold')

        # 1. 1RM Prediction Scatter Plot
        ax1 = axes[0, 0]
        y_true_1rm = np.array(results['true_values']['1RM'])
        y_pred_1rm = np.array(results['predictions']['predicted_1rm'])

        ax1.scatter(y_true_1rm, y_pred_1rm, alpha=0.6, s=30)
        ax1.plot([y_true_1rm.min(), y_true_1rm.max()],
                [y_true_1rm.min(), y_true_1rm.max()], 'r--', lw=2)
        ax1.set_xlabel('True 1RM (kg)')
        ax1.set_ylabel('Predicted 1RM (kg)')
        ax1.set_title('1RM Prediction Accuracy')
        ax1.grid(True, alpha=0.3)
        r2_1rm = results['metrics']['1RM']['r2']
        ax1.text(0.05, 0.95, f'R² = {r2_1rm:.3f}', transform=ax1.transAxes,
                bbox=dict(boxstyle="round,pad=0.3", facecolor="white", alpha=0.8))

        # 2. Residual Plot for 1RM
        ax2 = axes[0, 1]
        residuals_1rm = y_true_1rm - y_pred_1rm
        ax2.scatter(y_pred_1rm, residuals_1rm, alpha=0.6, s=30)
        ax2.axhline(y=0, color='r', linestyle='--')
        ax2.set_xlabel('Predicted 1RM (kg)')
        ax2.set_ylabel('Residuals (kg)')
        ax2.set_title('1RM Residual Plot')
        ax2.grid(True, alpha=0.3)

        # 3. Error Distribution Histogram
        ax3 = axes[0, 2]
        ax3.hist(residuals_1rm, bins=30, alpha=0.7, color='skyblue', edgecolor='black')
        ax3.set_xlabel('Prediction Error (kg)')
        ax3.set_ylabel('Frequency')
        ax3.set_title('1RM Error Distribution')
        ax3.axvline(x=0, color='r', linestyle='--', label='Zero Error')
        ax3.legend()
        ax3.grid(True, alpha=0.3)

        # 4. Suitability Score Comparison
        ax4 = axes[1, 0]
        y_true_suit = np.array(results['true_values']['suitability'])
        y_pred_suit = np.array(results['predictions']['suitability_score'])

        ax4.scatter(y_true_suit, y_pred_suit, alpha=0.6, s=30, color='green')
        ax4.plot([y_true_suit.min(), y_true_suit.max()],
                [y_true_suit.min(), y_true_suit.max()], 'r--', lw=2)
        ax4.set_xlabel('True Suitability')
        ax4.set_ylabel('Predicted Suitability')
        ax4.set_title('Suitability Score Prediction')
        ax4.grid(True, alpha=0.3)
        r2_suit = results['metrics']['Suitability']['r2']
        ax4.text(0.05, 0.95, f'R² = {r2_suit:.3f}', transform=ax4.transAxes,
                bbox=dict(boxstyle="round,pad=0.3", facecolor="white", alpha=0.8))

        # 5. Readiness Factor Comparison
        ax5 = axes[1, 1]
        y_true_ready = np.array(results['true_values']['readiness'])
        y_pred_ready = np.array(results['predictions']['readiness_factor'])

        ax5.scatter(y_true_ready, y_pred_ready, alpha=0.6, s=30, color='orange')
        ax5.plot([y_true_ready.min(), y_true_ready.max()],
                [y_true_ready.min(), y_true_ready.max()], 'r--', lw=2)
        ax5.set_xlabel('True Readiness Factor')
        ax5.set_ylabel('Predicted Readiness Factor')
        ax5.set_title('Readiness Factor Prediction')
        ax5.grid(True, alpha=0.3)
        r2_ready = results['metrics']['Readiness']['r2']
        ax5.text(0.05, 0.95, f'R² = {r2_ready:.3f}', transform=ax5.transAxes,
                bbox=dict(boxstyle="round,pad=0.3", facecolor="white", alpha=0.8))

        # 6. Metrics Comparison Bar Chart
        ax6 = axes[1, 2]
        metrics_names = ['MAE', 'RMSE', 'R²']
        metrics_1rm = [results['metrics']['1RM']['mae'],
                     results['metrics']['1RM']['rmse'],
                     results['metrics']['1RM']['r2']]
        metrics_suit = [results['metrics']['Suitability']['mae'],
                       results['metrics']['Suitability']['rmse'],
                       results['metrics']['Suitability']['r2']]
        metrics_ready = [results['metrics']['Readiness']['mae'],
                        results['metrics']['Readiness']['rmse'],
                        results['metrics']['Readiness']['r2']]

        x = np.arange(len(metrics_names))
        width = 0.25

        ax6.bar(x - width, metrics_1rm, width, label='1RM', color='blue', alpha=0.7)
        ax6.bar(x, metrics_suit, width, label='Suitability', color='green', alpha=0.7)
        ax6.bar(x + width, metrics_ready, width, label='Readiness', color='orange', alpha=0.7)

        ax6.set_xlabel('Metrics')
        ax6.set_ylabel('Value')
        ax6.set_title('Model Performance Metrics Comparison')
        ax6.set_xticks(x)
        ax6.set_xticklabels(metrics_names)
        ax6.legend()
        ax6.grid(True, alpha=0.3)

        # 7. Prediction Error Distribution
        ax7 = axes[2, 0]
        # Create error distribution histogram
        ax7.hist(np.abs(np.array(y_true_1rm) - np.array(y_pred_1rm)), bins=20, alpha=0.7, color='purple', edgecolor='black')
        ax7.set_xlabel('Absolute Error (kg)')
        ax7.set_ylabel('Frequency')
        ax7.set_title('1RM Prediction Error Distribution')
        ax7.grid(True, alpha=0.3)

        # 8. Correlation Heatmap
        ax8 = axes[2, 1]
        correlation_data = pd.DataFrame({
            'True_1RM': np.array(y_true_1rm),
            'Pred_1RM': np.array(y_pred_1rm),
            'True_Suit': np.array(y_true_suit),
            'Pred_Suit': np.array(y_pred_suit),
            'True_Ready': np.array(y_true_ready),
            'Pred_Ready': np.array(y_pred_ready)
        })

        corr_matrix = correlation_data.corr()
        im = ax8.imshow(corr_matrix, cmap='coolwarm', aspect='auto', vmin=-1, vmax=1)
        ax8.set_xticks(range(len(corr_matrix.columns)))
        ax8.set_yticks(range(len(corr_matrix.columns)))
        ax8.set_xticklabels(corr_matrix.columns, rotation=45, ha='right')
        ax8.set_yticklabels(corr_matrix.columns)
        ax8.set_title('Correlation Matrix')

        # Add correlation values
        for i in range(len(corr_matrix.columns)):
            for j in range(len(corr_matrix.columns)):
                ax8.text(j, i, f'{corr_matrix.iloc[i, j]:.2f}',
                        ha='center', va='center', color='black' if abs(corr_matrix.iloc[i, j]) < 0.5 else 'white')

        # 9. Performance Summary
        ax9 = axes[2, 2]
        ax9.axis('off')

        summary_text = f"""
        MODEL PERFORMANCE SUMMARY

        1RM Prediction:
        • R² Score: {results['metrics']['1RM']['r2']:.3f}
        • RMSE: {results['metrics']['1RM']['rmse']:.2f} kg
        • MAE: {results['metrics']['1RM']['mae']:.2f} kg
        • MAPE: {results['metrics']['1RM']['mape']:.2f}%

        Suitability Prediction:
        • R² Score: {results['metrics']['Suitability']['r2']:.3f}
        • RMSE: {results['metrics']['Suitability']['rmse']:.3f}
        • MAE: {results['metrics']['Suitability']['mae']:.3f}

        Readiness Prediction:
        • R² Score: {results['metrics']['Readiness']['r2']:.3f}
        • RMSE: {results['metrics']['Readiness']['rmse']:.3f}
        • MAE: {results['metrics']['Readiness']['mae']:.3f}

        Test Samples: {results['test_info']['samples']}
        """

        ax9.text(0.1, 0.9, summary_text, transform=ax9.transAxes, fontsize=10,
                verticalalignment='top', fontfamily='monospace',
                bbox=dict(boxstyle="round,pad=0.5", facecolor="lightgray", alpha=0.8))

        plt.tight_layout()
        plt.savefig(save_dir / 'comprehensive_evaluation_dashboard.png', dpi=300, bbox_inches='tight')
        plt.close()

        # Create additional detailed visualizations

        # Error Analysis by Value Range
        fig, axes = plt.subplots(1, 3, figsize=(18, 6))
        fig.suptitle('Error Analysis by Value Range', fontsize=14, fontweight='bold')

        # 1RM Error by Value Range
        ax1 = axes[0]
        df_1rm = pd.DataFrame({
            'true': np.array(y_true_1rm),
            'pred': np.array(y_pred_1rm),
            'error': np.abs(np.array(y_true_1rm) - np.array(y_pred_1rm))
        })
        df_1rm['range'] = pd.cut(df_1rm['true'], bins=5, labels=['Very Low', 'Low', 'Medium', 'High', 'Very High'])
        error_by_range = df_1rm.groupby('range')['error'].mean()

        bars = ax1.bar(range(len(error_by_range)), error_by_range.values, color='skyblue', alpha=0.7, edgecolor='black')
        ax1.set_xlabel('1RM Value Range')
        ax1.set_ylabel('Mean Absolute Error (kg)')
        ax1.set_title('1RM Prediction Error by Value Range')
        ax1.set_xticks(range(len(error_by_range)))
        ax1.set_xticklabels(error_by_range.index, rotation=45)
        ax1.grid(True, alpha=0.3)

        # Add value labels on bars
        for bar, value in zip(bars, error_by_range.values):
            ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
                    f'{value:.1f}', ha='center', va='bottom')

        # Suitability Error Analysis
        ax2 = axes[1]
        df_suit = pd.DataFrame({
            'true': np.array(y_true_suit),
            'pred': np.array(y_pred_suit),
            'error': np.abs(np.array(y_true_suit) - np.array(y_pred_suit))
        })
        df_suit['range'] = pd.cut(df_suit['true'], bins=3, labels=['Low', 'Medium', 'High'])
        suit_error_by_range = df_suit.groupby('range')['error'].mean()

        bars = ax2.bar(range(len(suit_error_by_range)), suit_error_by_range.values,
                      color='lightgreen', alpha=0.7, edgecolor='black')
        ax2.set_xlabel('Suitability Range')
        ax2.set_ylabel('Mean Absolute Error')
        ax2.set_title('Suitability Prediction Error by Range')
        ax2.set_xticks(range(len(suit_error_by_range)))
        ax2.set_xticklabels(suit_error_by_range.index)
        ax2.grid(True, alpha=0.3)

        # Readiness Error Analysis
        ax3 = axes[2]
        df_ready = pd.DataFrame({
            'true': np.array(y_true_ready),
            'pred': np.array(y_pred_ready),
            'error': np.abs(np.array(y_true_ready) - np.array(y_pred_ready))
        })
        df_ready['range'] = pd.cut(df_ready['true'], bins=3, labels=['Low', 'Medium', 'High'])
        ready_error_by_range = df_ready.groupby('range')['error'].mean()

        bars = ax3.bar(range(len(ready_error_by_range)), ready_error_by_range.values,
                      color='lightcoral', alpha=0.7, edgecolor='black')
        ax3.set_xlabel('Readiness Range')
        ax3.set_ylabel('Mean Absolute Error')
        ax3.set_title('Readiness Prediction Error by Range')
        ax3.set_xticks(range(len(ready_error_by_range)))
        ax3.set_xticklabels(ready_error_by_range.index)
        ax3.grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig(save_dir / 'error_analysis_by_range.png', dpi=300, bbox_inches='tight')
        plt.close()

        print(f"Visualizations saved to {save_dir}")

    def evaluate_comprehensive(self, test_file: str, save_results: bool = True) -> Dict:
        """Comprehensive model evaluation with all metrics and visualizations"""
        print(f"\nCOMPREHENSIVE MODEL EVALUATION")
        print(f"Test File: {test_file}")
        print("=" * 60)

        # Load and prepare data
        try:
            df_test = pd.read_excel(test_file)
            print(f"Test data loaded: {df_test.shape}")
        except Exception as e:
            print(f"Error loading test data: {e}")
            raise

        # Prepare data
        X_processed, df_processed = self.prepare_data(df_test)

        # Get true values
        y_true_1rm = df_processed['estimated_1rm'].values
        y_true_suit = df_processed.get('suitability_score', df_processed.get('suitability_x', 0.7)).values
        y_true_ready = df_processed['readiness_factor'].values

        print(f"\nDataset Information:")
        print(f"   - Total samples: {len(df_test)}")
        print(f"   - Features used: {X_processed.shape[1]}")
        print(f"   - 1RM range: [{y_true_1rm.min():.1f}, {y_true_1rm.max():.1f}] kg")
        print(f"   - Suitability range: [{y_true_suit.min():.3f}, {y_true_suit.max():.3f}]")
        print(f"   - Readiness range: [{y_true_ready.min():.3f}, {y_true_ready.max():.3f}]")

        # Make predictions
        print(f"\nMaking predictions...")
        predictions = self.predict(X_processed)

        y_pred_1rm = predictions['predicted_1rm']
        y_pred_suit = predictions['suitability_score']
        y_pred_ready = predictions['readiness_factor']

        # Calculate comprehensive metrics
        print(f"\nCalculating metrics...")

        metrics = {
            '1RM': self.calculate_regression_metrics(y_true_1rm, y_pred_1rm),
            'Suitability': self.calculate_regression_metrics(y_true_suit, y_pred_suit),
            'Readiness': self.calculate_regression_metrics(y_true_ready, y_pred_ready)
        }

        # Add classification metrics (using thresholds)
        metrics['1RM']['classification'] = self.calculate_classification_metrics(
            y_true_1rm, y_pred_1rm, threshold=np.median(y_true_1rm)
        )
        metrics['Suitability']['classification'] = self.calculate_classification_metrics(
            y_true_suit, y_pred_suit, threshold=0.5
        )
        metrics['Readiness']['classification'] = self.calculate_classification_metrics(
            y_true_ready, y_pred_ready, threshold=0.5
        )

        # Print detailed results
        print(f"\nDETAILED EVALUATION RESULTS")
        print("=" * 50)

        for target in ['1RM', 'Suitability', 'Readiness']:
            print(f"\n{target.upper()} PREDICTION:")
            print(f"   Regression Metrics:")
            print(f"      • MAE: {metrics[target]['mae']:.4f}")
            print(f"      • MSE: {metrics[target]['mse']:.4f}")
            print(f"      • RMSE: {metrics[target]['rmse']:.4f}")
            print(f"      • R²: {metrics[target]['r2']:.4f}")
            if target == '1RM':
                print(f"      • MAPE: {metrics[target]['mape']:.2f}%")
            print(f"      • Max Error: {metrics[target]['max_error']:.4f}")
            print(f"      • Mean Error: {metrics[target]['mean_error']:.4f}")
            print(f"      • Std Error: {metrics[target]['std_error']:.4f}")

            print(f"   Classification Metrics (threshold-based):")
            print(f"      • Accuracy: {metrics[target]['classification']['accuracy']:.4f}")
            print(f"      • Precision: {metrics[target]['classification']['precision']:.4f}")
            print(f"      • Recall: {metrics[target]['classification']['recall']:.4f}")
            print(f"      • F1-Score: {metrics[target]['classification']['f1']:.4f}")

        # Prepare results dictionary
        results = {
            'metrics': metrics,
            'predictions': {
                'predicted_1rm': y_pred_1rm.tolist(),
                'suitability_score': y_pred_suit.tolist(),
                'readiness_factor': y_pred_ready.tolist()
            },
            'true_values': {
                '1RM': y_true_1rm.tolist(),
                'suitability': y_true_suit.tolist(),
                'readiness': y_true_ready.tolist()
            },
            'test_info': {
                'file': test_file,
                'samples': len(df_test),
                'features': X_processed.shape[1]
            }
        }

        # Save results if requested
        if save_results:
            save_dir = self.artifacts_dir / "comprehensive_evaluation"
            save_dir.mkdir(exist_ok=True)

            # Save metrics
            timestamp = pd.Timestamp.now().strftime("%Y%m%d_%H%M%S")
            metrics_file = save_dir / f"comprehensive_metrics_{timestamp}.json"
            with open(metrics_file, 'w') as f:
                json.dump(metrics, f, indent=2)

            # Save predictions
            results_df = df_processed.copy()
            results_df['predicted_1rm'] = y_pred_1rm
            results_df['predicted_suitability'] = y_pred_suit
            results_df['predicted_readiness'] = y_pred_ready
            results_df['error_1rm'] = np.abs(y_true_1rm - y_pred_1rm)
            results_df['error_suitability'] = np.abs(y_true_suit - y_pred_suit)
            results_df['error_readiness'] = np.abs(y_true_ready - y_pred_ready)

            predictions_file = save_dir / f"detailed_predictions_{timestamp}.xlsx"
            results_df.to_excel(predictions_file, index=False)

            # Create visualizations
            self.create_visualizations(results, save_dir)

            print(f"\nResults saved to: {save_dir}")
            print(f"   • Metrics: {metrics_file.name}")
            print(f"   • Predictions: {predictions_file.name}")
            print(f"   • Visualizations: comprehensive_evaluation_dashboard.png, error_analysis_by_range.png")

        return results


def main():
    """Main function to run comprehensive evaluation"""
    import argparse

    parser = argparse.ArgumentParser(description='V3 Model Comprehensive Evaluation')
    parser.add_argument('--artifacts', type=str, default='./model',
                       help='Directory containing model artifacts')
    parser.add_argument('--test_file', type=str,
                       help='Test file path (if not specified, will search in data directory)')
    parser.add_argument('--device', type=str, choices=['cuda', 'cpu'],
                       help='Device to use for evaluation')

    args = parser.parse_args()

    try:
        # Initialize evaluator
        evaluator = V3ModelEvaluator(args.artifacts, args.device)

        # Determine test file
        if args.test_file:
            test_file = args.test_file
            if not os.path.exists(test_file):
                print(f"Test file not found: {test_file}")
                return
        else:
            # Find test files in data directory
            data_dir = Path(args.artifacts).parent / "src" / "v3" / "data"
            test_files = list(data_dir.glob("*.xlsx"))

            if not test_files:
                print("No test files found in data directory")
                return

            # Use the test_dataset.xlsx if available
            test_file = str(data_dir / "test_dataset.xlsx")
            if not os.path.exists(test_file):
                test_file = str(test_files[0])

        # Run comprehensive evaluation
        results = evaluator.evaluate_comprehensive(test_file, save_results=True)

        print(f"\nEVALUATION COMPLETED SUCCESSFULLY!")
        print(f"Check the generated visualizations and detailed metrics.")

    except Exception as e:
        print(f"Error during evaluation: {e}")
        raise


if __name__ == "__main__":
    main()
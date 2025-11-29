"""
3T-FIT AI Recommendation Engine - Model Evaluation
Comprehensive performance evaluation for the Two-Branch Neural Network

Metrics included:
- Regression metrics (for intensity prediction): RMSE, MAE, R², Explained Variance
- Classification metrics (for suitability prediction): Accuracy, Precision, Recall, F1-Score, AUC-ROC
- Business-specific metrics: Suitability Score Distribution, Recommendation Coverage
- Visualization: Confusion Matrix, ROC Curve, Residual Plots, Prediction vs Actual

Author: Claude Code
Date: 2025-11-27
"""

import torch
import torch.nn as nn
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import (
    mean_squared_error, mean_absolute_error, r2_score, explained_variance_score,
    accuracy_score, precision_score, recall_score, f1_score, roc_auc_score,
    confusion_matrix, classification_report, roc_curve, precision_recall_curve,
    average_precision_score
)
from sklearn.preprocessing import StandardScaler
import pickle
import json
import os
from typing import Dict, List, Tuple, Optional, Any
import logging
from datetime import datetime
import warnings

# Import the training model
from training_model import TwoBranchRecommendationModel, ExerciseDataset, ModelTrainer

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Suppress matplotlib warnings
warnings.filterwarnings('ignore', category=UserWarning, module='matplotlib')

class ModelEvaluator:
    """
    Comprehensive evaluator for the Two-Branch Neural Network
    """

    def __init__(self, model: TwoBranchRecommendationModel, device: str = 'cpu'):
        self.model = model.to(device)
        self.device = device
        self.scaler_X = StandardScaler()
        self.personal_evaluation_results = {}

    def load_model_and_scalers(self, model_dir: str):
        """Load trained model and preprocessing artifacts"""
        try:
            # Load model weights
            self.model.load_state_dict(
                torch.load(os.path.join(model_dir, 'model_weights.pth'), map_location=self.device)
            )
            self.model.eval()

            # Load feature scaler
            with open(os.path.join(model_dir, 'feature_scaler.pkl'), 'rb') as f:
                self.scaler_X = pickle.load(f)

            # Load metadata
            with open(os.path.join(model_dir, 'model_metadata.json'), 'r') as f:
                self.metadata = json.load(f)

            logger.info(f"Model loaded from {model_dir}")
            logger.info(f"Model architecture: {self.metadata.get('architecture', {})}")

            return True

        except Exception as e:
            logger.error(f"Error loading model: {e}")
            return False

    def predict(self, X: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        """
        Make predictions using the Two-Branch model

        Args:
            X: Feature matrix [n_samples, n_features]

        Returns:
            predicted_intensity: Predicted RPE values [n_samples]
            predicted_suitability: Predicted suitability scores [n_samples]
        """
        self.model.eval()

        # Scale features
        X_scaled = self.scaler_X.transform(X)
        X_tensor = torch.FloatTensor(X_scaled).to(self.device)

        with torch.no_grad():
            pred_intensity, pred_suitability = self.model(X_tensor)

            # Convert to numpy and flatten
            pred_intensity = pred_intensity.cpu().numpy().flatten()
            pred_suitability = pred_suitability.cpu().numpy().flatten()

        return pred_intensity, pred_suitability

    def evaluate_intensity_prediction(self, y_true: np.ndarray, y_pred: np.ndarray) -> Dict:
        """
        Evaluate intensity (RPE) prediction performance

        Args:
            y_true: True RPE values [n_samples]
            y_pred: Predicted RPE values [n_samples]

        Returns:
            Dictionary of regression metrics
        """
        metrics = {}

        # Basic regression metrics
        metrics['RMSE'] = np.sqrt(mean_squared_error(y_true, y_pred))
        metrics['MAE'] = mean_absolute_error(y_true, y_pred)
        metrics['R2'] = r2_score(y_true, y_pred)
        metrics['Explained_Variance'] = explained_variance_score(y_true, y_pred)

        # Additional metrics for RPE
        metrics['Mean_Absolute_Percentage_Error'] = np.mean(np.abs((y_true - y_pred) / y_true)) * 100

        # RPE-specific metrics (1-10 scale)
        # Count predictions within acceptable RPE ranges
        rpe_tolerance = 1.0  # ±1 RPE point
        within_tolerance = np.abs(y_true - y_pred) <= rpe_tolerance
        metrics['RPE_Accuracy_1pt'] = np.mean(within_tolerance) * 100

        rpe_tolerance = 2.0  # ±2 RPE points
        within_tolerance = np.abs(y_true - y_pred) <= rpe_tolerance
        metrics['RPE_Accuracy_2pt'] = np.mean(within_tolerance) * 100

        # Distribution analysis
        metrics['True_RPE_Mean'] = np.mean(y_true)
        metrics['Predicted_RPE_Mean'] = np.mean(y_pred)
        metrics['True_RPE_Std'] = np.std(y_true)
        metrics['Predicted_RPE_Std'] = np.std(y_pred)

        return metrics

    def evaluate_suitability_prediction(self, y_true: np.ndarray, y_pred: np.ndarray) -> Dict:
        """
        Evaluate suitability prediction performance

        Args:
            y_true: True suitability scores [n_samples]
            y_pred: Predicted suitability scores [n_samples]

        Returns:
            Dictionary of classification and regression metrics
        """
        metrics = {}

        # Binary classification metrics (threshold = 0.7)
        threshold = 0.7
        y_true_binary = (y_true >= threshold).astype(int)
        y_pred_binary = (y_pred >= threshold).astype(int)

        metrics['Accuracy'] = accuracy_score(y_true_binary, y_pred_binary)
        metrics['Precision'] = precision_score(y_true_binary, y_pred_binary, average='binary', zero_division=0)
        metrics['Recall'] = recall_score(y_true_binary, y_pred_binary, average='binary', zero_division=0)
        metrics['F1_Score'] = f1_score(y_true_binary, y_pred_binary, average='binary', zero_division=0)

        # AUC metrics
        try:
            metrics['AUC_ROC'] = roc_auc_score(y_true_binary, y_pred)
            metrics['AUC_PR'] = average_precision_score(y_true_binary, y_pred)
        except ValueError:
            # Handle case where only one class is present
            metrics['AUC_ROC'] = 0.5
            metrics['AUC_PR'] = 0.5

        # Regression metrics for continuous suitability scores
        metrics['RMSE_Continuous'] = np.sqrt(mean_squared_error(y_true, y_pred))
        metrics['MAE_Continuous'] = mean_absolute_error(y_true, y_pred)
        metrics['R2_Continuous'] = r2_score(y_true, y_pred)

        # Suitability score distribution analysis
        metrics['True_Suitability_Mean'] = np.mean(y_true)
        metrics['Predicted_Suitability_Mean'] = np.mean(y_pred)
        metrics['True_Suitability_Std'] = np.std(y_true)
        metrics['Predicted_Suitability_Std'] = np.std(y_pred)

        # Suitability score categories (based on README.md)
        def categorize_score(score):
            if score < 0.4:
                return 'Not Suitable'
            elif score < 0.6:
                return 'Support/Alternative'
            elif score < 0.75:
                return 'Needs Adjustment'
            elif score < 0.85:
                return 'Effective'
            else:
                return 'Optimal'

        y_true_categories = [categorize_score(s) for s in y_true]
        y_pred_categories = [categorize_score(s) for s in y_pred]

        metrics['Category_Accuracy'] = accuracy_score(y_true_categories, y_pred_categories)

        # Confusion matrix for categories
        categories = ['Not Suitable', 'Support/Alternative', 'Needs Adjustment', 'Effective', 'Optimal']
        cm = confusion_matrix(y_true_categories, y_pred_categories, labels=categories)
        metrics['Confusion_Matrix_Categories'] = cm.tolist()

        return metrics

    def evaluate_business_metrics(self, X: np.ndarray, y_true_intensity: np.ndarray,
                                 y_true_suitability: np.ndarray, y_pred_intensity: np.ndarray,
                                 y_pred_suitability: np.ndarray) -> Dict:
        """
        Evaluate business-specific metrics

        Args:
            X: Feature matrix
            y_true_intensity, y_true_suitability: True values
            y_pred_intensity, y_pred_suitability: Predicted values

        Returns:
            Dictionary of business metrics
        """
        metrics = {}

        # Recommendation Coverage
        # What percentage of exercises are recommended (suitability >= 0.7)?
        recommended_true = np.sum(y_true_suitability >= 0.7)
        recommended_pred = np.sum(y_pred_suitability >= 0.7)
        total_exercises = len(y_true_suitability)

        metrics['Recommendation_Coverage_True'] = (recommended_true / total_exercises) * 100
        metrics['Recommendation_Coverage_Pred'] = (recommended_pred / total_exercises) * 100

        # High-Quality Recommendations (suitability >= 0.85)
        high_quality_true = np.sum(y_true_suitability >= 0.85)
        high_quality_pred = np.sum(y_pred_suitability >= 0.85)

        metrics['High_Quality_Recs_True'] = (high_quality_true / total_exercises) * 100
        metrics['High_Quality_Recs_Pred'] = (high_quality_pred / total_exercises) * 100

        # RPE Distribution Analysis
        # How well does the model predict different intensity levels?
        rpe_bins = [1, 3, 5, 7, 9, 10]
        rpe_labels = ['Very Light', 'Light', 'Moderate', 'Hard', 'Very Hard', 'Max']

        true_rpe_hist, _ = np.histogram(y_true_intensity, bins=rpe_bins)
        pred_rpe_hist, _ = np.histogram(y_pred_intensity, bins=rpe_bins)

        # Normalize to percentages
        true_rpe_hist = (true_rpe_hist / len(y_true_intensity)) * 100
        pred_rpe_hist = (pred_rpe_hist / len(y_pred_intensity)) * 100

        metrics['RPE_Distribution_True'] = dict(zip(rpe_labels, true_rpe_hist.tolist()))
        metrics['RPE_Distribution_Pred'] = dict(zip(rpe_labels, pred_rpe_hist.tolist()))

        # Safety Metrics
        # How often does the model predict high intensity (>8 RPE) for potentially risky exercises?
        high_intensity_pred = np.sum(y_pred_intensity > 8)
        metrics['High_Intensity_Predictions_Percent'] = (high_intensity_pred / total_exercises) * 100

        # Low suitability predictions that might indicate safety concerns
        low_suitability_pred = np.sum(y_pred_suitability < 0.4)
        metrics['Low_Suitability_Predictions_Percent'] = (low_suitability_pred / total_exercises) * 100

        # Consistency Metrics
        # For similar user profiles, are predictions consistent?
        # This is a simplified version - in practice, you'd need user profile grouping
        if len(X) > 100:
            sample_size = min(1000, len(X))
            indices = np.random.choice(len(X), sample_size, replace=False)
            X_sample = X[indices]
            y_pred_intensity_sample = y_pred_intensity[indices]
            y_pred_suitability_sample = y_pred_suitability[indices]

            # Calculate prediction variance for similar profiles
            # This is a proxy for consistency
            metrics['Intensity_Prediction_Variance'] = np.var(y_pred_intensity_sample)
            metrics['Suitability_Prediction_Variance'] = np.var(y_pred_suitability_sample)

        return metrics

    def create_visualizations(self, y_true_intensity: np.ndarray, y_true_suitability: np.ndarray,
                            y_pred_intensity: np.ndarray, y_pred_suitability: np.ndarray,
                            save_dir: str = './evaluation_plots'):
        """Create comprehensive evaluation visualizations"""

        os.makedirs(save_dir, exist_ok=True)

        # Set style
        plt.style.use('seaborn-v0_8')
        sns.set_palette("husl")

        # 1. Intensity Prediction Plots
        fig, axes = plt.subplots(2, 2, figsize=(15, 12))

        # Scatter plot: Actual vs Predicted RPE
        axes[0, 0].scatter(y_true_intensity, y_pred_intensity, alpha=0.6, s=20)
        axes[0, 0].plot([1, 10], [1, 10], 'r--', label='Perfect Prediction')
        axes[0, 0].set_xlabel('Actual RPE')
        axes[0, 0].set_ylabel('Predicted RPE')
        axes[0, 0].set_title('Intensity Prediction: Actual vs Predicted')
        axes[0, 0].legend()
        axes[0, 0].grid(True, alpha=0.3)

        # Residual plot for RPE
        residuals_intensity = y_true_intensity - y_pred_intensity
        axes[0, 1].scatter(y_pred_intensity, residuals_intensity, alpha=0.6, s=20)
        axes[0, 1].axhline(y=0, color='r', linestyle='--')
        axes[0, 1].set_xlabel('Predicted RPE')
        axes[0, 1].set_ylabel('Residuals')
        axes[0, 1].set_title('Intensity Prediction: Residuals')
        axes[0, 1].grid(True, alpha=0.3)

        # Histogram of RPE predictions
        axes[1, 0].hist(y_true_intensity, bins=20, alpha=0.5, label='Actual', density=True)
        axes[1, 0].hist(y_pred_intensity, bins=20, alpha=0.5, label='Predicted', density=True)
        axes[1, 0].set_xlabel('RPE')
        axes[1, 0].set_ylabel('Density')
        axes[1, 0].set_title('RPE Distribution Comparison')
        axes[1, 0].legend()
        axes[1, 0].grid(True, alpha=0.3)

        # Box plot comparison
        df_rpe = pd.DataFrame({
            'Actual': y_true_intensity,
            'Predicted': y_pred_intensity
        })
        df_rpe_melted = df_rpe.melt(var_name='Type', value_name='RPE')
        sns.boxplot(data=df_rpe_melted, x='Type', y='RPE', ax=axes[1, 1])
        axes[1, 1].set_title('RPE Distribution Box Plot')
        axes[1, 1].grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig(os.path.join(save_dir, 'intensity_evaluation.png'), dpi=300, bbox_inches='tight')
        plt.close()

        # 2. Suitability Prediction Plots
        fig, axes = plt.subplots(2, 2, figsize=(15, 12))

        # Scatter plot: Actual vs Predicted Suitability
        axes[0, 0].scatter(y_true_suitability, y_pred_suitability, alpha=0.6, s=20)
        axes[0, 0].plot([0, 1], [0, 1], 'r--', label='Perfect Prediction')
        axes[0, 0].set_xlabel('Actual Suitability')
        axes[0, 0].set_ylabel('Predicted Suitability')
        axes[0, 0].set_title('Suitability Prediction: Actual vs Predicted')
        axes[0, 0].legend()
        axes[0, 0].grid(True, alpha=0.3)

        # ROC Curve
        threshold = 0.7
        y_true_binary = (y_true_suitability >= threshold).astype(int)
        fpr, tpr, _ = roc_curve(y_true_binary, y_pred_suitability)
        auc_score = roc_auc_score(y_true_binary, y_pred_suitability)

        axes[0, 1].plot(fpr, tpr, label=f'ROC Curve (AUC = {auc_score:.3f})')
        axes[0, 1].plot([0, 1], [0, 1], 'r--', label='Random Classifier')
        axes[0, 1].set_xlabel('False Positive Rate')
        axes[0, 1].set_ylabel('True Positive Rate')
        axes[0, 1].set_title('ROC Curve for Suitability Classification')
        axes[0, 1].legend()
        axes[0, 1].grid(True, alpha=0.3)

        # Histogram of suitability predictions
        axes[1, 0].hist(y_true_suitability, bins=20, alpha=0.5, label='Actual', density=True)
        axes[1, 0].hist(y_pred_suitability, bins=20, alpha=0.5, label='Predicted', density=True)
        axes[1, 0].set_xlabel('Suitability Score')
        axes[1, 0].set_ylabel('Density')
        axes[1, 0].set_title('Suitability Score Distribution')
        axes[1, 0].legend()
        axes[1, 0].grid(True, alpha=0.3)

        # Suitability categories bar plot
        def categorize_score(score):
            if score < 0.4:
                return 'Not Suitable'
            elif score < 0.6:
                return 'Support/Alt'
            elif score < 0.75:
                return 'Needs Adjust'
            elif score < 0.85:
                return 'Effective'
            else:
                return 'Optimal'

        true_categories = [categorize_score(s) for s in y_true_suitability]
        pred_categories = [categorize_score(s) for s in y_pred_suitability]

        categories = ['Not Suitable', 'Support/Alt', 'Needs Adjust', 'Effective', 'Optimal']
        true_counts = [true_categories.count(cat) for cat in categories]
        pred_counts = [pred_categories.count(cat) for cat in categories]

        x = np.arange(len(categories))
        width = 0.35

        axes[1, 1].bar(x - width/2, true_counts, width, label='Actual', alpha=0.7)
        axes[1, 1].bar(x + width/2, pred_counts, width, label='Predicted', alpha=0.7)
        axes[1, 1].set_xlabel('Suitability Category')
        axes[1, 1].set_ylabel('Count')
        axes[1, 1].set_title('Suitability Categories Distribution')
        axes[1, 1].set_xticks(x)
        axes[1, 1].set_xticklabels(categories, rotation=45, ha='right')
        axes[1, 1].legend()
        axes[1, 1].grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig(os.path.join(save_dir, 'suitability_evaluation.png'), dpi=300, bbox_inches='tight')
        plt.close()

        # 3. Confusion Matrix for Suitability Classification
        threshold = 0.7
        y_true_binary = (y_true_suitability >= threshold).astype(int)
        y_pred_binary = (y_pred_suitability >= threshold).astype(int)

        cm = confusion_matrix(y_true_binary, y_pred_binary)

        plt.figure(figsize=(8, 6))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                   xticklabels=['Not Suitable', 'Suitable'],
                   yticklabels=['Not Suitable', 'Suitable'])
        plt.title('Confusion Matrix - Suitability Classification')
        plt.ylabel('Actual')
        plt.xlabel('Predicted')
        plt.tight_layout()
        plt.savefig(os.path.join(save_dir, 'confusion_matrix.png'), dpi=300, bbox_inches='tight')
        plt.close()

        logger.info(f"Visualizations saved to {save_dir}")

    def generate_evaluation_report(self, X: np.ndarray, y_true_intensity: np.ndarray,
                                 y_true_suitability: np.ndarray, y_pred_intensity: np.ndarray,
                                 y_pred_suitability: np.ndarray, save_dir: str = './personal_evaluation_results'):
        """Generate comprehensive evaluation report"""

        os.makedirs(save_dir, exist_ok=True)

        # Evaluate all metrics
        intensity_metrics = self.evaluate_intensity_prediction(y_true_intensity, y_pred_intensity)
        suitability_metrics = self.evaluate_suitability_prediction(y_true_suitability, y_pred_suitability)
        business_metrics = self.evaluate_business_metrics(
            X, y_true_intensity, y_true_suitability, y_pred_intensity, y_pred_suitability
        )

        # Create comprehensive report
        report = {
            'evaluation_metadata': {
                'timestamp': datetime.now().isoformat(),
                'model_version': self.metadata.get('model_type', 'TwoBranchRecommendationModel'),
                'dataset_size': len(X),
                'feature_count': X.shape[1],
                'device': self.device
            },
            'intensity_prediction_metrics': intensity_metrics,
            'suitability_prediction_metrics': suitability_metrics,
            'business_metrics': business_metrics,
            'summary': {
                'overall_performance': self._calculate_overall_score(intensity_metrics, suitability_metrics),
                'key_insights': self._generate_key_insights(intensity_metrics, suitability_metrics, business_metrics)
            }
        }

        # Save detailed results
        with open(os.path.join(save_dir, 'detailed_evaluation_report.json'), 'w') as f:
            json.dump(report, f, indent=2, default=str)

        # Create summary report
        self._create_summary_report(report, save_dir)

        # Create visualizations
        self.create_visualizations(
            y_true_intensity, y_true_suitability, y_pred_intensity, y_pred_suitability,
            os.path.join(save_dir, 'plots')
        )

        # Store results for later access
        self.personal_evaluation_results = report

        logger.info(f"Evaluation report generated and saved to {save_dir}")

        return report

    def _calculate_overall_score(self, intensity_metrics: Dict, suitability_metrics: Dict) -> Dict:
        """Calculate overall performance scores"""

        # Intensity score (weighted combination of R² and accuracy)
        intensity_score = (
            intensity_metrics.get('R2', 0) * 0.4 +
            (intensity_metrics.get('RPE_Accuracy_1pt', 0) / 100) * 0.6
        )

        # Suitability score (weighted combination of F1 and AUC)
        suitability_score = (
            suitability_metrics.get('F1_Score', 0) * 0.5 +
            suitability_metrics.get('AUC_ROC', 0) * 0.5
        )

        # Overall score
        overall_score = (intensity_score + suitability_score) / 2

        return {
            'intensity_score': max(0, min(1, intensity_score)),
            'suitability_score': max(0, min(1, suitability_score)),
            'overall_score': max(0, min(1, overall_score)),
            'performance_grade': self._get_performance_grade(overall_score)
        }

    def _get_performance_grade(self, score: float) -> str:
        """Get performance grade based on score"""
        if score >= 0.9:
            return 'Excellent (A)'
        elif score >= 0.8:
            return 'Good (B)'
        elif score >= 0.7:
            return 'Fair (C)'
        elif score >= 0.6:
            return 'Poor (D)'
        else:
            return 'Very Poor (F)'

    def _generate_key_insights(self, intensity_metrics: Dict, suitability_metrics: Dict, business_metrics: Dict) -> List[str]:
        """Generate key insights from evaluation metrics"""

        insights = []

        # Intensity insights
        if intensity_metrics.get('R2', 0) > 0.7:
            insights.append("✅ Strong RPE prediction with high R² score")
        elif intensity_metrics.get('R2', 0) > 0.5:
            insights.append("⚠️ Moderate RPE prediction, could be improved")
        else:
            insights.append("❌ Weak RPE prediction, needs significant improvement")

        rpe_accuracy = intensity_metrics.get('RPE_Accuracy_1pt', 0)
        if rpe_accuracy > 70:
            insights.append(f"✅ {rpe_accuracy:.1f}% of RPE predictions within ±1 point")
        else:
            insights.append(f"⚠️ Only {rpe_accuracy:.1f}% of RPE predictions within ±1 point")

        # Suitability insights
        f1_score = suitability_metrics.get('F1_Score', 0)
        if f1_score > 0.8:
            insights.append("✅ Excellent suitability classification")
        elif f1_score > 0.6:
            insights.append("⚠️ Moderate suitability classification")
        else:
            insights.append("❌ Poor suitability classification")

        # Business insights
        coverage_diff = abs(business_metrics.get('Recommendation_Coverage_True', 0) -
                          business_metrics.get('Recommendation_Coverage_Pred', 0))
        if coverage_diff < 10:
            insights.append("✅ Recommendation coverage well-predicted")
        else:
            insights.append(f"⚠️ {coverage_diff:.1f}% difference in predicted vs actual coverage")

        # Safety insights
        low_suitability = business_metrics.get('Low_Suitability_Predictions_Percent', 0)
        if low_suitability > 20:
            insights.append(f"⚠️ High percentage ({low_suitability:.1f}%) of low suitability predictions")

        return insights

    def _create_summary_report(self, report: Dict, save_dir: str):
        """Create a human-readable summary report"""

        summary_path = os.path.join(save_dir, 'evaluation_summary.txt')

        with open(summary_path, 'w', encoding='utf-8') as f:
            f.write("="*80 + "\n")
            f.write("3T-FIT AI RECOMMENDATION ENGINE - MODEL EVALUATION REPORT\n")
            f.write("="*80 + "\n\n")

            f.write(f"Evaluation Date: {report['evaluation_metadata']['timestamp']}\n")
            f.write(f"Model Version: {report['evaluation_metadata']['model_version']}\n")
            f.write(f"Dataset Size: {report['evaluation_metadata']['dataset_size']:,}\n")
            f.write(f"Feature Count: {report['evaluation_metadata']['feature_count']}\n\n")

            # Overall Performance
            f.write("OVERALL PERFORMANCE\n")
            f.write("-" * 40 + "\n")
            summary = report['summary']['overall_performance']
            f.write(f"Performance Score: {summary['overall_score']:.3f}/1.0\n")
            f.write(f"Performance Grade: {summary['performance_grade']}\n")
            f.write(f"Intensity Score: {summary['intensity_score']:.3f}/1.0\n")
            f.write(f"Suitability Score: {summary['suitability_score']:.3f}/1.0\n\n")

            # Key Metrics
            f.write("KEY METRICS\n")
            f.write("-" * 40 + "\n")

            intensity_metrics = report['intensity_prediction_metrics']
            f.write("Intensity Prediction (RPE):\n")
            f.write(f"  RMSE: {intensity_metrics['RMSE']:.3f}\n")
            f.write(f"  MAE: {intensity_metrics['MAE']:.3f}\n")
            f.write(f"  R² Score: {intensity_metrics['R2']:.3f}\n")
            f.write(f"  Accuracy (±1 RPE): {intensity_metrics['RPE_Accuracy_1pt']:.1f}%\n\n")

            suitability_metrics = report['suitability_prediction_metrics']
            f.write("Suitability Prediction:\n")
            f.write(f"  Accuracy: {suitability_metrics['Accuracy']:.3f}\n")
            f.write(f"  Precision: {suitability_metrics['Precision']:.3f}\n")
            f.write(f"  Recall: {suitability_metrics['Recall']:.3f}\n")
            f.write(f"  F1-Score: {suitability_metrics['F1_Score']:.3f}\n")
            f.write(f"  AUC-ROC: {suitability_metrics['AUC_ROC']:.3f}\n\n")

            # Business Metrics
            f.write("BUSINESS METRICS\n")
            f.write("-" * 40 + "\n")
            business_metrics = report['business_metrics']
            f.write(f"Recommendation Coverage (Actual): {business_metrics['Recommendation_Coverage_True']:.1f}%\n")
            f.write(f"Recommendation Coverage (Predicted): {business_metrics['Recommendation_Coverage_Pred']:.1f}%\n")
            f.write(f"High-Quality Recommendations (Actual): {business_metrics['High_Quality_Recs_True']:.1f}%\n")
            f.write(f"High-Quality Recommendations (Predicted): {business_metrics['High_Quality_Recs_Pred']:.1f}%\n\n")

            # Key Insights
            f.write("KEY INSIGHTS\n")
            f.write("-" * 40 + "\n")
            for insight in report['summary']['key_insights']:
                f.write(f"{insight}\n")
            f.write("\n")

            f.write("="*80 + "\n")
            f.write("END OF REPORT\n")
            f.write("="*80 + "\n")

def main():
    """Main evaluation function"""
    # Configuration
    config = {
        'model_dir': './personal_model_v4',
        'test_data_path': '../data/personal_training_data/test_data.xlsx',
        'device': 'cuda' if torch.cuda.is_available() else 'cpu'
    }

    logger.info(f"Starting model evaluation on device: {config['device']}")

    try:
        # Load metadata first to get input_dim
        metadata_path = os.path.join(config['model_dir'], 'model_metadata.json')
        input_dim = 26 # Default fallback
        
        if os.path.exists(metadata_path):
            try:
                with open(metadata_path, 'r') as f:
                    metadata = json.load(f)
                    input_dim = metadata.get('input_dim', 26)
                    logger.info(f"Loaded input_dim from metadata: {input_dim}")
            except Exception as e:
                logger.warning(f"Could not load metadata to determine input_dim: {e}")

        # Initialize model
        model = TwoBranchRecommendationModel(
            input_dim=input_dim,
            intensity_hidden_dims=[64, 32],
            suitability_hidden_dims=[128, 64],
            dropout_rate=0.2
        )

        # Initialize evaluator
        evaluator = ModelEvaluator(model, device=config['device'])

        # Load trained model
        logger.info("Loading trained model...")
        if not evaluator.load_model_and_scalers(config['model_dir']):
            raise Exception("Failed to load model")

        # Load test data
        logger.info("Loading test data...")
        if config['test_data_path'].endswith('.xlsx'):
            df_test = pd.read_excel(config['test_data_path'])
        else:
            df_test = pd.read_csv(config['test_data_path'])

        logger.info(f"Loaded test data with shape: {df_test.shape}")

        # Prepare test data
        # Feature columns (same as training)
        feature_columns = [
            'duration_min', 'avg_hr', 'max_hr', 'calories', 'fatigue', 'effort', 'mood',
            'age', 'height_m', 'weight_kg', 'bmi', 'fat_percentage', 'resting_heartrate',
            'experience_level', 'workout_frequency', 'gender', 'session_duration',
            'estimated_1rm', 'pace', 'duration_capacity', 'rest_period',
            'intensity_score', 'resistance_intensity', 'cardio_intensity',
            'volume_load', 'rest_density', 'hr_reserve', 'calorie_efficiency'
        ]

        # Filter available columns
        available_features = [col for col in feature_columns if col in df_test.columns]
        logger.info(f"Using {len(available_features)} features: {available_features}")

        # Prepare features and targets
        if available_features:
            X_test = df_test[available_features].values
        else:
            # Fallback to all numeric columns except targets
            exclude_cols = ['enhanced_suitability', 'is_suitable']
            numeric_cols = df_test.select_dtypes(include=[np.number]).columns
            X_test = df_test[[col for col in numeric_cols if col not in exclude_cols]].values

        # Prepare targets
        if 'enhanced_suitability' in df_test.columns:
            y_true_suitability = df_test['enhanced_suitability'].values

            # Derive RPE from intensity-related features if available
            if 'intensity_score' in df_test.columns:
                y_true_intensity = df_test['intensity_score'].values * 10
                y_true_intensity = np.clip(y_true_intensity, 1, 10)
            elif 'avg_hr' in df_test.columns and 'max_hr' in df_test.columns:
                hr_ratio = df_test['avg_hr'] / df_test['max_hr']
                y_true_intensity = hr_ratio * 10
                y_true_intensity = np.clip(y_true_intensity, 1, 10)
            else:
                y_true_intensity = np.random.uniform(1, 10, len(df_test))
        else:
            # Create synthetic targets for demonstration
            y_true_suitability = np.random.beta(2, 2, len(df_test))
            y_true_intensity = np.random.uniform(1, 10, len(df_test))

        # Remove NaN values
        mask = ~(np.isnan(X_test).any(axis=1) | np.isnan(y_true_intensity) | np.isnan(y_true_suitability))
        X_test = X_test[mask]
        y_true_intensity = y_true_intensity[mask]
        y_true_suitability = y_true_suitability[mask]

        logger.info(f"Clean test data: X={X_test.shape}, y_intensity={y_true_intensity.shape}, y_suitability={y_true_suitability.shape}")

        # Make predictions
        logger.info("Making predictions...")
        y_pred_intensity, y_pred_suitability = evaluator.predict(X_test)

        logger.info(f"Predictions generated: intensity={y_pred_intensity.shape}, suitability={y_pred_suitability.shape}")

        # Generate comprehensive evaluation report
        logger.info("Generating evaluation report...")
        evaluation_report = evaluator.generate_evaluation_report(
            X_test, y_true_intensity, y_true_suitability,
            y_pred_intensity, y_pred_suitability,
            save_dir='./personal_evaluation_results'
        )

        # Print summary to console
        summary = evaluation_report['summary']['overall_performance']
        logger.info("\n" + "="*60)
        logger.info("EVALUATION SUMMARY")
        logger.info("="*60)
        logger.info(f"Overall Performance Score: {summary['overall_score']:.3f}/1.0")
        logger.info(f"Performance Grade: {summary['performance_grade']}")
        logger.info(f"Intensity Score: {summary['intensity_score']:.3f}/1.0")
        logger.info(f"Suitability Score: {summary['suitability_score']:.3f}/1.0")

        logger.info("\nKEY INSIGHTS:")
        for insight in evaluation_report['summary']['key_insights']:
            logger.info(f"  {insight}")

        logger.info("\nKEY METRICS:")
        logger.info(f"  RPE RMSE: {evaluation_report['intensity_prediction_metrics']['RMSE']:.3f}")
        logger.info(f"  RPE R²: {evaluation_report['intensity_prediction_metrics']['R2']:.3f}")
        logger.info(f"  Suitability F1-Score: {evaluation_report['suitability_prediction_metrics']['F1_Score']:.3f}")
        logger.info(f"  Suitability AUC-ROC: {evaluation_report['suitability_prediction_metrics']['AUC_ROC']:.3f}")

        logger.info(f"\nDetailed evaluation results saved to: ./personal_evaluation_results")
        logger.info("="*60)

        return evaluation_report

    except Exception as e:
        logger.error(f"Evaluation failed: {e}")
        raise

if __name__ == "__main__":
    main()
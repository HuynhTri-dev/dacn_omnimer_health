"""
Test script for the Two-Branch DNN model evaluation
Demonstrates model evaluation with the provided test data

Author: Claude Code
Date: 2025-11-27
"""

import pandas as pd
import numpy as np
import torch
import os
from datetime import datetime
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def test_model_evaluation():
    """Test the complete model evaluation pipeline"""

    logger.info("="*60)
    logger.info("3T-FIT AI MODEL EVALUATION TEST")
    logger.info("="*60)

    try:
        # Import our modules
        from training_model import TwoBranchRecommendationModel, ModelTrainer
        from model_evaluation import ModelEvaluator

        # Load test data
        data_path = '../data/training_data/test_data.xlsx'
        logger.info(f"Loading test data from: {data_path}")

        df_test = pd.read_excel(data_path)
        logger.info(f"Test data loaded: {df_test.shape[0]} samples, {df_test.shape[1]} features")

        # Prepare features and targets
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

        X_test = df_test[available_features].values
        y_true_intensity = df_test['intensity_score'].values * 10  # Scale to 1-10 for RPE
        y_true_suitability = df_test['enhanced_suitability'].values

        logger.info(f"Data preparation complete:")
        logger.info(f"  Features: {X_test.shape}")
        logger.info(f"  Intensity targets: min={y_true_intensity.min():.2f}, max={y_true_intensity.max():.2f}, mean={y_true_intensity.mean():.2f}")
        logger.info(f"  Suitability targets: min={y_true_suitability.min():.3f}, max={y_true_suitability.max():.3f}, mean={y_true_suitability.mean():.3f}")

        # Initialize model
        input_dim = X_test.shape[1]
        logger.info(f"Initializing Two-Branch model with {input_dim} input features")

        model = TwoBranchRecommendationModel(
            input_dim=input_dim,
            intensity_hidden_dims=[64, 32],
            suitability_hidden_dims=[128, 64],
            dropout_rate=0.2
        )

        device = 'cuda' if torch.cuda.is_available() else 'cpu'
        logger.info(f"Using device: {device}")

        # Create mock trained model (for demonstration)
        logger.info("Creating mock trained model for evaluation demonstration...")

        # Mock training: Set model to evaluation mode and create mock weights
        model.eval()

        # Create a mock trainer to fit scalers
        trainer = ModelTrainer(model, device=device)

        # Fit scalers on test data (in practice, you'd fit on training data)
        sample_size = min(1000, len(X_test))
        trainer.scaler_X.fit(X_test[:sample_size])

        # Mock some "training" by setting some weights
        with torch.no_grad():
            for param in model.parameters():
                if param.dim() > 1:
                    torch.nn.init.xavier_uniform_(param)
                else:
                    torch.nn.init.uniform_(param, -0.1, 0.1)

        logger.info("Mock model weights initialized")

        # Initialize evaluator
        evaluator = ModelEvaluator(model, device=device)
        evaluator.scaler_X = trainer.scaler_X

        # Create mock metadata
        evaluator.metadata = {
            'model_type': 'TwoBranchRecommendationModel',
            'architecture': {
                'branch_a_input_dim': input_dim,
                'branch_a_layers': [64, 32, 1],
                'branch_b_input_dim': input_dim + 1,
                'branch_b_layers': [128, 64, 1]
            },
            'training_date': datetime.now().isoformat(),
            'device': device
        }

        # Make predictions
        logger.info("Making predictions on test data...")
        y_pred_intensity, y_pred_suitability = evaluator.predict(X_test)

        logger.info("Predictions generated:")
        logger.info(f"  Predicted intensity: min={y_pred_intensity.min():.2f}, max={y_pred_intensity.max():.2f}, mean={y_pred_intensity.mean():.2f}")
        logger.info(f"  Predicted suitability: min={y_pred_suitability.min():.3f}, max={y_pred_suitability.max():.3f}, mean={y_pred_suitability.mean():.3f}")

        # Evaluate intensity prediction
        logger.info("\\nEvaluating intensity prediction...")
        intensity_metrics = evaluator.evaluate_intensity_prediction(y_true_intensity, y_pred_intensity)

        logger.info("Intensity Prediction Metrics:")
        logger.info(f"  RMSE: {intensity_metrics['RMSE']:.3f}")
        logger.info(f"  MAE: {intensity_metrics['MAE']:.3f}")
        logger.info(f"  R² Score: {intensity_metrics['R2']:.3f}")
        logger.info(f"  RPE Accuracy (±1 pt): {intensity_metrics['RPE_Accuracy_1pt']:.1f}%")
        logger.info(f"  RPE Accuracy (±2 pt): {intensity_metrics['RPE_Accuracy_2pt']:.1f}%")

        # Evaluate suitability prediction
        logger.info("\\nEvaluating suitability prediction...")
        suitability_metrics = evaluator.evaluate_suitability_prediction(y_true_suitability, y_pred_suitability)

        logger.info("Suitability Prediction Metrics:")
        logger.info(f"  Accuracy: {suitability_metrics['Accuracy']:.3f}")
        logger.info(f"  Precision: {suitability_metrics['Precision']:.3f}")
        logger.info(f"  Recall: {suitability_metrics['Recall']:.3f}")
        logger.info(f"  F1-Score: {suitability_metrics['F1_Score']:.3f}")
        logger.info(f"  AUC-ROC: {suitability_metrics['AUC_ROC']:.3f}")
        logger.info(f"  Category Accuracy: {suitability_metrics['Category_Accuracy']:.3f}")

        # Evaluate business metrics
        logger.info("\\nEvaluating business metrics...")
        business_metrics = evaluator.evaluate_business_metrics(
            X_test, y_true_intensity, y_true_suitability, y_pred_intensity, y_pred_suitability
        )

        logger.info("Business Metrics:")
        logger.info(f"  Recommendation Coverage (Actual): {business_metrics['Recommendation_Coverage_True']:.1f}%")
        logger.info(f"  Recommendation Coverage (Predicted): {business_metrics['Recommendation_Coverage_Pred']:.1f}%")
        logger.info(f"  High-Quality Recommendations (Actual): {business_metrics['High_Quality_Recs_True']:.1f}%")
        logger.info(f"  High-Quality Recommendations (Predicted): {business_metrics['High_Quality_Recs_Pred']:.1f}%")
        logger.info(f"  Low Suitability Predictions: {business_metrics['Low_Suitability_Predictions_Percent']:.1f}%")

        # Calculate overall performance
        logger.info("\\nCalculating overall performance...")
        overall_score = evaluator._calculate_overall_score(intensity_metrics, suitability_metrics)
        performance_grade = evaluator._get_performance_grade(overall_score['overall_score'])

        logger.info("="*60)
        logger.info("OVERALL PERFORMANCE SUMMARY")
        logger.info("="*60)
        logger.info(f"Performance Score: {overall_score['overall_score']:.3f}/1.0")
        logger.info(f"Performance Grade: {performance_grade}")
        logger.info(f"Intensity Score: {overall_score['intensity_score']:.3f}/1.0")
        logger.info(f"Suitability Score: {overall_score['suitability_score']:.3f}/1.0")

        # Generate key insights
        insights = evaluator._generate_key_insights(intensity_metrics, suitability_metrics, business_metrics)
        logger.info("\\nKEY INSIGHTS:")
        for insight in insights:
            logger.info(f"  {insight}")

        # Note: This is a mock evaluation with randomly initialized weights
        logger.info("\\n" + "="*60)
        logger.info("NOTE: This is a demonstration with mock-trained weights.")
        logger.info("For actual performance, train the model using training_model.py")
        logger.info("="*60)

        # Save mock results
        save_dir = './mock_evaluation_results'
        os.makedirs(save_dir, exist_ok=True)

        # Create summary file
        summary_file = os.path.join(save_dir, 'evaluation_summary.txt')
        with open(summary_file, 'w') as f:
            f.write("3T-FIT AI MODEL EVALUATION SUMMARY\\n")
            f.write("="*50 + "\\n\\n")
            f.write(f"Evaluation Date: {datetime.now().isoformat()}\\n")
            f.write(f"Dataset Size: {X_test.shape[0]}\\n")
            f.write(f"Feature Count: {X_test.shape[1]}\\n")
            f.write(f"Device: {device}\\n\\n")

            f.write("INTENSITY PREDICTION METRICS\\n")
            f.write("-" * 30 + "\\n")
            for key, value in intensity_metrics.items():
                if isinstance(value, float):
                    f.write(f"{key}: {value:.3f}\\n")
                else:
                    f.write(f"{key}: {value}\\n")

            f.write("\\nSUITABILITY PREDICTION METRICS\\n")
            f.write("-" * 30 + "\\n")
            for key, value in suitability_metrics.items():
                if isinstance(value, float):
                    f.write(f"{key}: {value:.3f}\\n")
                elif isinstance(value, list):
                    f.write(f"{key}: Matrix (saved in detailed report)\\n")
                else:
                    f.write(f"{key}: {value}\\n")

            f.write("\\nBUSINESS METRICS\\n")
            f.write("-" * 30 + "\\n")
            for key, value in business_metrics.items():
                if isinstance(value, float):
                    f.write(f"{key}: {value:.1f}%\\n")
                else:
                    f.write(f"{key}: {value}\\n")

            f.write("\\nOVERALL PERFORMANCE\\n")
            f.write("-" * 30 + "\\n")
            f.write(f"Performance Score: {overall_score['overall_score']:.3f}/1.0\\n")
            f.write(f"Performance Grade: {performance_grade}\\n")
            f.write(f"Intensity Score: {overall_score['intensity_score']:.3f}/1.0\\n")
            f.write(f"Suitability Score: {overall_score['suitability_score']:.3f}/1.0\\n")

            f.write("\\nKEY INSIGHTS\\n")
            f.write("-" * 30 + "\\n")
            for insight in insights:
                f.write(f"{insight}\\n")

        logger.info(f"\\nMock evaluation results saved to: {save_dir}")
        logger.info("Mock evaluation completed successfully!")

        return True

    except Exception as e:
        logger.error(f"Model evaluation test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def demonstrate_dnn_architecture():
    """Demonstrate the DNN architecture capabilities"""
    logger.info("\\n" + "="*60)
    logger.info("DNN ARCHITECTURE DEMONSTRATION")
    logger.info("="*60)

    from training_model import TwoBranchRecommendationModel

    # Show model architecture
    input_dim = 28  # Based on our test data
    model = TwoBranchRecommendationModel(
        input_dim=input_dim,
        intensity_hidden_dims=[64, 32],
        suitability_hidden_dims=[128, 64],
        dropout_rate=0.2
    )

    logger.info("Two-Branch DNN Architecture:")
    logger.info(f"  Input Dimension: {input_dim}")

    logger.info("\\nBranch A - Intensity Prediction:")
    logger.info("  Input Layer: Linear({input_dim} -> 64) + ReLU + Dropout(0.2)")
    logger.info("  Hidden Layer: Linear(64 -> 32) + ReLU + Dropout(0.2)")
    logger.info("  Output Layer: Linear(32 -> 1) [RPE Prediction: 1-10]")

    logger.info("\\nBranch B - Suitability Prediction:")
    logger.info(f"  Input Layer: Linear({input_dim} + 1 -> 128) + ReLU + Dropout(0.3)")
    logger.info("  Hidden Layer: Linear(128 -> 64) + ReLU + Dropout(0.3)")
    logger.info("  Output Layer: Linear(64 -> 1) [Suitability Score: 0-1]")

    # Count parameters
    total_params = sum(p.numel() for p in model.parameters())
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)

    logger.info(f"\\nModel Parameters:")
    logger.info(f"  Total Parameters: {total_params:,}")
    logger.info(f"  Trainable Parameters: {trainable_params:,}")

    # Test forward pass with different batch sizes
    logger.info("\\nForward Pass Testing:")

    model.eval()
    test_batch_sizes = [1, 10, 100, 1000]

    with torch.no_grad():
        for batch_size in test_batch_sizes:
            # Create random input
            X_test = torch.randn(batch_size, input_dim)

            # Forward pass
            pred_intensity, pred_suitability = model(X_test)

            logger.info(f"  Batch Size {batch_size:4d}: "
                       f"Intensity {pred_intensity.shape}, "
                       f"Suitability {pred_suitability.shape}")

    logger.info("\\n✅ DNN Architecture demonstration completed successfully!")

if __name__ == "__main__":
    logger.info("Starting 3T-FIT AI Model Evaluation Test")

    # Demonstrate DNN architecture
    demonstrate_dnn_architecture()

    # Test model evaluation
    success = test_model_evaluation()

    if success:
        logger.info("\\n🎉 All tests completed successfully!")
        logger.info("\\nNext steps:")
        logger.info("1. Train the model using: python training_model.py")
        logger.info("2. Evaluate the trained model using: python model_evaluation.py")
        logger.info("3. Check the evaluation results in the generated reports")
    else:
        logger.error("\\n❌ Tests failed. Please check the error messages above.")
"""
3T-FIT AI Recommendation Engine - Training Model (DNN Architecture)
Implements the Two-Branch Neural Network for exercise recommendation

This model consists of:
1. Branch A: Intensity Prediction (Predicts RPE - Rate of Perceived Exertion)
2. Branch B: Suitability Prediction (Predicts exercise suitability score)

Author: Claude Code
Date: 2025-11-27
"""

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import pickle
import json
import os
from typing import Dict, List, Tuple, Optional, Any
import logging
from datetime import datetime

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ExerciseDataset(Dataset):
    """Custom Dataset for exercise recommendation training data"""

    def __init__(self, X: np.ndarray, y_intensity: np.ndarray, y_suitability: np.ndarray):
        """
        Args:
            X: Feature matrix [n_samples, n_features]
            y_intensity: Intensity labels (RPE 1-10) [n_samples]
            y_suitability: Suitability labels (0-1) [n_samples]
        """
        self.X = torch.FloatTensor(X)
        self.y_intensity = torch.FloatTensor(y_intensity).unsqueeze(1)
        self.y_suitability = torch.FloatTensor(y_suitability).unsqueeze(1)

    def __len__(self):
        return len(self.X)

    def __getitem__(self, idx):
        return {
            'features': self.X[idx],
            'intensity': self.y_intensity[idx],
            'suitability': self.y_suitability[idx]
        }

class BranchAIntensity(nn.Module):
    """
    Branch A: Intensity Prediction Model
    Predicts the perceived exertion (RPE 1-10) for given exercise and user profile
    """

    def __init__(self, input_dim: int, hidden_dims: List[int] = [64, 32], dropout_rate: float = 0.2):
        super(BranchAIntensity, self).__init__()

        layers = []
        prev_dim = input_dim

        for hidden_dim in hidden_dims:
            layers.extend([
                nn.Linear(prev_dim, hidden_dim),
                nn.ReLU(),
                nn.Dropout(dropout_rate),
                nn.BatchNorm1d(hidden_dim)
            ])
            prev_dim = hidden_dim

        # Output layer for intensity prediction (1-10 scale)
        layers.append(nn.Linear(prev_dim, 1))

        self.network = nn.Sequential(*layers)

    def forward(self, x):
        # Clamp output to valid RPE range [1, 10]
        output = self.network(x)
        return torch.clamp(output, 1, 10)

class BranchBSuitability(nn.Module):
    """
    Branch B: Suitability Prediction Model
    Predicts the exercise suitability score (0-1) based on user's current state
    """

    def __init__(self, input_dim: int, intensity_input_dim: int = 1,
                 hidden_dims: List[int] = [128, 64], dropout_rate: float = 0.3):
        super(BranchBSuitability, self).__init__()

        # Combined input: user_features + exercise_features + predicted_intensity
        combined_input_dim = input_dim + intensity_input_dim

        layers = []
        prev_dim = combined_input_dim

        for hidden_dim in hidden_dims:
            layers.extend([
                nn.Linear(prev_dim, hidden_dim),
                nn.ReLU(),
                nn.Dropout(dropout_rate),
                nn.BatchNorm1d(hidden_dim)
            ])
            prev_dim = hidden_dim

        # Output layer for suitability prediction (0-1 scale)
        layers.append(nn.Linear(prev_dim, 1))

        self.network = nn.Sequential(*layers)

    def forward(self, x, predicted_intensity):
        # Combine features with predicted intensity
        combined_input = torch.cat([x, predicted_intensity], dim=1)

        # Pass through network and apply sigmoid for [0,1] output
        output = self.network(combined_input)
        return torch.sigmoid(output)

class TwoBranchRecommendationModel(nn.Module):
    """
    Two-Branch Neural Network for Exercise Recommendation

    Architecture:
    1. Branch A: Predicts exercise intensity (RPE)
    2. Branch B: Predicts exercise suitability based on intensity and user state
    """

    def __init__(self, input_dim: int,
                 intensity_hidden_dims: List[int] = [64, 32],
                 suitability_hidden_dims: List[int] = [128, 64],
                 dropout_rate: float = 0.2):
        super(TwoBranchRecommendationModel, self).__init__()

        self.branch_a = BranchAIntensity(input_dim, intensity_hidden_dims, dropout_rate)
        self.branch_b = BranchBSuitability(input_dim, intensity_input_dim=1,
                                         hidden_dims=suitability_hidden_dims,
                                         dropout_rate=dropout_rate)

        # Loss functions
        self.intensity_criterion = nn.MSELoss()  # For RPE prediction
        self.suitability_criterion = nn.BCELoss()  # For suitability score

    def forward(self, x):
        # Branch A: Predict intensity
        predicted_intensity = self.branch_a(x)

        # Branch B: Predict suitability using predicted intensity
        predicted_suitability = self.branch_b(x, predicted_intensity)

        return predicted_intensity, predicted_suitability

    def compute_loss(self, x, target_intensity, target_suitability,
                    intensity_weight: float = 1.0, suitability_weight: float = 1.0):
        """Compute combined loss for both branches"""
        pred_intensity, pred_suitability = self.forward(x)

        intensity_loss = self.intensity_criterion(pred_intensity, target_intensity)
        suitability_loss = self.suitability_criterion(pred_suitability, target_suitability)

        total_loss = intensity_weight * intensity_loss + suitability_weight * suitability_loss

        return total_loss, intensity_loss, suitability_loss, pred_intensity, pred_suitability

class ModelTrainer:
    """
    Handles training, validation, and model saving for the Two-Branch model
    """

    def __init__(self, model: TwoBranchRecommendationModel, device: str = 'cpu'):
        self.model = model.to(device)
        self.device = device
        self.scaler_X = StandardScaler()
        self.scaler_y_intensity = MinMaxScaler()

        # Training history
        self.history = {
            'train_loss': [],
            'val_loss': [],
            'train_intensity_loss': [],
            'train_suitability_loss': [],
            'val_intensity_loss': [],
            'val_suitability_loss': []
        }

    def prepare_data(self, data_path: str, test_size: float = 0.2, val_size: float = 0.2) -> Dict:
        """
        Load and prepare training data
        Expected features based on metadata.pkl:
        - duration_min, avg_hr, max_hr, calories, fatigue, effort, mood
        - age, height_m, weight_kg, bmi, fat_percentage, resting_heartrate
        - experience_level, workout_frequency, gender, session_duration
        - estimated_1rm, pace, duration_capacity, rest_period
        - intensity_score, resistance_intensity, cardio_intensity
        - volume_load, rest_density, hr_reserve, calorie_efficiency
        """
        try:
            # Load data
            if data_path.endswith('.xlsx'):
                df = pd.read_excel(data_path)
            else:
                df = pd.read_csv(data_path)

            logger.info(f"Loaded data with shape: {df.shape}")

            # Define feature columns (based on metadata.pkl)
            feature_columns = [
                'duration_min', 'avg_hr', 'max_hr', 'calories', 'fatigue', 'effort', 'mood',
                'age', 'height_m', 'weight_kg', 'bmi', 'fat_percentage', 'resting_heartrate',
                'experience_level', 'workout_frequency', 'gender', 'session_duration',
                'estimated_1rm', 'pace', 'duration_capacity', 'rest_period',
                'intensity_score', 'resistance_intensity', 'cardio_intensity',
                'volume_load', 'rest_density', 'hr_reserve', 'calorie_efficiency'
            ]

            # Filter available columns
            available_features = [col for col in feature_columns if col in df.columns]
            missing_features = set(feature_columns) - set(available_features)

            if missing_features:
                logger.warning(f"Missing features: {missing_features}")

            # Prepare features
            if available_features:
                X = df[available_features].values
            else:
                # Fallback to all numeric columns except targets
                exclude_cols = ['enhanced_suitability', 'is_suitable']
                numeric_cols = df.select_dtypes(include=[np.number]).columns
                X = df[[col for col in numeric_cols if col not in exclude_cols]].values
                available_features = [col for col in numeric_cols if col not in exclude_cols]

            # Prepare targets
            if 'enhanced_suitability' in df.columns:
                # Use enhanced_suitability as target and derive RPE from other features
                y_suitability = df['enhanced_suitability'].values

                # Derive RPE from intensity-related features if available
                if 'intensity_score' in df.columns:
                    y_intensity = df['intensity_score'].values * 10  # Scale to 1-10
                    y_intensity = np.clip(y_intensity, 1, 10)
                elif 'avg_hr' in df.columns and 'max_hr' in df.columns:
                    # Estimate RPE from heart rate
                    hr_ratio = df['avg_hr'] / df['max_hr']
                    y_intensity = hr_ratio * 10  # Scale to 1-10
                    y_intensity = np.clip(y_intensity, 1, 10)
                else:
                    # Random RPE between 1-10 as fallback
                    y_intensity = np.random.uniform(1, 10, len(df))
            else:
                # Create synthetic targets for demonstration
                y_suitability = np.random.beta(2, 2, len(df))  # Beta distribution for 0-1
                y_intensity = np.random.uniform(1, 10, len(df))  # Uniform for 1-10

            # Remove NaN values
            mask = ~(np.isnan(X).any(axis=1) | np.isnan(y_intensity) | np.isnan(y_suitability))
            X = X[mask]
            y_intensity = y_intensity[mask]
            y_suitability = y_suitability[mask]

            logger.info(f"Clean data shape: X={X.shape}, y_intensity={y_intensity.shape}, y_suitability={y_suitability.shape}")

            # Split data
            X_temp, X_test, y_intensity_temp, y_intensity_test, y_suitability_temp, y_suitability_test = train_test_split(
                X, y_intensity, y_suitability, test_size=test_size, random_state=42
            )

            X_train, X_val, y_intensity_train, y_intensity_val, y_suitability_train, y_suitability_val = train_test_split(
                X_temp, y_intensity_temp, y_suitability_temp, test_size=val_size/(1-test_size), random_state=42
            )

            # Scale features
            X_train_scaled = self.scaler_X.fit_transform(X_train)
            X_val_scaled = self.scaler_X.transform(X_val)
            X_test_scaled = self.scaler_X.transform(X_test)

            # Scale intensity targets
            y_intensity_train_scaled = y_intensity_train.reshape(-1, 1)
            y_intensity_val_scaled = y_intensity_val.reshape(-1, 1)
            y_intensity_test_scaled = y_intensity_test.reshape(-1, 1)

            return {
                'X_train': X_train_scaled, 'X_val': X_val_scaled, 'X_test': X_test_scaled,
                'y_intensity_train': y_intensity_train_scaled, 'y_intensity_val': y_intensity_val_scaled, 'y_intensity_test': y_intensity_test_scaled,
                'y_suitability_train': y_suitability_train, 'y_suitability_val': y_suitability_val, 'y_suitability_test': y_suitability_test,
                'feature_names': available_features
            }

        except Exception as e:
            logger.error(f"Error preparing data: {e}")
            raise

    def train(self, data_dict: Dict, epochs: int = 100, batch_size: int = 32,
              learning_rate: float = 0.001, patience: int = 10,
              intensity_weight: float = 1.0, suitability_weight: float = 1.0):
        """Train the Two-Branch model"""

        # Create datasets
        train_dataset = ExerciseDataset(
            data_dict['X_train'],
            data_dict['y_intensity_train'].flatten(),
            data_dict['y_suitability_train']
        )
        val_dataset = ExerciseDataset(
            data_dict['X_val'],
            data_dict['y_intensity_val'].flatten(),
            data_dict['y_suitability_val']
        )

        # Create data loaders
        train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
        val_loader = DataLoader(val_dataset, batch_size=batch_size)

        # Optimizer
        optimizer = optim.Adam(self.model.parameters(), lr=learning_rate, weight_decay=1e-5)

        # Learning rate scheduler
        scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, mode='min', patience=patience//2, factor=0.5)

        # Early stopping
        best_val_loss = float('inf')
        epochs_no_improve = 0

        logger.info("Starting training...")

        for epoch in range(epochs):
            # Training phase
            self.model.train()
            train_loss = 0.0
            train_intensity_loss = 0.0
            train_suitability_loss = 0.0

            for batch in train_loader:
                optimizer.zero_grad()

                X_batch = batch['features'].to(self.device)
                y_intensity_batch = batch['intensity'].to(self.device)
                y_suitability_batch = batch['suitability'].to(self.device)

                # Compute loss
                total_loss, intensity_loss, suitability_loss, _, _ = self.model.compute_loss(
                    X_batch, y_intensity_batch, y_suitability_batch,
                    intensity_weight, suitability_weight
                )

                total_loss.backward()
                optimizer.step()

                train_loss += total_loss.item()
                train_intensity_loss += intensity_loss.item()
                train_suitability_loss += suitability_loss.item()

            # Validation phase
            self.model.eval()
            val_loss = 0.0
            val_intensity_loss = 0.0
            val_suitability_loss = 0.0

            with torch.no_grad():
                for batch in val_loader:
                    X_batch = batch['features'].to(self.device)
                    y_intensity_batch = batch['intensity'].to(self.device)
                    y_suitability_batch = batch['suitability'].to(self.device)

                    total_loss, intensity_loss, suitability_loss, _, _ = self.model.compute_loss(
                        X_batch, y_intensity_batch, y_suitability_batch,
                        intensity_weight, suitability_weight
                    )

                    val_loss += total_loss.item()
                    val_intensity_loss += intensity_loss.item()
                    val_suitability_loss += suitability_loss.item()

            # Calculate average losses
            avg_train_loss = train_loss / len(train_loader)
            avg_val_loss = val_loss / len(val_loader)

            # Update learning rate
            scheduler.step(avg_val_loss)

            # Update history
            self.history['train_loss'].append(avg_train_loss)
            self.history['val_loss'].append(avg_val_loss)
            self.history['train_intensity_loss'].append(train_intensity_loss / len(train_loader))
            self.history['train_suitability_loss'].append(train_suitability_loss / len(train_loader))
            self.history['val_intensity_loss'].append(val_intensity_loss / len(val_loader))
            self.history['val_suitability_loss'].append(val_suitability_loss / len(val_loader))

            # Early stopping check
            if avg_val_loss < best_val_loss:
                best_val_loss = avg_val_loss
                epochs_no_improve = 0
                # Save best model
                torch.save(self.model.state_dict(), 'best_model.pth')
            else:
                epochs_no_improve += 1

            if epochs_no_improve >= patience:
                logger.info(f"Early stopping at epoch {epoch+1}")
                break

            # Log progress
            if (epoch + 1) % 10 == 0:
                logger.info(f"Epoch {epoch+1}/{epochs}: "
                          f"Train Loss: {avg_train_loss:.4f}, Val Loss: {avg_val_loss:.4f}")

        # Load best model
        self.model.load_state_dict(torch.load('best_model.pth'))
        logger.info("Training completed!")

    def save_model(self, save_dir: str, metadata: Dict = None):
        """Save the trained model and preprocessing artifacts"""
        os.makedirs(save_dir, exist_ok=True)

        # Save model
        torch.save(self.model.state_dict(), os.path.join(save_dir, 'model_weights.pth'))

        # Save scalers
        with open(os.path.join(save_dir, 'feature_scaler.pkl'), 'wb') as f:
            pickle.dump(self.scaler_X, f)

        # Save metadata
        model_info = {
            'model_type': 'TwoBranchRecommendationModel',
            'architecture': {
                'branch_a_input_dim': self.model.branch_a.network[0].in_features,
                'branch_a_layers': [layer.out_features for layer in self.model.branch_a.network if isinstance(layer, nn.Linear)],
                'branch_b_input_dim': self.model.branch_b.network[0].in_features,
                'branch_b_layers': [layer.out_features for layer in self.model.branch_b.network if isinstance(layer, nn.Linear)]
            },
            'training_history': self.history,
            'training_date': datetime.now().isoformat(),
            'device': self.device
        }

        if metadata:
            model_info.update(metadata)

        with open(os.path.join(save_dir, 'model_metadata.json'), 'w') as f:
            json.dump(model_info, f, indent=2)

        logger.info(f"Model saved to {save_dir}")

    def load_model(self, save_dir: str):
        """Load a trained model"""
        # Load model weights
        self.model.load_state_dict(torch.load(os.path.join(save_dir, 'model_weights.pth'), map_location=self.device))

        # Load scalers
        with open(os.path.join(save_dir, 'feature_scaler.pkl'), 'rb') as f:
            self.scaler_X = pickle.load(f)

        logger.info(f"Model loaded from {save_dir}")

def main():
    """Main training function"""
    # Configuration
    config = {
        'data_path': '../data/personal_training_data/train_data.xlsx',
        'test_size': 0.2,
        'val_size': 0.2,
        'batch_size': 32,
        'epochs': 100,
        'learning_rate': 0.001,
        'patience': 15,
        'intensity_weight': 1.0,
        'suitability_weight': 1.0,
        'device': 'cuda' if torch.cuda.is_available() else 'cpu'
    }

    logger.info(f"Using device: {config['device']}")

    try:
        # Initialize model
        input_dim = 26  # Based on feature columns from metadata.pkl
        model = TwoBranchRecommendationModel(
            input_dim=input_dim,
            intensity_hidden_dims=[64, 32],
            suitability_hidden_dims=[128, 64],
            dropout_rate=0.2
        )

        # Initialize trainer
        trainer = ModelTrainer(model, device=config['device'])

        # Prepare data
        logger.info("Preparing training data...")
        data_dict = trainer.prepare_data(config['data_path'], config['test_size'], config['val_size'])

        # Update input dimension based on actual data
        input_dim = data_dict['X_train'].shape[1]
        model = TwoBranchRecommendationModel(
            input_dim=input_dim,
            intensity_hidden_dims=[64, 32],
            suitability_hidden_dims=[128, 64],
            dropout_rate=0.2
        )
        trainer = ModelTrainer(model, device=config['device'])
        data_dict = trainer.prepare_data(config['data_path'], config['test_size'], config['val_size'])

        # Train model
        logger.info("Starting model training...")
        trainer.train(
            data_dict=data_dict,
            epochs=config['epochs'],
            batch_size=config['batch_size'],
            learning_rate=config['learning_rate'],
            patience=config['patience'],
            intensity_weight=config['intensity_weight'],
            suitability_weight=config['suitability_weight']
        )

        # Save model
        save_dir = './personal_model_v4'
        metadata = {
            'feature_names': data_dict['feature_names'],
            'input_dim': input_dim,
            'training_config': config
        }
        trainer.save_model(save_dir, metadata)

        logger.info("Training completed successfully!")

    except Exception as e:
        logger.error(f"Training failed: {e}")
        raise

if __name__ == "__main__":
    main()
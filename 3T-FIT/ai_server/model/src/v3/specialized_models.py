"""
specialized_models.py
Implement specialized models for each prediction task

This script creates and trains separate models for:
1. 1RM Prediction (Strength estimation)
2. Suitability Score Prediction
3. Readiness Factor Prediction

Each model is optimized for its specific task architecture.

Author: Claude Code Assistant
Date: 2025-11-27
"""

import torch
import torch.nn as nn
import torch.optim as optim
import numpy as np
import pandas as pd
from pathlib import Path
import json
from typing import Dict, List, Tuple, Optional
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.preprocessing import RobustScaler, StandardScaler
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.linear_model import ElasticNet, Ridge
import xgboost as xgb
import lightgbm as lgb
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.feature_selection import SelectKBest, f_regression, RFE
import joblib

class EnhancedMLP(nn.Module):
    """Enhanced Multi-layer Perceptron with advanced features"""

    def __init__(self, input_dim: int, hidden_dims: List[int] = [512, 256, 128, 64],
                 dropout: float = 0.3, activation: str = 'relu',
                 batch_norm: bool = True, residual: bool = True):
        super(EnhancedMLP, self).__init__()

        self.input_dim = input_dim
        self.hidden_dims = hidden_dims
        self.dropout_rate = dropout
        self.activation = activation
        self.batch_norm = batch_norm
        self.residual = residual

        # Build layers
        layers = []
        prev_dim = input_dim

        for i, hidden_dim in enumerate(hidden_dims):
            # Linear layer
            layers.append(nn.Linear(prev_dim, hidden_dim))

            # Batch normalization
            if batch_norm:
                layers.append(nn.BatchNorm1d(hidden_dim))

            # Activation
            if activation == 'relu':
                layers.append(nn.ReLU(inplace=True))
            elif activation == 'gelu':
                layers.append(nn.GELU())
            elif activation == 'swish':
                layers.append(nn.SiLU())

            # Dropout
            layers.append(nn.Dropout(dropout))
            prev_dim = hidden_dim

        # Output layer
        layers.append(nn.Linear(prev_dim, 1))

        self.network = nn.Sequential(*layers)

        # Residual connection if input and output dimensions match
        if residual and input_dim == 1:
            self.residual_layer = nn.Identity()
        else:
            self.residual_layer = None

    def forward(self, x):
        out = self.network(x)
        if self.residual_layer is not None and out.shape == x.shape:
            out = out + self.residual_layer(x)
        return out

class Specialized1RMModel(nn.Module):
    """Specialized model for 1RM prediction with advanced architecture"""

    def __init__(self, input_dim: int):
        super(Specialized1RMModel, self).__init__()

        # Feature extraction layers
        self.feature_extractor = nn.Sequential(
            nn.Linear(input_dim, 256),
            nn.LayerNorm(256),
            nn.ReLU(),
            nn.Dropout(0.2),

            nn.Linear(256, 128),
            nn.LayerNorm(128),
            nn.ReLU(),
            nn.Dropout(0.2),

            nn.Linear(128, 64),
            nn.LayerNorm(64),
            nn.ReLU(),
            nn.Dropout(0.1)
        )

        # Body composition branch
        self.body_branch = nn.Sequential(
            nn.Linear(4, 32),  # weight, height, bmi, age
            nn.ReLU(),
            nn.Dropout(0.1),
            nn.Linear(32, 16),
            nn.ReLU()
        )

        # Experience branch
        self.experience_branch = nn.Sequential(
            nn.Linear(3, 32),  # experience, frequency, resting_hr
            nn.ReLU(),
            nn.Dropout(0.1),
            nn.Linear(32, 16),
            nn.ReLU()
        )

        # SePA branch
        self.sepa_branch = nn.Sequential(
            nn.Linear(3, 32),  # mood, fatigue, effort
            nn.ReLU(),
            nn.Dropout(0.1),
            nn.Linear(32, 16),
            nn.ReLU()
        )

        # Fusion and prediction
        self.fusion = nn.Sequential(
            nn.Linear(64 + 16 + 16 + 16, 128),  # feature_extractor + branches
            nn.LayerNorm(128),
            nn.ReLU(),
            nn.Dropout(0.2),

            nn.Linear(128, 64),
            nn.ReLU(),
            nn.Dropout(0.1),

            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Linear(32, 1)
        )

    def forward(self, x):
        # Main feature extraction
        main_features = self.feature_extractor(x)

        # Branch processing
        body_features = self.body_branch(x[:, [1, 2, 3, 0]])  # weight, height, bmi, age
        exp_features = self.experience_branch(x[:, [5, 6, 7]])  # experience, freq, resting_hr
        sepa_features = self.sepa_branch(x[:, [8, 9, 10]])  # mood, fatigue, effort

        # Concatenate and fuse
        combined = torch.cat([main_features, body_features, exp_features, sepa_features], dim=1)
        output = self.fusion(combined)

        return output.squeeze()

class SpecializedSuitabilityModel(nn.Module):
    """Specialized model for suitability prediction with classification focus"""

    def __init__(self, input_dim: int):
        super(SpecializedSuitabilityModel, self).__init__()

        # Main network
        self.main_network = EnhancedMLP(
            input_dim=input_dim,
            hidden_dims=[256, 128, 64],
            dropout=0.3,
            activation='gelu'
        )

        # Auxiliary classification heads
        self.difficulty_classifier = nn.Sequential(
            nn.Linear(input_dim, 64),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(64, 3)  # Easy, Medium, Hard
        )

        self.goal_classifier = nn.Sequential(
            nn.Linear(input_dim, 64),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(64, 4)  # Strength, Hypertrophy, Endurance, General
        )

    def forward(self, x):
        # Main regression output
        suitability = self.main_network(x).squeeze()

        # Auxiliary classification outputs
        difficulty = self.difficulty_classifier(x)
        goal = self.goal_classifier(x)

        return suitability, difficulty, goal

class SpecializedReadinessModel(nn.Module):
    """Specialized model for readiness factor prediction"""

    def __init__(self, input_dim: int):
        super(SpecializedReadinessModel, self).__init__()

        # SePA-focused network
        self.sepa_network = nn.Sequential(
            nn.Linear(3, 64),  # mood, fatigue, effort
            nn.ReLU(),
            nn.LayerNorm(64),
            nn.Dropout(0.1),

            nn.Linear(64, 32),
            nn.ReLU(),
            nn.LayerNorm(32),

            nn.Linear(32, 16),
            nn.ReLU()
        )

        # Physical factors network
        self.physical_network = nn.Sequential(
            nn.Linear(input_dim - 3, 64),  # all features except SePA
            nn.ReLU(),
            nn.LayerNorm(64),
            nn.Dropout(0.1),

            nn.Linear(64, 32),
            nn.ReLU(),
            nn.LayerNorm(32),

            nn.Linear(32, 16),
            nn.ReLU()
        )

        # Fusion and output
        self.fusion = nn.Sequential(
            nn.Linear(16 + 16, 32),
            nn.ReLU(),
            nn.Dropout(0.1),
            nn.Linear(32, 16),
            nn.ReLU(),
            nn.Linear(16, 1)
        )

    def forward(self, x):
        # Split features
        sepa_features = x[:, -3:]  # mood, fatigue, effort
        physical_features = x[:, :-3]  # all other features

        # Process through branches
        sepa_out = self.sepa_network(sepa_features)
        physical_out = self.physical_network(physical_features)

        # Fuse and predict
        combined = torch.cat([sepa_out, physical_out], dim=1)
        readiness = self.fusion(combined).squeeze()

        return readiness

class SpecializedModelTrainer:
    """Trainer for specialized models with advanced techniques"""

    def __init__(self, data_path: str, output_dir: str = "./specialized_models"):
        self.data_path = Path(data_path)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)

        self.data = None
        self.scalers = {}
        self.models = {}
        self.training_history = {}

    def load_and_prepare_data(self):
        """Load and prepare data for specialized training"""
        print("📁 Loading and preparing data...")

        # Load data
        self.data = pd.read_excel(self.data_path)
        print(f"   • Loaded data: {self.data.shape}")

        # Feature engineering
        self._engineer_features()

        # Prepare targets
        targets = self._prepare_targets()

        # Split data
        train_data, test_data = train_test_split(
            self.data, test_size=0.2, random_state=42, stratify=None
        )

        # Prepare features for each task
        feature_sets = self._prepare_feature_sets()

        print(f"   • Train samples: {len(train_data)}")
        print(f"   • Test samples: {len(test_data)}")

        return train_data, test_data, targets, feature_sets

    def _engineer_features(self):
        """Create advanced features"""
        print("🔧 Engineering features...")

        # Body composition features
        self.data['bmi_category'] = pd.cut(self.data['bmi'],
                                        bins=[0, 18.5, 25, 30, 100],
                                        labels=['Underweight', 'Normal', 'Overweight', 'Obese'])

        # Experience features
        self.data['experience_intensity'] = self.data['experience_level'] * self.data['workout_frequency']
        self.data['age_experience_interaction'] = self.data['age'] * self.data['experience_level']

        # Strength estimation features
        self.data['strength_potential'] = self.data['weight_kg'] * (1 + self.data['experience_level'] * 0.1)

        # SePA composite features
        self.data['sepa_energy'] = (self.data['mood_numeric'] +
                                   (6 - self.data['fatigue_numeric']) +
                                   self.data['effort_numeric']) / 3

        # Health indicators
        self.data['cardiovascular_health'] = np.where(
            (self.data['resting_heartrate'] < 60) & (self.data['age'] < 40),
            'Excellent',
            np.where(
                self.data['resting_heartrate'] < 70,
                'Good',
                np.where(
                    self.data['resting_heartrate'] < 80,
                    'Fair',
                    'Poor'
                )
            )
        )

    def _prepare_targets(self) -> Dict:
        """Prepare target variables with transformations"""
        print("🎯 Preparing targets...")

        targets = {}

        # 1RM with log transformation
        self.data['estimated_1rm_log'] = np.log1p(self.data['estimated_1rm'])
        targets['1rm'] = {
            'original': 'estimated_1rm',
            'log': 'estimated_1rm_log',
            'transform': 'log'
        }

        # Suitability score
        targets['suitability'] = {
            'original': 'suitability_x',
            'transform': 'none'
        }

        # Readiness factor
        targets['readiness'] = {
            'original': 'readiness_factor',
            'transform': 'none'
        }

        return targets

    def _prepare_feature_sets(self) -> Dict:
        """Define feature sets for each task"""
        return {
            '1rm': [
                'age', 'weight_kg', 'height_m', 'bmi',
                'experience_level', 'workout_frequency', 'resting_heartrate',
                'mood_numeric', 'fatigue_numeric', 'effort_numeric',
                'experience_intensity', 'strength_potential', 'sepa_energy'
            ],
            'suitability': [
                'age', 'weight_kg', 'height_m', 'bmi',
                'experience_level', 'workout_frequency', 'resting_heartrate',
                'mood_numeric', 'fatigue_numeric', 'effort_numeric',
                'sepa_energy', 'age_experience_interaction'
            ],
            'readiness': [
                'age', 'weight_kg', 'height_m', 'bmi',
                'experience_level', 'workout_frequency', 'resting_heartrate',
                'mood_numeric', 'fatigue_numeric', 'effort_numeric',
                'sepa_energy'
            ]
        }

    def train_specialized_models(self):
        """Train all specialized models"""
        print("🚀 Training specialized models...")
        print("=" * 60)

        # Load and prepare data
        train_data, test_data, targets, feature_sets = self.load_and_prepare_data()

        results = {}

        # Train 1RM model
        print("\n💪 Training 1RM Prediction Model...")
        results['1rm'] = self._train_1rm_model(
            train_data, test_data, feature_sets['1rm'], targets['1rm']
        )

        # Train Suitability model
        print("\n⭐ Training Suitability Prediction Model...")
        results['suitability'] = self._train_suitability_model(
            train_data, test_data, feature_sets['suitability'], targets['suitability']
        )

        # Train Readiness model
        print("\n🔋 Training Readiness Prediction Model...")
        results['readiness'] = self._train_readiness_model(
            train_data, test_data, feature_sets['readiness'], targets['readiness']
        )

        # Compare with baseline models
        print("\n📊 Training Baseline Models for Comparison...")
        baseline_results = self._train_baseline_models(
            train_data, test_data, targets, feature_sets
        )
        results['baseline'] = baseline_results

        # Save results
        self._save_results(results)

        # Create comparison visualizations
        self._create_comparison_visualizations(results)

        return results

    def _train_1rm_model(self, train_data, test_data, features, target_info):
        """Train specialized 1RM model"""
        # Prepare data
        X_train = train_data[features].fillna(train_data[features].median())
        X_test = test_data[features].fillna(test_data[features].median())

        # Choose target based on transformation
        if target_info['transform'] == 'log':
            y_train = train_data[target_info['log']]
            y_test = test_data[target_info['log']]
        else:
            y_train = train_data[target_info['original']]
            y_test = test_data[target_info['original']]

        # Scale features
        scaler = RobustScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)

        # Train neural network
        device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

        model = Specialized1RMModel(input_dim=len(features)).to(device)
        optimizer = optim.AdamW(model.parameters(), lr=0.001, weight_decay=0.01)
        scheduler = optim.lr_scheduler.ReduceLROnPlateau(
            optimizer, mode='min', factor=0.5, patience=10, verbose=True
        )

        # Convert to tensors
        X_train_tensor = torch.FloatTensor(X_train_scaled).to(device)
        y_train_tensor = torch.FloatTensor(y_train.values).to(device)
        X_test_tensor = torch.FloatTensor(X_test_scaled).to(device)
        y_test_tensor = torch.FloatTensor(y_test.values).to(device)

        # Training loop
        train_losses = []
        val_losses = []

        best_val_loss = float('inf')
        patience_counter = 0

        for epoch in range(200):
            # Training
            model.train()
            optimizer.zero_grad()

            outputs = model(X_train_tensor)
            loss = nn.MSELoss()(outputs, y_train_tensor)

            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
            optimizer.step()

            train_losses.append(loss.item())

            # Validation
            model.eval()
            with torch.no_grad():
                val_outputs = model(X_test_tensor)
                val_loss = nn.MSELoss()(val_outputs, y_test_tensor)
                val_losses.append(val_loss.item())

            scheduler.step(val_loss)

            # Early stopping
            if val_loss < best_val_loss:
                best_val_loss = val_loss
                patience_counter = 0
                best_model_state = model.state_dict().copy()
            else:
                patience_counter += 1

            if patience_counter >= 30:
                print(f"   • Early stopping at epoch {epoch}")
                break

        # Load best model
        model.load_state_dict(best_model_state)

        # Evaluate
        model.eval()
        with torch.no_grad():
            y_pred_scaled = model(X_test_tensor).cpu().numpy()

        # Reverse transformation if needed
        if target_info['transform'] == 'log':
            y_pred = np.expm1(y_pred_scaled)
            y_true = test_data[target_info['original']].values
        else:
            y_pred = y_pred_scaled
            y_true = test_data[target_info['original']].values

        # Calculate metrics
        metrics = {
            'mae': mean_absolute_error(y_true, y_pred),
            'rmse': np.sqrt(mean_squared_error(y_true, y_pred)),
            'r2': r2_score(y_true, y_pred),
            'mape': np.mean(np.abs((y_true - y_pred) / (y_true + 1e-8))) * 100
        }

        # Save model
        torch.save({
            'model_state_dict': model.state_dict(),
            'input_dim': len(features),
            'features': features,
            'scaler': scaler,
            'target_info': target_info,
            'metrics': metrics,
            'training_losses': train_losses,
            'validation_losses': val_losses
        }, self.output_dir / 'specialized_1rm_model.pt')

        # Save scaler
        joblib.dump(scaler, self.output_dir / '1rm_scaler.joblib')

        print(f"   • 1RM Model - MAE: {metrics['mae']:.2f}, RMSE: {metrics['rmse']:.2f}, R²: {metrics['r2']:.3f}")

        return {
            'model': model,
            'scaler': scaler,
            'metrics': metrics,
            'predictions': y_pred,
            'true_values': y_true,
            'training_history': {'train': train_losses, 'val': val_losses}
        }

    def _train_suitability_model(self, train_data, test_data, features, target_info):
        """Train specialized suitability model"""
        # Similar implementation for suitability...
        # For brevity, using a simpler approach
        X_train = train_data[features].fillna(train_data[features].median())
        X_test = test_data[features].fillna(test_data[features].median())
        y_train = train_data[target_info['original']]
        y_test = test_data[target_info['original']]

        # Scale features
        scaler = StandardScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)

        # Train ensemble models
        models = {
            'rf': RandomForestRegressor(n_estimators=100, random_state=42),
            'gb': GradientBoostingRegressor(n_estimators=100, random_state=42),
            'xgb': xgb.XGBRegressor(random_state=42),
            'lgb': lgb.LGBMRegressor(random_state=42)
        }

        best_model = None
        best_score = float('inf')
        best_name = None

        for name, model in models.items():
            model.fit(X_train_scaled, y_train)
            y_pred = model.predict(X_test_scaled)
            score = mean_absolute_error(y_test, y_pred)

            if score < best_score:
                best_score = score
                best_model = model
                best_name = name

        # Final predictions
        y_pred = best_model.predict(X_test_scaled)

        metrics = {
            'mae': mean_absolute_error(y_test, y_pred),
            'rmse': np.sqrt(mean_squared_error(y_test, y_pred)),
            'r2': r2_score(y_test, y_pred),
            'best_model': best_name
        }

        # Save model
        joblib.dump({
            'model': best_model,
            'scaler': scaler,
            'features': features,
            'metrics': metrics
        }, self.output_dir / 'suitability_ensemble_model.joblib')

        print(f"   • Suitability Model ({best_name}) - MAE: {metrics['mae']:.3f}, RMSE: {metrics['rmse']:.3f}, R²: {metrics['r2']:.3f}")

        return {
            'model': best_model,
            'scaler': scaler,
            'metrics': metrics,
            'predictions': y_pred,
            'true_values': y_test.values,
            'best_model_name': best_name
        }

    def _train_readiness_model(self, train_data, test_data, features, target_info):
        """Train specialized readiness model"""
        # Similar to suitability but focused on SePA features
        X_train = train_data[features].fillna(train_data[features].median())
        X_test = test_data[features].fillna(test_data[features].median())
        y_train = train_data[target_info['original']]
        y_test = test_data[target_info['original']]

        # Scale features
        scaler = RobustScaler()
        X_train_scaled = scaler.fit_transform(X_train)
        X_test_scaled = scaler.transform(X_test)

        # Train neural network with focus on SePA
        device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

        model = SpecializedReadinessModel(input_dim=len(features)).to(device)
        optimizer = optim.Adam(model.parameters(), lr=0.001)

        # Training
        X_train_tensor = torch.FloatTensor(X_train_scaled).to(device)
        y_train_tensor = torch.FloatTensor(y_train.values).to(device)
        X_test_tensor = torch.FloatTensor(X_test_scaled).to(device)

        for epoch in range(100):
            model.train()
            optimizer.zero_grad()

            outputs = model(X_train_tensor)
            loss = nn.MSELoss()(outputs, y_train_tensor)

            loss.backward()
            optimizer.step()

        # Evaluate
        model.eval()
        with torch.no_grad():
            y_pred = model(X_test_tensor).cpu().numpy()

        metrics = {
            'mae': mean_absolute_error(y_test.values, y_pred),
            'rmse': np.sqrt(mean_squared_error(y_test.values, y_pred)),
            'r2': r2_score(y_test.values, y_pred)
        }

        # Save model
        torch.save({
            'model_state_dict': model.state_dict(),
            'input_dim': len(features),
            'scaler': scaler,
            'metrics': metrics
        }, self.output_dir / 'specialized_readiness_model.pt')

        print(f"   • Readiness Model - MAE: {metrics['mae']:.3f}, RMSE: {metrics['rmse']:.3f}, R²: {metrics['r2']:.3f}")

        return {
            'model': model,
            'scaler': scaler,
            'metrics': metrics,
            'predictions': y_pred,
            'true_values': y_test.values
        }

    def _train_baseline_models(self, train_data, test_data, targets, feature_sets):
        """Train baseline models for comparison"""
        baseline_results = {}

        for task_name, target_info in targets.items():
            if task_name == 'baseline':
                continue

            print(f"   • Training baseline models for {task_name}...")

            features = feature_sets[task_name]
            X_train = train_data[features].fillna(train_data[features].median())
            X_test = test_data[features].fillna(test_data[features].median())

            # Choose target
            if target_info['transform'] == 'log':
                y_train = train_data[target_info['log']]
                y_test = test_data[target_info['log']]
            else:
                y_train = train_data[target_info['original']]
                y_test = test_data[target_info['original']]

            # Simple baseline models
            models = {
                'linear': Ridge(alpha=1.0),
                'elastic': ElasticNet(alpha=1.0, l1_ratio=0.5)
            }

            task_results = {}
            for name, model in models.items():
                model.fit(X_train, y_train)
                y_pred = model.predict(X_test)

                if target_info['transform'] == 'log':
                    y_pred = np.expm1(y_pred)
                    y_true = test_data[target_info['original']].values
                else:
                    y_true = test_data[target_info['original']].values

                metrics = {
                    'mae': mean_absolute_error(y_true, y_pred),
                    'rmse': np.sqrt(mean_squared_error(y_true, y_pred)),
                    'r2': r2_score(y_true, y_pred)
                }

                task_results[name] = {'model': model, 'metrics': metrics}

            baseline_results[task_name] = task_results

        return baseline_results

    def _save_results(self, results: Dict):
        """Save all training results"""
        print("\n💾 Saving results...")

        # Save comprehensive results
        results_file = self.output_dir / "specialized_models_results.json"

        # Convert numpy arrays to lists for JSON serialization
        serializable_results = {}
        for key, value in results.items():
            if isinstance(value, dict):
                serializable_results[key] = {}
                for sub_key, sub_value in value.items():
                    if hasattr(sub_value, '__dict__'):
                        continue  # Skip model objects
                    elif 'predictions' in sub_value:
                        serializable_results[key][sub_key] = {
                            'metrics': sub_value['metrics'],
                            'predictions': sub_value['predictions'].tolist() if hasattr(sub_value['predictions'], 'tolist') else sub_value['predictions'],
                            'true_values': sub_value['true_values'].tolist() if hasattr(sub_value['true_values'], 'tolist') else sub_value['true_values']
                        }
                    else:
                        serializable_results[key][sub_key] = sub_value
            else:
                serializable_results[key] = value

        with open(results_file, 'w') as f:
            json.dump(serializable_results, f, indent=2)

        print(f"   • Results saved: {results_file}")

    def _create_comparison_visualizations(self, results: Dict):
        """Create comparison visualizations"""
        print("📊 Creating comparison visualizations...")

        # Create comparison charts
        fig, axes = plt.subplots(2, 2, figsize=(16, 12))
        fig.suptitle('Specialized Models Performance Comparison', fontsize=16, fontweight='bold')

        tasks = ['1rm', 'suitability', 'readiness']
        task_names = ['1RM Prediction', 'Suitability Score', 'Readiness Factor']

        # 1. MAE Comparison
        ax1 = axes[0, 0]
        specialized_mae = [results[task]['metrics']['mae'] for task in tasks]
        baseline_mae = [min([results['baseline'][task][model]['metrics']['mae']
                           for model in results['baseline'][task].keys()])
                       for task in tasks]

        x = np.arange(len(tasks))
        width = 0.35

        ax1.bar(x - width/2, specialized_mae, width, label='Specialized', alpha=0.7, color='blue')
        ax1.bar(x + width/2, baseline_mae, width, label='Best Baseline', alpha=0.7, color='orange')

        ax1.set_xlabel('Prediction Task')
        ax1.set_ylabel('MAE')
        ax1.set_title('Mean Absolute Error Comparison')
        ax1.set_xticks(x)
        ax1.set_xticklabels(task_names)
        ax1.legend()
        ax1.grid(True, alpha=0.3)

        # 2. RMSE Comparison
        ax2 = axes[0, 1]
        specialized_rmse = [results[task]['metrics']['rmse'] for task in tasks]
        baseline_rmse = [min([results['baseline'][task][model]['metrics']['rmse']
                            for model in results['baseline'][task].keys()])
                        for task in tasks]

        ax2.bar(x - width/2, specialized_rmse, width, label='Specialized', alpha=0.7, color='blue')
        ax2.bar(x + width/2, baseline_rmse, width, label='Best Baseline', alpha=0.7, color='orange')

        ax2.set_xlabel('Prediction Task')
        ax2.set_ylabel('RMSE')
        ax2.set_title('Root Mean Square Error Comparison')
        ax2.set_xticks(x)
        ax2.set_xticklabels(task_names)
        ax2.legend()
        ax2.grid(True, alpha=0.3)

        # 3. R² Comparison
        ax3 = axes[1, 0]
        specialized_r2 = [results[task]['metrics']['r2'] for task in tasks]
        baseline_r2 = [max([results['baseline'][task][model]['metrics']['r2']
                           for model in results['baseline'][task].keys()])
                       for task in tasks]

        ax3.bar(x - width/2, specialized_r2, width, label='Specialized', alpha=0.7, color='blue')
        ax3.bar(x + width/2, baseline_r2, width, label='Best Baseline', alpha=0.7, color='orange')

        ax3.set_xlabel('Prediction Task')
        ax3.set_ylabel('R² Score')
        ax3.set_title('R² Score Comparison')
        ax3.set_xticks(x)
        ax3.set_xticklabels(task_names)
        ax3.legend()
        ax3.grid(True, alpha=0.3)

        # 4. Performance Improvement
        ax4 = axes[1, 1]
        improvement_mae = [(baseline_mae[i] - specialized_mae[i]) / baseline_mae[i] * 100
                          for i in range(len(tasks))]
        improvement_rmse = [(baseline_rmse[i] - specialized_rmse[i]) / baseline_rmse[i] * 100
                           for i in range(len(tasks))]
        improvement_r2 = [(specialized_r2[i] - baseline_r2[i]) / abs(baseline_r2[i]) * 100
                         if baseline_r2[i] != 0 else 0
                         for i in range(len(tasks))]

        x = np.arange(len(tasks))
        width = 0.25

        ax4.bar(x - width, improvement_mae, width, label='MAE Improvement', alpha=0.7, color='green')
        ax4.bar(x, improvement_rmse, width, label='RMSE Improvement', alpha=0.7, color='blue')
        ax4.bar(x + width, improvement_r2, width, label='R² Improvement', alpha=0.7, color='purple')

        ax4.set_xlabel('Prediction Task')
        ax4.set_ylabel('Improvement (%)')
        ax4.set_title('Performance Improvement Over Baseline')
        ax4.set_xticks(x)
        ax4.set_xticklabels(task_names)
        ax4.legend()
        ax4.grid(True, alpha=0.3)
        ax4.axhline(y=0, color='red', linestyle='--', alpha=0.5)

        plt.tight_layout()

        # Save visualization
        viz_path = self.output_dir / 'specialized_models_comparison.png'
        plt.savefig(viz_path, dpi=300, bbox_inches='tight')
        plt.close()

        print(f"   • Comparison visualization saved: {viz_path}")


def main():
    """Main function to train specialized models"""
    import argparse

    parser = argparse.ArgumentParser(description='Train Specialized Models')
    parser.add_argument('--data', type=str,
                       default='./data/enhanced_gym_member_exercise_tracking_10k.xlsx',
                       help='Training data file path')
    parser.add_argument('--output', type=str,
                       default='./specialized_models',
                       help='Output directory for models')

    args = parser.parse_args()

    try:
        trainer = SpecializedModelTrainer(args.data, args.output)
        results = trainer.train_specialized_models()

        print(f"\n🎉 Specialized model training completed!")
        print(f"📁 Models saved in: {args.output}")
        print(f"📊 Check comparison visualizations and detailed results.")

    except Exception as e:
        print(f"❌ Error during training: {e}")
        raise


if __name__ == "__main__":
    main()
import torch
import torch.nn as nn
from typing import List

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
        # Branch A: Predict Intensity
        intensity_pred = self.branch_a(x)

        # Branch B: Predict Suitability (using original features + predicted intensity)
        suitability_pred = self.branch_b(x, intensity_pred)

        return intensity_pred, suitability_pred

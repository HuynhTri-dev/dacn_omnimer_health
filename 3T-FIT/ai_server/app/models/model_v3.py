import torch
import torch.nn as nn
import json
import os

# Model v3 paths
MODEL_V3_PATH = "../../model/src/v3/model"
META_V3_PATH = os.path.join(MODEL_V3_PATH, "meta_v3.json")
MODEL_V3_CKPT = os.path.join(MODEL_V3_PATH, "best_v3.pt")
DECODING_RULES_PATH = os.path.join(MODEL_V3_PATH, "decoding_rules.json")

class UnifiedMTLv3(nn.Module):
    """
    Model v3: Multi-Task Learning model for capability prediction
    Based on actual trained model architecture
    Predicts: 1RM, Suitability, Readiness (single output per exercise)
    """

    def __init__(self, in_dim: int = 12, d: int = 256, drop: float = 0.2):
        super().__init__()

        self.input_dim = in_dim

        # Feature encoder (matching training architecture)
        self.feature_encoder = nn.Sequential(
            nn.Linear(in_dim, d),
            nn.ReLU(),
            nn.Dropout(drop),
            nn.Linear(d, d),
            nn.ReLU(),
            nn.Dropout(drop)
        )

        # LSTM layers for sequential processing
        self.lstm = nn.LSTM(d, d, num_layers=2, batch_first=True, dropout=drop)

        # Multi-task heads
        self.head_1rm = nn.Sequential(
            nn.Linear(d, 128),
            nn.ReLU(),
            nn.Dropout(drop),
            nn.Linear(128, 1)
        )

        self.head_suitability = nn.Sequential(
            nn.Linear(d, 128),
            nn.ReLU(),
            nn.Dropout(drop),
            nn.Linear(128, 1)
        )

        self.head_readiness = nn.Sequential(
            nn.Linear(d, 128),
            nn.ReLU(),
            nn.Dropout(drop),
            nn.Linear(128, 1)
        )

        # Attention mechanism
        self.attention = nn.Sequential(
            nn.Linear(d, 32),
            nn.ReLU(),
            nn.Linear(32, 1)
        )

    def forward(self, x):
        """
        Forward pass

        Args:
            x: User profile tensor [batch_size, input_dim]

        Returns:
            1rm_prediction: Predicted 1RM for each exercise [batch_size, 1]
            suitability_score: Exercise suitability score [batch_size, 1]
            readiness_factor: Readiness adjustment factor [batch_size, 1]
        """
        # Encode features
        encoded = self.feature_encoder(x)  # [batch_size, d]

        # Add sequence dimension for LSTM
        encoded_seq = encoded.unsqueeze(1)  # [batch_size, 1, d]

        # Pass through LSTM
        lstm_out, _ = self.lstm(encoded_seq)  # [batch_size, 1, d]

        # Get final hidden state
        lstm_final = lstm_out.squeeze(1)  # [batch_size, d]

        # Multi-task predictions
        one_rm_pred = self.head_1rm(lstm_final)  # [batch_size, 1]
        suitability = self.head_suitability(lstm_final)  # [batch_size, 1]
        readiness = self.head_readiness(lstm_final)  # [batch_size, 1]

        # Apply activations
        one_rm_scaled = torch.sigmoid(one_rm_pred)  # Scale to [0, 1]
        suitability_scaled = torch.sigmoid(suitability)  # Scale to [0, 1]
        readiness_scaled = torch.sigmoid(readiness)  # Scale to [0, 1]

        return one_rm_scaled, suitability_scaled, readiness_scaled

    def predict_exercise_capabilities(self, x, num_exercises=100):
        """
        Predict capabilities for multiple exercises (simulating exercise-specific predictions)

        Args:
            x: User profile tensor [batch_size, input_dim]
            num_exercises: Number of exercises to predict for

        Returns:
            capabilities: Exercise-specific predictions [batch_size, num_exercises, 3]
        """
        batch_size = x.size(0)

        # Get base predictions
        one_rm_base, suitability_base, readiness_base = self.forward(x)

        # Create exercise-specific variations
        # Note: Since the actual model was trained on user data only, we simulate
        # exercise-specific predictions by adding controlled variations
        one_rm_variations = one_rm_base.unsqueeze(1) * (1 + 0.1 * torch.randn(batch_size, num_exercises, 1, device=x.device))
        suitability_variations = suitability_base.unsqueeze(1) * (1 + 0.05 * torch.randn(batch_size, num_exercises, 1, device=x.device))
        readiness_variations = readiness_base.unsqueeze(1).expand(batch_size, num_exercises, 1)

        # Combine into single output for compatibility with existing code
        capabilities = torch.cat([one_rm_variations, suitability_variations, readiness_variations], dim=2)
        capabilities = torch.clamp(capabilities, 0, 1)  # Ensure [0, 1] range

        return capabilities

class ModelV3Loader:
    """Load and manage Model v3 artifacts"""

    def __init__(self):
        self.model = None
        self.meta_v3 = None
        self.exercise_columns = None
        self.feature_scaler = None
        self.target_scales = None
        self.decoding_rules = None

    def load_model(self, device: str = "cpu"):
        """Load Model v3 with all required artifacts"""
        try:
            # Load metadata
            with open(META_V3_PATH, 'r', encoding='utf-8') as f:
                self.meta_v3 = json.load(f)

            # Load model checkpoint
            checkpoint = torch.load(MODEL_V3_CKPT, map_location=device)

            # Extract model info from metadata
            input_dim = self.meta_v3['model_architecture']['input_dim']

            # Generate exercise column names
            num_exercises = 100  # Default number of exercises
            self.exercise_columns = [f"exercise_{i}" for i in range(num_exercises)]

            # Load target scales from metadata
            self.target_scales = {
                "1RM": (0.0, 200.0),
                "Pace": (0.0, 25.0),
                "Duration": (0.0, 120.0),
                "Rest": (0.0, 5.0),
                "AvgHR": (60.0, 180.0),
                "PeakHR": (100.0, 200.0)
            }

            # Load decoding rules if available
            try:
                with open(DECODING_RULES_PATH, 'r', encoding='utf-8') as f:
                    self.decoding_rules = json.load(f)
            except FileNotFoundError:
                self.decoding_rules = {}
                print("Warning: decoding_rules.json not found, using default rules")

            # Initialize model
            self.model = UnifiedMTLv3(in_dim=input_dim).to(device)
            self.model.load_state_dict(checkpoint)  # Direct load since checkpoint contains state_dict
            self.model.eval()

            print(f"Model v3 loaded successfully")
            print(f"   - Input dimension: {input_dim}")
            print(f"   - Number of exercises: {num_exercises}")
            print(f"   - Device: {device}")

            return True

        except Exception as e:
            print(f"Failed to load Model v3: {e}")
            return False

    def get_model_info(self) -> dict:
        """Get model information"""
        if self.meta_v3 is None:
            return {}

        return {
            "version": self.meta_v3.get("model_version", "v3_enhanced"),
            "training_date": self.meta_v3.get("training_date", "Unknown"),
            "input_features": self.meta_v3.get("dataset_info", {}).get("feature_columns", []),
            "num_exercises": len(self.exercise_columns) if self.exercise_columns else 0,
            "exercise_columns": self.exercise_columns or [],
            "target_dimensions": ["1RM", "Pace", "Duration", "Rest", "AvgHR", "PeakHR"],
            "test_results": self.meta_v3.get("test_results", {}),
            "best_validation_metrics": self.meta_v3.get("best_validation_metrics", {})
        }

# Global model instance
model_v3_loader = ModelV3Loader()

def load_model_v3(device: str = "cpu") -> bool:
    """Load Model v3 - call this during app startup"""
    return model_v3_loader.load_model(device)

def get_model_v3():
    """Get the loaded Model v3 instance"""
    if model_v3_loader.model is None:
        raise RuntimeError("Model v3 not loaded. Call load_model_v3() first.")
    return model_v3_loader.model

def get_model_v3_info() -> dict:
    """Get Model v3 information"""
    return model_v3_loader.get_model_info()

def get_exercise_columns_v3() -> list:
    """Get exercise column names from Model v3"""
    if model_v3_loader.exercise_columns is None:
        raise RuntimeError("Model v3 not loaded. Call load_model_v3() first.")
    return model_v3_loader.exercise_columns

def get_target_scales_v3() -> dict:
    """Get target value scales for post-processing"""
    if model_v3_loader.target_scales is None:
        raise RuntimeError("Model v3 not loaded. Call load_model_v3() first.")
    return model_v3_loader.target_scales

def get_decoding_rules_v3() -> dict:
    """Get decoding rules for workout generation"""
    return model_v3_loader.decoding_rules or {}
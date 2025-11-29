
import torch
import numpy as np
import os
import sys
import json
import pickle

# Add the current directory to path to import training_model
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from training_model import TwoBranchRecommendationModel, ModelTrainer

def load_and_predict():
    # Paths
    base_dir = os.path.dirname(os.path.abspath(__file__))
    model_dir = os.path.join(base_dir, 'personal_model_v4')
    metadata_path = os.path.join(model_dir, 'model_metadata.json')
    
    # 1. Load Metadata to get input dimension
    print(f"Loading metadata from {metadata_path}...")
    with open(metadata_path, 'r') as f:
        metadata = json.load(f)
    
    input_dim = metadata['input_dim']
    feature_names = metadata['feature_names']
    print(f"Model Input Dimension: {input_dim}")
    print(f"Features expected: {feature_names}")

    # 2. Initialize Model Architecture
    print("Initializing model architecture...")
    model = TwoBranchRecommendationModel(
        input_dim=input_dim,
        intensity_hidden_dims=[64, 32],
        suitability_hidden_dims=[128, 64],
        dropout_rate=0.2
    )

    # 3. Load Trained Weights
    print("Loading trained weights...")
    trainer = ModelTrainer(model)
    trainer.load_model(model_dir)
    
    # 4. Create a Dummy Input (Simulating a User + Exercise)
    # In a real app, you would construct this vector from User Profile + Exercise Metadata
    print("\nCreating dummy input for demonstration...")
    # Create random input within reasonable ranges (normalized by scaler later if needed, 
    # but here we assume the scaler handles raw inputs if we use the trainer's pipeline,
    # however, the trainer.load_model loads the scaler but doesn't attach it to the model forward pass directly.
    # We need to scale the input manually using the loaded scaler.
    
    # Let's generate random data roughly matching the feature count
    dummy_input_raw = np.random.rand(1, input_dim) 
    
    # Scale the input
    print("Scaling input...")
    dummy_input_scaled = trainer.scaler_X.transform(dummy_input_raw)
    
    # Convert to Tensor
    input_tensor = torch.FloatTensor(dummy_input_scaled)
    
    # 5. Make Prediction
    print("Making prediction...")
    model.eval() # Set to evaluation mode
    with torch.no_grad():
        predicted_intensity, predicted_suitability = model(input_tensor)
        
    # 6. Display Results
    print("\n" + "="*30)
    print("PREDICTION RESULTS")
    print("="*30)
    print(f"Predicted Intensity (RPE 1-10): {predicted_intensity.item():.2f}")
    print(f"Predicted Suitability (0-1):    {predicted_suitability.item():.4f}")
    
    if predicted_suitability.item() > 0.7:
        print(">> Verdict: HIGHLY SUITABLE ✅")
    elif predicted_suitability.item() > 0.4:
        print(">> Verdict: MODERATE / WARMUP ⚠️")
    else:
        print(">> Verdict: NOT SUITABLE ❌")
    print("="*30)

if __name__ == "__main__":
    load_and_predict()

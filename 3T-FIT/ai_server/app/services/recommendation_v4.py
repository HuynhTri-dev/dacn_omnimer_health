import torch
import pandas as pd
import numpy as np
import pickle
import json
import os
import logging
from typing import List, Dict, Any
from app.models.model_v4_arch import TwoBranchRecommendationModel
from app.api.schemas_v4 import RecommendRequestV4, RecommendationItem

logger = logging.getLogger(__name__)

# Global variables to hold model and artifacts
MODEL_V4 = None
SCALER_V4 = None
METADATA_V4 = None
DEVICE = 'cpu'

# Feature order MUST match training data exactly
FEATURE_COLUMNS = [
    'duration_min', 'avg_hr', 'max_hr', 'calories', 'fatigue', 'effort', 'mood', 
    'age', 'height_m', 'weight_kg', 'bmi', 'fat_percentage', 'resting_heartrate', 
    'experience_level', 'workout_frequency', 'gender', 'session_duration', 
    'estimated_1rm', 'pace', 'duration_capacity', 'rest_period', 'intensity_score', 
    'resistance_intensity', 'cardio_intensity', 'volume_load', 'rest_density', 
    'hr_reserve', 'calorie_efficiency'
]

def load_model_v4_artifacts(model_dir: str = "../model/src/v4/model_v4"):
    """Load Model v4 weights, scaler, and metadata"""
    global MODEL_V4, SCALER_V4, METADATA_V4, DEVICE
    
    try:
        DEVICE = 'cuda' if torch.cuda.is_available() else 'cpu'
        logger.info(f"Loading Model v4 artifacts from {model_dir} on {DEVICE}...")

        # 1. Load Metadata
        meta_path = os.path.join(model_dir, "model_metadata.json")
        if os.path.exists(meta_path):
            with open(meta_path, 'r') as f:
                METADATA_V4 = json.load(f)
            input_dim = METADATA_V4.get('architecture', {}).get('branch_a_input_dim', 28)
        else:
            logger.warning("Metadata not found, using default input_dim=28")
            input_dim = 28

        # 2. Load Scaler
        scaler_path = os.path.join(model_dir, "feature_scaler.pkl")
        if os.path.exists(scaler_path):
            with open(scaler_path, 'rb') as f:
                SCALER_V4 = pickle.load(f)
        else:
            logger.error("Scaler not found! Model v4 cannot function without scaler.")
            return False

        # 3. Load Model Weights
        weights_path = os.path.join(model_dir, "model_weights.pth")
        if os.path.exists(weights_path):
            model = TwoBranchRecommendationModel(input_dim=input_dim)
            model.load_state_dict(torch.load(weights_path, map_location=DEVICE))
            model.to(DEVICE)
            model.eval()
            MODEL_V4 = model
            logger.info("✅ Model v4 loaded successfully")
            return True
        else:
            logger.error("Model weights not found!")
            return False

    except Exception as e:
        logger.error(f"❌ Error loading Model v4: {e}")
        return False

def _map_sepa_to_numeric(value: str) -> int:
    """Map SePA text values to 1-5 scale"""
    mapping = {
        'very bad': 1, 'bad': 2, 'neutral': 3, 'good': 4, 'very good': 5, 'excellent': 5,
        'very low': 1, 'low': 2, 'medium': 3, 'high': 4, 'very high': 5,
        'beginner': 1, 'intermediate': 2, 'advanced': 3, 'pro': 4, 'expert': 4,
        'male': 1, 'female': 0, 'other': 0
    }
    return mapping.get(str(value).lower(), 3)

def _prepare_input_vector(req: RecommendRequestV4, exercise: Dict[str, Any]) -> np.ndarray:
    """Convert request + exercise candidate into feature vector"""
    
    # Extract user metrics
    metrics = req.health_metrics
    user_ctx = req.user_context
    state = req.current_state
    
    # 1. Basic User Stats
    age = metrics.age
    height = metrics.height_cm / 100.0 # Convert to meters
    weight = metrics.weight_kg
    bmi = metrics.bmi if metrics.bmi else weight / (height ** 2)
    fat = metrics.body_fat_percentage if metrics.body_fat_percentage else 20.0
    rhr = metrics.resting_heart_rate if metrics.resting_heart_rate else 70
    
    # 2. Context & State
    gender = _map_sepa_to_numeric(user_ctx.gender)
    exp_level = _map_sepa_to_numeric(user_ctx.experience_level)
    freq = user_ctx.workout_frequency
    mood = _map_sepa_to_numeric(state.mood)
    fatigue = _map_sepa_to_numeric(state.fatigue)
    effort = 3 # Default effort prediction
    
    # 3. Exercise Specifics (Estimated)
    # Note: For prediction, we use estimated values based on exercise metadata
    duration = req.goal_context.duration_preference_min or 45
    met = exercise.get('met_value', 5.0)
    
    # Estimate HR based on intensity/METs
    max_hr_age = 208 - (0.7 * age)
    avg_hr = rhr + (max_hr_age - rhr) * 0.6 # Assume 60% intensity
    max_hr = max_hr_age
    
    # Estimate Calories
    calories = (met * 3.5 * weight / 200) * duration
    
    # Derived Features (defaults for prediction)
    session_duration = duration / 60.0 # hours
    estimated_1rm = weight * 0.8 # Rough proxy if unknown
    pace = 0.0
    duration_capacity = duration * 60 # seconds
    rest_period = 60.0
    intensity_score = met # Use MET as proxy for intensity score
    
    # Advanced Derived Features (Calculated same as data_processor.py)
    resistance_intensity = intensity_score / estimated_1rm if estimated_1rm > 0 else 0
    cardio_intensity = avg_hr / max_hr if max_hr > 0 else 0
    volume_load = intensity_score * duration
    rest_density = rest_period / (rest_period + duration)
    hr_reserve = (avg_hr - rhr) / (max_hr - rhr) if (max_hr - rhr) > 0 else 0
    calorie_efficiency = calories / duration if duration > 0 else 0
    
    # Construct Feature Dictionary
    features = {
        'duration_min': duration,
        'avg_hr': avg_hr,
        'max_hr': max_hr,
        'calories': calories,
        'fatigue': fatigue,
        'effort': effort,
        'mood': mood,
        'age': age,
        'height_m': height,
        'weight_kg': weight,
        'bmi': bmi,
        'fat_percentage': fat,
        'resting_heartrate': rhr,
        'experience_level': exp_level,
        'workout_frequency': freq,
        'gender': gender,
        'session_duration': session_duration,
        'estimated_1rm': estimated_1rm,
        'pace': pace,
        'duration_capacity': duration_capacity,
        'rest_period': rest_period,
        'intensity_score': intensity_score,
        'resistance_intensity': resistance_intensity,
        'cardio_intensity': cardio_intensity,
        'volume_load': volume_load,
        'rest_density': rest_density,
        'hr_reserve': hr_reserve,
        'calorie_efficiency': calorie_efficiency
    }
    
    # Convert to ordered list matching FEATURE_COLUMNS
    vector = [features.get(col, 0.0) for col in FEATURE_COLUMNS]
    return np.array(vector, dtype=np.float32)

def recommend_v4(req: RecommendRequestV4) -> RecommendResponseV4:
    """Generate recommendations using Model v4"""
    global MODEL_V4, SCALER_V4
    
    if MODEL_V4 is None:
        raise Exception("Model v4 is not loaded")

    # 1. Get Candidate Exercises
    # In production, this would fetch from DB. Here we use input or mock.
    candidates = req.available_exercises or []
    if not candidates:
        # Mock candidates if none provided
        candidates = [
            {"id": "ex1", "name": "Barbell Squat", "met_value": 6.0},
            {"id": "ex2", "name": "Running", "met_value": 8.0},
            {"id": "ex3", "name": "Yoga", "met_value": 3.0},
            {"id": "ex4", "name": "HIIT", "met_value": 10.0},
            {"id": "ex5", "name": "Bench Press", "met_value": 5.0}
        ]
    
    recommendations = []
    
    # 2. Prepare Batch Input
    input_vectors = []
    for ex in candidates:
        # Handle both dict and object (Pydantic)
        ex_dict = ex.dict() if hasattr(ex, 'dict') else ex
        vec = _prepare_input_vector(req, ex_dict)
        input_vectors.append(vec)
        
    X = np.array(input_vectors)
    
    # 3. Scale Features
    X_scaled = SCALER_V4.transform(X)
    X_tensor = torch.FloatTensor(X_scaled).to(DEVICE)
    
    # 4. Inference
    with torch.no_grad():
        intensity_pred, suitability_pred = MODEL_V4(X_tensor)
        
    # 5. Process Results
    intensity_vals = intensity_pred.cpu().numpy().flatten()
    suitability_vals = suitability_pred.cpu().numpy().flatten()
    
    for i, ex in enumerate(candidates):
        ex_dict = ex.dict() if hasattr(ex, 'dict') else ex
        score = float(suitability_vals[i])
        rpe = float(intensity_vals[i])
        
        # Filter logic (e.g. threshold > 0.4)
        if score > 0.4:
            rec = RecommendationItem(
                exercise_id=ex_dict.get('id', f'ex_{i}'),
                exercise_name=ex_dict.get('name', 'Unknown'),
                predicted_rpe=round(rpe, 1),
                suitability_score=round(score, 3),
                reason=f"Matches your current mood and energy (Score: {int(score*100)}%)",
                suggested_params={"duration": req.goal_context.duration_preference_min}
            )
            recommendations.append(rec)
            
    # 6. Sort by Suitability
    recommendations.sort(key=lambda x: x.suitability_score, reverse=True)
    
    return RecommendResponseV4(
        recommendations=recommendations[:req.top_k],
        session_id="sess_v4_demo"
    )

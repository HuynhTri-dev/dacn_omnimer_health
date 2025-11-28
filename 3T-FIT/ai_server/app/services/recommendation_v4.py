import torch
import pandas as pd
import numpy as np
import pickle
import json
import os
import logging
from typing import List, Dict, Any

from models.model_v4_arch import TwoBranchRecommendationModel
from schema.recommend_schemas import RecommendInput, RecommendOutput, RecommendedExercise, SetDetail
from schema.common_schemas import HealthProfile
from utils.intensity_converter import convert_intensity_to_params

logger = logging.getLogger(__name__)

# Global variables
MODEL_V4 = None
SCALER_V4 = None
METADATA_V4 = None
DEVICE = 'cpu'

# Feature columns must match the trained model's input
FEATURE_COLUMNS = [
    'duration_min', 'avg_hr', 'max_hr', 'calories', 'fatigue', 'effort', 'mood', 
    'age', 'height_m', 'weight_kg', 'bmi', 'fat_percentage', 'resting_heartrate', 
    'experience_level', 'workout_frequency', 'gender', 'session_duration', 
    'estimated_1rm', 'pace', 'duration_capacity', 'rest_period', 'intensity_score', 
    'resistance_intensity', 'cardio_intensity', 'volume_load', 'rest_density', 
    'hr_reserve', 'calorie_efficiency'
]

def load_model_v4_artifacts(model_dir: str = "d:/dacn_omnimer_health/3T-FIT/ai_server/model/src/v4/personal_model_v4"):
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

def _map_text_to_numeric(value: str) -> int:
    """Map text values to 1-5 scale"""
    mapping = {
        'very bad': 1, 'bad': 2, 'neutral': 3, 'good': 4, 'very good': 5, 'excellent': 5,
        'very low': 1, 'low': 2, 'medium': 3, 'high': 4, 'very high': 5,
        'beginner': 1, 'intermediate': 2, 'advanced': 3, 'pro': 4, 'expert': 4,
        'male': 1, 'female': 0, 'other': 0
    }
    return mapping.get(str(value).lower(), 3)

def _prepare_input_vector(profile: HealthProfile, exercise: Dict[str, Any], goal_type: str) -> np.ndarray:
    """Convert request + exercise candidate into feature vector"""
    
    # 1. Basic User Stats
    age = profile.age
    height = profile.height / 100.0 # Convert cm to meters
    weight = profile.weight
    bmi = profile.bmi
    fat = profile.bodyFatPercentage
    rhr = profile.restingHeartRate
    
    # 2. Context & State
    gender = _map_text_to_numeric(profile.gender)
    exp_level = _map_text_to_numeric(profile.experienceLevel)
    freq = profile.workoutFrequency
    
    # Defaults for missing context in new schema
    mood = 3 # Neutral
    fatigue = 3 # Medium
    effort = 3 # Moderate
    
    # 3. Exercise Specifics (Estimated)
    duration = 60 # Default duration
    met = 5.0 # Default MET
    
    # Estimate HR based on intensity/METs
    max_hr_age = 208 - (0.7 * age)
    avg_hr = rhr + (max_hr_age - rhr) * 0.6 
    max_hr = max_hr_age
    
    # Estimate Calories
    calories = (met * 3.5 * weight / 200) * duration
    
    # Derived Features
    session_duration = duration / 60.0 # hours
    estimated_1rm = weight * 0.8 
    pace = 0.0
    duration_capacity = duration * 60 
    rest_period = 60.0
    intensity_score = met 
    
    # Advanced Derived Features
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

class RecommendationService:
    def __init__(self):
        if MODEL_V4 is None:
            load_model_v4_artifacts()
            
    def recommend_exercises(self, req: RecommendInput) -> RecommendOutput:
        """Generate recommendations using Model v4"""
        global MODEL_V4, SCALER_V4
        
        if MODEL_V4 is None:
            # Try loading again if not loaded
            if not load_model_v4_artifacts():
                raise Exception("Model v4 could not be loaded")

        candidates = req.exercises
        if not candidates:
            return RecommendOutput(exercises=[])
        
        # Prepare Batch Input
        input_vectors = []
        # Use first goal as primary for context
        primary_goal = req.goals[0].goalType if req.goals else "General"
        
        for ex in candidates:
            # We treat ExerciseInput as a dictionary for feature extraction
            # In a real scenario, we might need to fetch more metadata about the exercise (MET, etc.)
            # Here we just pass the object and let _prepare_input_vector handle defaults
            ex_dict = ex.dict()
            vec = _prepare_input_vector(req.healthProfile, ex_dict, primary_goal)
            input_vectors.append(vec)
            
        X = np.array(input_vectors)
        
        # Scale Features
        X_scaled = SCALER_V4.transform(X)
        X_tensor = torch.FloatTensor(X_scaled).to(DEVICE)
        
        # Inference
        with torch.no_grad():
            intensity_pred, suitability_pred = MODEL_V4(X_tensor)
            
        # Process Results
        intensity_vals = intensity_pred.cpu().numpy().flatten()
        suitability_vals = suitability_pred.cpu().numpy().flatten()
        
        recommended_exercises = []
        
        for i, ex in enumerate(candidates):
            suitability = float(suitability_vals[i])
            predicted_rpe = float(intensity_vals[i])
            
            # Filter logic (e.g. threshold > 0.4)
            if suitability > 0.4:
                # Determine exercise type (Mock logic: assume 'reps' unless name implies cardio)
                ex_type = "reps"
                name_lower = ex.exerciseName.lower()
                if any(x in name_lower for x in ['run', 'cardio', 'treadmill', 'cycle', 'bike']):
                    ex_type = "distance"
                elif any(x in name_lower for x in ['plank', 'hiit', 'yoga']):
                    ex_type = "time"
                
                # Generate Parameters using the utility function
                sets = convert_intensity_to_params(
                    exercise_name=ex.exerciseName,
                    exercise_type=ex_type,
                    intensity_score=predicted_rpe,
                    user_profile=req.healthProfile,
                    goal_type=primary_goal
                )
                
                recommended_exercises.append(RecommendedExercise(
                    name=ex.exerciseName,
                    sets=sets
                ))
                
        # Sort by suitability (implicitly handled by the order of processing if we wanted, but let's sort)
        # We need to pair them up to sort, but RecommendedExercise doesn't have score. 
        # For now, we return them in the order processed (which matches input order), 
        # or we could zip and sort.
        
        # Let's zip, sort, and unzip
        zipped = zip(recommended_exercises, suitability_vals)
        sorted_zipped = sorted(zipped, key=lambda x: x[1], reverse=True)
        final_recommendations = [x[0] for x in sorted_zipped if x[1] > 0.4]
        
        # Limit to k
        final_recommendations = final_recommendations[:req.k]
        
        return RecommendOutput(exercises=final_recommendations)

# Singleton instance
recommendation_service = RecommendationService()

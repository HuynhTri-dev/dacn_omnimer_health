from typing import List, Dict, Any
from schema.recommend_schemas import SetDetail
from schema.common_schemas import HealthProfile

def calculate_1rm_estimate(weight: float, reps: int) -> float:
    """Estimate 1RM using Epley formula."""
    if reps == 0: return 0
    return weight * (1 + reps / 30)

def convert_intensity_to_params(
    exercise_name: str,
    exercise_type: str, # "reps", "distance", "time"
    intensity_score: float, # Predicted RPE (1-10)
    user_profile: HealthProfile,
    goal_type: str
) -> List[SetDetail]:
    """
    Converts an AI predicted intensity score into concrete workout parameters (sets, reps, weight, etc.)
    based on user profile and goal.
    """
    sets: List[SetDetail] = []
    
    # Normalize intensity score to 0.0 - 1.0 for easier calculation if it's 1-10
    normalized_intensity = intensity_score / 10.0 if intensity_score > 1.0 else intensity_score
    
    # Default number of sets
    num_sets = 3
    if normalized_intensity > 0.8:
        num_sets = 4
    elif normalized_intensity < 0.4:
        num_sets = 2
        
    if exercise_type == "reps":
        # Logic for Resistance Training
        reps = 10 # Default
        percent_1rm = 0.7 # Default
        rest_seconds = 60
        
        if goal_type == "Strength":
            reps = 5
            percent_1rm = 0.85 + (normalized_intensity * 0.1) # Higher intensity -> closer to 1RM
            rest_seconds = 180
        elif goal_type == "MuscleGain":
            reps = 10
            percent_1rm = 0.70 + (normalized_intensity * 0.1)
            rest_seconds = 90
        elif goal_type == "Endurance":
            reps = 15
            percent_1rm = 0.50 + (normalized_intensity * 0.1)
            rest_seconds = 45
            
        # Estimate User Strength (Proxy using Body Weight if no history)
        # In a real system, we would query historical 1RM. 
        # Here we assume a beginner-intermediate level: Bench Press ~ 0.8 * BW, Squat ~ 1.2 * BW
        base_strength_ratio = 0.5 # Conservative default
        if user_profile.experienceLevel == "Intermediate":
            base_strength_ratio = 0.8
        elif user_profile.experienceLevel == "Advanced":
            base_strength_ratio = 1.2
            
        estimated_1rm = user_profile.weight * base_strength_ratio
        target_weight = estimated_1rm * percent_1rm
        
        # Round to nearest 2.5kg
        target_weight = round(target_weight / 2.5) * 2.5
        
        for _ in range(num_sets):
            sets.append(SetDetail(
                reps=reps,
                kg=target_weight,
                restAfterSetSeconds=rest_seconds
            ))
            
    elif exercise_type == "distance":
        # Logic for Cardio (Running/Cycling)
        # Intensity maps to Distance/Pace
        base_distance_km = 2.0 # Default 2km
        
        if user_profile.experienceLevel == "Intermediate":
            base_distance_km = 5.0
        elif user_profile.experienceLevel == "Advanced":
            base_distance_km = 10.0
            
        # Adjust by intensity
        target_distance = base_distance_km * (0.8 + (normalized_intensity * 0.4))
        
        for _ in range(1): # Cardio usually 1 big set or intervals
            sets.append(SetDetail(
                distance=round(target_distance, 2)
            ))
            
    elif exercise_type == "time":
        # Logic for HIIT/Plank
        base_duration_sec = 30
        rest_sec = 30
        
        if normalized_intensity > 0.6:
            base_duration_sec = 45
            rest_sec = 15
        if normalized_intensity > 0.8:
            base_duration_sec = 60
            rest_sec = 10
            
        for _ in range(num_sets):
            sets.append(SetDetail(
                duration=base_duration_sec,
                restAfterSetSeconds=rest_sec
            ))
            
    return sets

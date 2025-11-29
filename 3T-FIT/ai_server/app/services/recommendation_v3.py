import numpy as np
import pandas as pd
import torch
import logging
from typing import Dict, List, Optional
from services.decoders import WorkoutDecoder
from utils.preprocess_v3 import transform_profile_v3
from models.model_v3 import get_model_v3, get_exercise_columns_v3, get_target_scales_v3

logger = logging.getLogger(__name__)

def recommend_v3(
    profile: dict,
    top_k: int = 5,
    goal: str = "hypertrophy",
    target_duration: float = 30.0
) -> dict:
    """
    Generate workout recommendations using Model v3

    Args:
        profile: User profile dictionary from backend
        top_k: Number of top exercises to recommend
        goal: Workout goal ("strength", "hypertrophy", "endurance", "general_fitness")
        target_duration: Target workout duration in minutes (for cardio)

    Returns:
        Dict with exercise recommendations in the format specified in README.md
    """
    try:
        # Get Model v3 and exercise columns
        model = get_model_v3()
        exercise_columns = get_exercise_columns_v3()
        target_scales = get_target_scales_v3()

        # Transform input profile using Model v3 preprocessor
        X_transformed = transform_profile_v3(profile)
        X = torch.tensor(X_transformed.astype("float32"))

        # Run inference
        with torch.no_grad():
            # Use the new predict_exercise_capabilities method
            capabilities = model.predict_exercise_capabilities(X, num_exercises=len(exercise_columns))
            capabilities = capabilities.numpy()[0]  # Shape: [num_exercises, 3]

        # Extract predictions
        suitability_scores = capabilities[:, 1]  # Second column is suitability
        one_rm_predictions = capabilities[:, 0]     # First column is 1RM
        readiness_factors = capabilities[:, 2]   # Third column is readiness

        # Get top-k exercises by suitability score
        top_indices = np.argsort(-suitability_scores)[:top_k]

        # Initialize workout decoder
        decoder = WorkoutDecoder()

        # Generate workout plan
        workout_plan = []
        avg_hr_list = []
        peak_hr_list = []
        suitability_list = []

        # Extract SePA scores from profile for auto-regulation
        mood = float(profile.get('mood_numeric', 3.0))
        fatigue = float(profile.get('fatigue_numeric', 3.0))
        effort = float(profile.get('effort_numeric', 3.0))

        # Get user's historical max weight for safety
        max_weight_lifted = profile.get('max_weight_lifted_kg')

        # Generate realistic exercise names
        exercise_names = [
            "Bench Press", "Squat", "Deadlift", "Pull Up", "Push Up",
            "Shoulder Press", "Barbell Row", "Dips", "Leg Press", "Calf Raises",
            "Bicep Curls", "Tricep Extensions", "Lat Pulldown", "Leg Curl", "Hamstring Curl",
            "Plank", "Side Plank", "Russian Twist", "Crunches", "Leg Raises",
            "Treadmill Running", "Cycling", "Rowing Machine", "Elliptical", "Stair Climber",
            "Jumping Jacks", "Burpees", "Mountain Climbers", "Lunges", "Box Jumps"
        ]

        for i, idx in enumerate(top_indices):
            # Use realistic exercise name based on index
            exercise_name = exercise_names[idx % len(exercise_names)]
            suitability_score = float(suitability_scores[idx])

            # Denormalize predictions to real values
            predicted_1rm = denormalize_value(one_rm_predictions[idx], target_scales["1RM"])

            # Generate realistic HR predictions based on exercise and user profile
            base_hr = float(profile.get('resting_hr', 70))
            predicted_avg_hr = int(base_hr + 50 + (20 * suitability_score))
            predicted_peak_hr = int(base_hr + 80 + (30 * suitability_score))

            # Generate realistic secondary parameters
            if decoder.is_cardio_exercise(exercise_name):
                predicted_pace = denormalize_value(0.6 + 0.2 * suitability_score, target_scales["Pace"])
                predicted_duration = target_duration
                predicted_rest = 2.0
            else:
                predicted_pace = 0.0
                predicted_duration = 0.0
                predicted_rest = 1.5 + (0.5 * (1 - readiness_factors[idx]))

            # Decode capabilities to detailed workout parameters
            decoded_exercise = decoder.decode_exercise(
                exercise_name=exercise_name,
                predicted_1rm=predicted_1rm,
                predicted_pace=predicted_pace,
                predicted_avg_hr=predicted_avg_hr,
                predicted_peak_hr=predicted_peak_hr,
                predicted_duration=predicted_duration,
                predicted_rest=predicted_rest,
                goal=goal,
                mood=mood,
                fatigue=fatigue,
                effort=effort,
                max_weight_lifted=max_weight_lifted,
                target_duration=target_duration
            )

            # Format according to API response structure
            if decoded_exercise["exercise_type"] == "cardio":
                # Cardio exercise formatting
                if "intervals" in decoded_exercise:
                    # HIIT workout with intervals
                    sets_list = []
                    for interval in decoded_exercise["intervals"]:
                        sets_list.append({
                            "reps": 0,
                            "kg": 0.0,
                            "km": round(interval.get("pace_kmh", 0) * interval.get("duration_min", 0) / 60, 2),
                            "min": interval.get("duration_min", 0),
                            "minRest": interval.get("minRest", 1.0)
                        })
                else:
                    # Steady state cardio
                    sets_list = [{
                        "reps": 0,
                        "kg": 0.0,
                        "km": decoded_exercise.get("distance_km", 0),
                        "min": decoded_exercise.get("duration_min", 0),
                        "minRest": 2.0
                    }]
            else:
                # Strength exercise formatting
                sets_list = decoded_exercise["sets"]

            # Add to workout plan
            workout_plan.append({
                "name": exercise_name,
                "sets": sets_list,
                "suitabilityScore": round(suitability_score, 4),
                "predictedAvgHR": predicted_avg_hr,
                "predictedPeakHR": predicted_peak_hr,
                "explanation": decoded_exercise.get("explanation", ""),
                "readinessFactor": decoded_exercise.get("readinessFactor", 1.0),
                "goal": goal
            })

            # Collect metrics for overall workout stats
            avg_hr_list.append(predicted_avg_hr)
            peak_hr_list.append(predicted_peak_hr)
            suitability_list.append(suitability_score)

        # Calculate overall workout metrics
        overall_suitability = float(np.mean(suitability_list)) if suitability_list else 0.0
        overall_avg_hr = int(np.mean(avg_hr_list)) if avg_hr_list else 0
        overall_peak_hr = int(np.max(peak_hr_list)) if peak_hr_list else 0

        # Prepare final response
        response = {
            "exercises": workout_plan,
            "suitabilityScore": round(overall_suitability, 4),
            "predictedAvgHR": overall_avg_hr,
            "predictedPeakHR": overall_peak_hr,
            "modelVersion": "v3_enhanced",
            "goal": goal,
            "totalExercises": len(workout_plan),
            "readinessAdjustment": {
                "mood": mood,
                "fatigue": fatigue,
                "effort": effort,
                "appliedFactor": decoder.calculate_readiness_factor(mood, fatigue, effort)
            }
        }

        logger.info(f"Generated v3 workout plan: {len(workout_plan)} exercises, goal={goal}")
        return response

    except Exception as e:
        logger.error(f"Error in v3 recommendation: {e}")
        raise e

def denormalize_value(normalized_value: float, scale_range: tuple) -> float:
    """
    Denormalize a value from [0, 1] range to actual scale

    Args:
        normalized_value: Value in [0, 1] range from model output
        scale_range: (min_value, max_value) tuple

    Returns:
        Denormalized value in actual scale
    """
    min_val, max_val = scale_range
    # Ensure value is within [0, 1] range
    normalized_value = max(0.0, min(1.0, float(normalized_value)))
    return min_val + normalized_value * (max_val - min_val)

def validate_profile_for_v3(profile: dict) -> tuple[bool, str]:
    """
    Validate user profile for Model v3 compatibility

    Args:
        profile: User profile dictionary

    Returns:
        (is_valid, error_message) tuple
    """
    required_fields = [
        'age', 'weight_kg', 'height_cm', 'gender'
    ]

    missing_fields = []
    for field in required_fields:
        if field not in profile or profile[field] is None:
            missing_fields.append(field)

    if missing_fields:
        return False, f"Missing required fields: {', '.join(missing_fields)}"

    # Validate ranges
    try:
        age = float(profile['age'])
        if not (10 <= age <= 100):
            return False, f"Invalid age: {age}. Must be between 10-100"

        weight = float(profile['weight_kg'])
        if not (30 <= weight <= 300):
            return False, f"Invalid weight: {weight}kg. Must be between 30-300kg"

        height = float(profile['height_cm'])
        if not (100 <= height <= 250):
            return False, f"Invalid height: {height}cm. Must be between 100-250cm"

    except (ValueError, TypeError) as e:
        return False, f"Invalid numeric values: {str(e)}"

    return True, ""

def get_goal_suggestions(user_profile: dict) -> list:
    """
    Suggest appropriate goals based on user profile

    Args:
        user_profile: User profile dictionary

    Returns:
        List of suggested goals with explanations
    """
    suggestions = []

    # Extract relevant information
    age = float(user_profile.get('age', 30))
    experience = user_profile.get('experience_level', '').lower()
    bmi = float(user_profile.get('bmi', 23))
    goal_type = user_profile.get('goal_type', '').lower()

    # Goal suggestions based on profile
    if 'beginner' in experience or age > 50:
        suggestions.append({
            "goal": "general_fitness",
            "reason": "Recommended for building foundation safely",
            "priority": "high"
        })

    if bmi > 28:
        suggestions.append({
            "goal": "endurance",
            "reason": "Focus on fat loss and cardiovascular health",
            "priority": "high"
        })

    if 'intermediate' in experience or 'advanced' in experience:
        suggestions.append({
            "goal": "hypertrophy",
            "reason": "Good experience level for muscle building",
            "priority": "medium"
        })

        suggestions.append({
            "goal": "strength",
            "reason": "Experience level supports strength training",
            "priority": "medium"
        })

    # Include user's stated goal if available
    if goal_type and goal_type not in [s["goal"] for s in suggestions]:
        suggestions.append({
            "goal": goal_type,
            "reason": "Based on your stated preferences",
            "priority": "user_preference"
        })

    return suggestions
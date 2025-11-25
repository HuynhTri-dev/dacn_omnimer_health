import json
import argparse
import sys
import os
import pandas as pd
import numpy as np
from pathlib import Path

# Add the current directory to sys.path to import modules
current_dir = Path(__file__).parent.absolute()
sys.path.append(str(current_dir))

try:
    from test_v3_model import V3ModelTester
    from train_v3_enhanced import map_sepa_to_numeric, MOOD_MAPPING, FATIGUE_MAPPING, EFFORT_MAPPING
except ImportError as e:
    print(f"Error importing modules: {e}")
    sys.exit(1)

def map_goal_type(goal_type):
    """Map user goal type to model goal type"""
    goal_map = {
        'WeightLoss': 'endurance',
        'MuscleGain': 'hypertrophy',
        'Strength': 'strength',
        'GeneralFitness': 'general_fitness'
    }
    # Default to general_fitness if not found or partial match
    for key, value in goal_map.items():
        if key.lower() in goal_type.lower():
            return value
    return 'general_fitness'

def process_workout_request(input_file, artifacts_dir, output_file=None):
    """
    Process a workout request and generate the formatted output
    """
    # 1. Load Input Data
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            request_data = json.load(f)
    except Exception as e:
        print(f"Error reading input file: {e}")
        return

    health_profile = request_data.get('healthProfile', {})
    goals = request_data.get('goals', [])
    exercises = request_data.get('exercises', [])

    # 2. Prepare User Profile for Model
    # Map health_profile fields to model features
    user_profile = {
        'age': health_profile.get('age', 30),
        'weight_kg': health_profile.get('weight', 70),
        'height_m': health_profile.get('height', 175) / 100.0, # Convert cm to m
        'experience_level': 2, # Default intermediate if not mapped
        'workout_frequency': health_profile.get('workoutFrequency', 3),
        'resting_heartrate': health_profile.get('restingHeartRate', 70),
        'gender': health_profile.get('gender', 'male'),
        # Default SePA values if not present (could be in healthStatus or separate)
        'mood_numeric': 3,
        'fatigue_numeric': 3,
        'effort_numeric': 3
    }
    
    # Calculate BMI if not present
    if 'bmi' in health_profile:
        user_profile['bmi'] = health_profile['bmi']
    else:
        user_profile['bmi'] = user_profile['weight_kg'] / (user_profile['height_m'] ** 2)

    # Map experience level string to numeric if needed
    exp_map = {'Beginner': 1, 'Intermediate': 2, 'Advanced': 3, 'Expert': 4}
    exp_str = health_profile.get('experienceLevel', 'Intermediate')
    user_profile['experience_level'] = exp_map.get(exp_str, 2)

    # 3. Initialize Model
    tester = V3ModelTester(artifacts_dir)
    
    # 4. Make Prediction
    predictions = tester.predict(user_profile)
    
    # 5. Generate Workout Recommendations
    # Determine primary goal
    primary_goal_type = goals[0]['goalType'] if goals else 'GeneralFitness'
    model_goal = map_goal_type(primary_goal_type)
    
    # Generate recommendations using the model's logic
    # We pass the specific goal we want
    recs = tester.generate_workout_recommendations(predictions, [model_goal])
    rec_data = recs[0]['workout_recommendations'][model_goal]
    
    # 6. Format Output
    formatted_exercises = []
    
    for exercise in exercises:
        exercise_name = exercise.get('exerciseName', 'Unknown Exercise')
        
        # Normalize and clamp values according to user constraints
        # Sets: > 1 and < 5 => [2, 4]
        raw_sets = rec_data['sets']['recommended']
        num_sets = int(max(2, min(4, round(raw_sets))))
        
        # Reps: > 5 and < 20 => [6, 19]
        raw_reps = rec_data['reps']['recommended']
        reps = int(max(6, min(19, round(raw_reps))))
        
        # Weight: Round to nearest 5 for gym compatibility
        raw_weight = rec_data['training_weight_kg']['recommended']
        weight = int(5 * round(raw_weight / 5))
        
        # Rest: Integer (minutes)
        rest = int(round(rec_data['rest_minutes']['recommended']))
        
        sets_data = []
        
        for _ in range(num_sets):
            set_info = {
                "reps": reps,
                "kg": weight,
                "km": 0, # Default for non-cardio
                "min": 0, # Default for non-cardio
                "minRest": rest
            }
            
            # Simple logic to adjust for cardio based on exercise name keywords
            if any(k in exercise_name.lower() for k in ['run', 'jog', 'cycle', 'bike', 'cardio']):
                set_info['kg'] = 0
                set_info['reps'] = 0
                set_info['min'] = 15 # Default cardio duration
                set_info['km'] = 3 # Default distance
            
            sets_data.append(set_info)
            
        formatted_exercises.append({
            "name": exercise_name,
            "sets": sets_data
        })
    
    output_data = {
        "exercises": formatted_exercises,
        "suitabilityScore": round(predictions['suitability_score'][0], 3),
        "predictedAvgHR": 0, 
        "predictedPeakHR": 0,
        "readinessFactor": round(predictions['readiness_factor'][0], 3),
        "predicted1RM": round(predictions['predicted_1rm'][0], 1)
    }
    
    # Print or Save Output
    json_output = json.dumps(output_data, indent=2)
    print(json_output)
    
    if output_file:
        with open(output_file, 'w') as f:
            f.write(json_output)
        print(f"\nOutput saved to {output_file}")

def main():
    parser = argparse.ArgumentParser(description='Generate Workout Plan JSON')
    parser.add_argument('--input', type=str, required=True, help='Input JSON file path')
    parser.add_argument('--output', type=str, help='Output JSON file path')
    parser.add_argument('--artifacts', type=str, default='./model', help='Path to model artifacts')
    
    args = parser.parse_args()
    
    process_workout_request(args.input, args.artifacts, args.output)

if __name__ == "__main__":
    main()

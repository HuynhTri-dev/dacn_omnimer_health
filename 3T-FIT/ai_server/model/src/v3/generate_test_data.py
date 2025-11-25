"""
Script to generate test data for workout plan generation.
Reads exercise names from JSON files in the exercises directory and creates
random health profiles for testing.
"""

import json
import random
import os
from pathlib import Path

def load_exercise_names(exercises_dir):
    """
    Load all exercise names from JSON files in the exercises directory.
    
    Args:
        exercises_dir: Path to the exercises directory
        
    Returns:
        List of exercise names
    """
    exercise_names = []
    exercises_path = Path(exercises_dir)
    
    if not exercises_path.exists():
        print(f"Warning: Exercises directory not found: {exercises_dir}")
        return []
    
    # Get all JSON files in the exercises directory
    json_files = list(exercises_path.glob("*.json"))
    
    for json_file in json_files:
        try:
            with open(json_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                # Extract the name field from the JSON
                name = data.get('name', json_file.stem.replace('_', ' '))
                exercise_names.append(name)
        except Exception as e:
            print(f"Warning: Could not read {json_file.name}: {e}")
            # Use filename as fallback
            exercise_names.append(json_file.stem.replace('_', ' '))
    
    return sorted(exercise_names)

def generate_random_health_profile():
    """
    Generate a random health profile for testing.
    
    Returns:
        Dictionary with random health profile data
    """
    genders = ['male', 'female']
    experience_levels = ['Beginner', 'Intermediate', 'Advanced', 'Expert']
    
    age = random.randint(18, 65)
    weight = random.randint(50, 120)  # kg
    height = random.randint(150, 200)  # cm
    gender = random.choice(genders)
    experience = random.choice(experience_levels)
    workout_frequency = random.randint(2, 7)
    resting_heart_rate = random.randint(50, 90)
    
    # Calculate BMI
    height_m = height / 100.0
    bmi = round(weight / (height_m ** 2), 2)
    
    return {
        "age": age,
        "weight": weight,
        "height": height,
        "bmi": bmi,
        "gender": gender,
        "experienceLevel": experience,
        "workoutFrequency": workout_frequency,
        "restingHeartRate": resting_heart_rate,
        "healthStatus": "Good"
    }

def generate_test_request(exercises_dir, num_exercises=5):
    """
    Generate a complete test request with random health profile and exercises.
    
    Args:
        exercises_dir: Path to the exercises directory
        num_exercises: Number of exercises to include in the request
        
    Returns:
        Dictionary with complete test request data
    """
    # Load available exercises
    exercise_names = load_exercise_names(exercises_dir)
    
    if not exercise_names:
        print("Warning: No exercises found. Using default exercise names.")
        exercise_names = [
            "Barbell Squat",
            "Bench Press",
            "Deadlift",
            "Pull-ups",
            "Dumbbell Curl"
        ]
    
    # Select random exercises
    selected_exercises = random.sample(
        exercise_names, 
        min(num_exercises, len(exercise_names))
    )
    
    # Generate random health profile
    health_profile = generate_random_health_profile()
    
    # Define goal types
    goal_types = ['WeightLoss', 'MuscleGain', 'Strength', 'GeneralFitness']
    primary_goal = random.choice(goal_types)
    
    # Create request structure
    request = {
        "healthProfile": health_profile,
        "goals": [
            {
                "goalType": primary_goal,
                "targetValue": random.randint(5, 20),
                "deadline": "2025-12-31"
            }
        ],
        "exercises": [
            {"exerciseName": name} for name in selected_exercises
        ]
    }
    
    return request

def main():
    """
    Main function to generate and save test data.
    """
    # Determine paths
    current_dir = Path(__file__).parent.absolute()
    project_root = current_dir.parent.parent.parent.parent
    exercises_dir = project_root / "exercises"
    
    print(f"Looking for exercises in: {exercises_dir}")
    
    # Generate multiple test cases
    num_test_cases = 3
    
    for i in range(1, num_test_cases + 1):
        # Generate test request
        test_request = generate_test_request(
            exercises_dir=str(exercises_dir),
            num_exercises=random.randint(3, 8)
        )
        
        # Save to file
        output_file = current_dir / f"test_request_{i}.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(test_request, f, indent=2, ensure_ascii=False)
        
        print(f"\n{'='*60}")
        print(f"Test Case {i} generated: {output_file.name}")
        print(f"{'='*60}")
        print(f"Health Profile:")
        print(f"  - Age: {test_request['healthProfile']['age']}")
        print(f"  - Gender: {test_request['healthProfile']['gender']}")
        print(f"  - Weight: {test_request['healthProfile']['weight']} kg")
        print(f"  - Height: {test_request['healthProfile']['height']} cm")
        print(f"  - BMI: {test_request['healthProfile']['bmi']}")
        print(f"  - Experience: {test_request['healthProfile']['experienceLevel']}")
        print(f"  - Workout Frequency: {test_request['healthProfile']['workoutFrequency']} days/week")
        print(f"\nGoal: {test_request['goals'][0]['goalType']}")
        print(f"\nExercises ({len(test_request['exercises'])}):")
        for ex in test_request['exercises']:
            print(f"  - {ex['exerciseName']}")
    
    print(f"\n{'='*60}")
    print(f"✅ Generated {num_test_cases} test cases successfully!")
    print(f"{'='*60}")
    print(f"\nTo test, run:")
    print(f"  python generate_workout_plan.py --input test_request_1.json --output output_1.json")

if __name__ == "__main__":
    main()

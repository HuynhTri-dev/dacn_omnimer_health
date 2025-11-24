# -*- coding: utf-8 -*-
"""
test_inference_demo.py

Script demo để test Exercise Recommendation Model
Tạo nhiều test cases khác nhau và hiển thị kết quả
"""

import json
import os
import torch  # Cần import torch để fix lỗi

# --- FIX LỖI UNPICKLING ERROR (PYTORCH 2.6+) ---
# Đoạn này ép torch.load luôn dùng weights_only=False mặc định
# Giúp load được model cũ chứa đối tượng numpy mà không cần sửa file thư viện
_original_load = torch.load

def _safe_load(*args, **kwargs):
    if 'weights_only' not in kwargs:
        kwargs['weights_only'] = False
    return _original_load(*args, **kwargs)

torch.load = _safe_load
# -----------------------------------------------

from inference_exercise_recommendation import ExerciseRecommender

def print_separator(char='=', length=80):
    print(char * length)

def print_recommendation(rec):
    """In thông tin một recommendation"""
    print(f"\n{rec['rank']}. {rec['name']}")
    print(f"   {'─' * 70}")
    print(f"   📊 Suitability Score: {rec['suitabilityScore']:.3f}")
    print(f"   💪 Sets: {len(rec['sets'])}")
    print(f"   🔁 Reps: {rec['sets'][0]['reps']}")
    print(f"   ⚖️  Weight: {rec['sets'][0]['kg']:.1f} kg")
    print(f"   ⏱️  Rest: {rec['sets'][0]['minRest']:.1f} min")
    print(f"   ❤️  Heart Rate: {rec['predictedAvgHR']:.0f} avg / {rec['predictedPeakHR']:.0f} peak")
    
    # Hiển thị thông tin cardio nếu có
    if rec['sets'][0]['km'] > 0:
        print(f"   🏃 Distance: {rec['sets'][0]['km']:.2f} km")
    if rec['sets'][0]['min'] > 0:
        print(f"   ⏰ Duration: {rec['sets'][0]['min']:.1f} min")

def test_case_1():
    """Test Case 1: Người mới bắt đầu"""
    print_separator()
    print("TEST CASE 1: NGƯỜI MỚI BẮT ĐẦU (BEGINNER)")
    print_separator()
    
    health_profile = {
        "age": 22,
        "height_m": 1.70,
        "weight_kg": 65,
        "bmi": 22.5,
        "fat_percentage": 18.0,
        "resting_heartrate": 70,
        "workout_frequency": 2,
        "gender": "Male",
        "experience_level": "Beginner",
        "activity_level": "Low"
    }
    
    exercises = [
        "Push Up", "Squat", "Plank", "Jumping Jack",
        "Bicep Curl", "Lateral Raise", "Leg Press",
        "Seated Row", "Treadmill Walking", "Cycling"
    ]
    
    return health_profile, exercises

def test_case_2():
    """Test Case 2: Người có kinh nghiệm"""
    print_separator()
    print("TEST CASE 2: NGƯỜI CÓ KINH NGHIỆM (ADVANCED)")
    print_separator()
    
    health_profile = {
        "age": 28,
        "height_m": 1.78,
        "weight_kg": 80,
        "bmi": 25.2,
        "fat_percentage": 12.0,
        "resting_heartrate": 58,
        "workout_frequency": 5,
        "gender": "Male",
        "experience_level": "Advanced",
        "activity_level": "High"
    }
    
    exercises = [
        "Barbell Bench Press (Wide Grip)", "Squat", "Pull-Up",
        "Decline Bench Press", "Stiff Leg Deadlift",
        "Lat Pulldown", "Seated Row (Wide Grip)",
        "Overhead Triceps Extension", "Hammer Curl", "HIIT"
    ]
    
    return health_profile, exercises

def test_case_3():
    """Test Case 3: Nữ giới muốn giảm cân"""
    print_separator()
    print("TEST CASE 3: NỮ GIỚI MUỐN GIẢM CÂN")
    print_separator()
    
    health_profile = {
        "age": 30,
        "height_m": 1.62,
        "weight_kg": 68,
        "bmi": 25.9,
        "fat_percentage": 28.0,
        "resting_heartrate": 72,
        "workout_frequency": 3,
        "gender": "Female",
        "experience_level": "Intermediate",
        "activity_level": "Moderate"
    }
    
    exercises = [
        "Cardio", "Cycling", "Treadmill Walking", "Swimming",
        "Burpee", "Jumping Jack", "High Knee Skips",
        "Yoga", "Plank", "Leg Extension"
    ]
    
    return health_profile, exercises

def test_case_4():
    """Test Case 4: Người muốn tăng cơ"""
    print_separator()
    print("TEST CASE 4: NGƯỜI MUỐN TĂNG CƠ (MUSCLE BUILDING)")
    print_separator()
    
    health_profile = {
        "age": 26,
        "height_m": 1.75,
        "weight_kg": 75,
        "bmi": 24.5,
        "fat_percentage": 14.0,
        "resting_heartrate": 62,
        "workout_frequency": 5,
        "gender": "Male",
        "experience_level": "Intermediate",
        "activity_level": "High"
    }
    
    exercises = [
        "Barbell Bench Press (Wide Grip)", "Squat", "Stiff Leg Deadlift",
        "Pull-Up", "Seated Row", "Leg Press",
        "Bicep Curl", "Triceps Pushdown", "Lateral Raise",
        "Leg Extension", "Lying Leg Curl", "Seated Chest Press"
    ]
    
    return health_profile, exercises

def run_test(recommender, test_name, health_profile, exercises, top_k=5):
    """Chạy một test case"""
    print(f"\n👤 Health Profile:")
    print(f"   Age: {health_profile['age']}, Gender: {health_profile['gender']}")
    print(f"   Height: {health_profile['height_m']}m, Weight: {health_profile['weight_kg']}kg")
    print(f"   BMI: {health_profile['bmi']:.1f}, Body Fat: {health_profile['fat_percentage']:.1f}%")
    print(f"   Experience: {health_profile['experience_level']}, Activity: {health_profile['activity_level']}")
    print(f"   Workout Frequency: {health_profile['workout_frequency']} times/week")
    
    print(f"\n🏋️ Input Exercises ({len(exercises)}):")
    print(f"   {', '.join(exercises[:5])}...")
    
    # Get recommendations
    recommendations = recommender.recommend(
        health_profile=health_profile,
        exercise_names=exercises,
        top_k=top_k
    )
    
    print(f"\n✨ TOP {top_k} RECOMMENDATIONS:")
    print_separator('─')
    
    for rec in recommendations:
        print_recommendation(rec)
    
    return recommendations

def main():
    """Main function"""
    print_separator('═')
    print("🎯 EXERCISE RECOMMENDATION MODEL - DEMO TEST")
    print_separator('═')
    
    # Load model
    artifacts_dir = '../artifacts_exercise_rec'
    print(f"\n📦 Loading model from: {artifacts_dir}")
    recommender = ExerciseRecommender(artifacts_dir)
    
    # Run all test cases
    test_cases = [
        ("Beginner", test_case_1()),
        ("Advanced", test_case_2()),
        ("Weight Loss", test_case_3()),
        ("Muscle Building", test_case_4())
    ]
    
    all_results = {}
    
    for test_name, (health_profile, exercises) in test_cases:
        recommendations = run_test(
            recommender, 
            test_name, 
            health_profile, 
            exercises, 
            top_k=5
        )
        all_results[test_name] = recommendations
        print("\n")
    
    # Save all results
    output_file = 'test_results.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(all_results, f, ensure_ascii=False, indent=2)
    
    print_separator('═')
    print(f"✅ All tests completed!")
    print(f"📄 Results saved to: {output_file}")
    print_separator('═')

if __name__ == '__main__':
    main()
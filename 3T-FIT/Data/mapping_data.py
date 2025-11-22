# -*- coding: utf-8 -*-
"""
Script để tạo file xlsx mới dựa trên dữ liệu từ gym_member_exercise_tracking.xlsx
và cấu trúc từ merged_omni_health_dataset.xlsx.

Sử dụng các công thức từ:
- CALORIES_BURNED_CALCULATE.md
- HEALTH_METRIC_CALCULATE.md
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random
import sys
import io

# Set UTF-8 encoding for console output
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

# ==================== CÔNG THỨC TÍNH TOÁN ====================

def calculate_hr_max(age):
    """
    Công thức Tanaka (2001) - Nhịp tim tối đa
    HR_max = 208 - (0.7 × Age)
    """
    return 208 - (0.7 * age)

def calculate_calories_mets(mets, weight_kg, duration_min):
    """
    Công thức METs chuẩn
    CB (kcal) = (METs × 3.5 × Weight(kg) / 200) × Duration(min)
    """
    return (mets * 3.5 * weight_kg / 200) * duration_min

def get_intensity_level(workout_type, avg_hr, hr_max, resting_hr):
    """
    Xác định cường độ tập luyện dựa trên loại bài tập và nhịp tim
    
    Intensity zones:
    - Low: 50-60% HRR
    - Medium: 60-70% HRR
    - High: 70-85% HRR
    - Maximal: >85% HRR
    """
    # Tính HRR (Heart Rate Reserve)
    hrr_percent = ((avg_hr - resting_hr) / (hr_max - resting_hr)) * 100
    
    # Nếu có nhịp tim, dùng HRR để xác định
    if hrr_percent >= 85:
        return 'Maximal'
    if hrr_percent >= 70:
        return 'High'
    elif hrr_percent >= 60:
        return 'Medium'
    else:
        return 'Low'

def get_mets_value(workout_type, intensity):
    """
    Lấy giá trị METs dựa trên loại bài tập và cường độ
    Tham khảo: https://pacompendium.com/
    """
    mets_map = {
        'Cardio': {'Low': 3.5, 'Medium': 5.0, 'High': 7.0, 'Maximal': 9.0},
        'Strength': {'Low': 3.0, 'Medium': 5.0, 'High': 6.0, 'Maximal': 7.0},
        'Yoga': {'Low': 2.5, 'Medium': 3.0, 'High': 4.0, 'Maximal': 5.0},
        'HIIT': {'Low': 8.0, 'Medium': 10.0, 'High': 12.0, 'Maximal': 14.0}
    }
    
    return mets_map.get(workout_type, {}).get(intensity, 5.0)

# ==================== XỬ LÝ DỮ LIỆU ====================

def load_exercise_data():
    """Đọc dữ liệu bài tập từ merged_omni_health_dataset.xlsx"""
    file_path = r'd:\dacn_omnimer_health\3T-FIT\Data\data\merged_omni_health_dataset.xlsx'
    df = pd.read_excel(file_path)
    
    # Lọc các bài tập có exercise_name
    exercises = df[df['exercise_name'].notna()].copy()
    
    return exercises

def generate_user_profile_id(index):
    """Tạo User Health Profile ID"""
    return f"UH{index + 1}"

def generate_workout_id(index, workout_type):
    """Tạo Workout ID"""
    type_prefix = workout_type[0].upper()
    return f"W{type_prefix}{index + 1}"

def map_experience_level(level):
    """
    Chuyển đổi Experience Level từ số sang text
    1: Beginner, 2: Intermediate, 3: Advanced
    """
    level_map = {1: 'Beginner', 2: 'Intermediate', 3: 'Advanced'}
    return level_map.get(level, 'Intermediate')

def estimate_whr(gender, bmi, fat_percentage):
    """
    Ước tính WHR (Waist-to-Hip Ratio) dựa trên BMI và fat percentage
    """
    if gender.lower() == 'male':
        base_whr = 0.85 + (bmi - 25) * 0.01 + (fat_percentage - 15) * 0.005
        return max(0.75, min(base_whr, 1.0))
    else:
        base_whr = 0.75 + (bmi - 25) * 0.01 + (fat_percentage - 20) * 0.005
        return max(0.65, min(base_whr, 0.95))

def map_activity_level(workout_frequency):
    """
    Chuyển đổi workout frequency sang activity level
    1-2 days: Sedentary
    3-4 days: Moderate
    5-7 days: Active
    """
    if workout_frequency <= 2:
        return 'Sedentary'
    elif workout_frequency <= 4:
        return 'Moderate'
    else:
        return 'Active'

def generate_strength_sets_format():
    """
    Tạo format cho sets/reps/weight/timeresteachset
    Format: 8x50x3 | 8x50x3 | 8x50x5
    - 8 reps (5-15)
    - 50 kg (1-99)
    - 3 phút nghỉ (1-5)
    - Số sets: 1-5
    """
    num_sets = random.randint(1, 5)
    sets_list = []
    
    for _ in range(num_sets):
        reps = random.randint(5, 15)
        weight = random.randint(1, 99)
        rest_time = random.randint(1, 5)
        sets_list.append(f"{reps}x{weight}x{rest_time}")
    
    return ' | '.join(sets_list)

def generate_cardio_sets_format(total_duration_min):
    """
    Tạo format cho sets/time_m/timeresteachset
    Format: 1x3 | 0.5x3 | 0.6x3
    - 1 phút tập (0.5-5 phút)
    - 3 phút nghỉ (1-5)
    - Số sets: 2-4
    """
    num_sets = random.randint(2, 4)
    sets_list = []
    
    time_per_set = total_duration_min / (num_sets * 1.5)
    
    for _ in range(num_sets):
        work_time = round(random.uniform(0.5, min(5, time_per_set)), 1)
        rest_time = random.randint(1, 5)
        sets_list.append(f"{work_time}x{rest_time}")
    
    return ' | '.join(sets_list)

def calculate_suitability(age, gender, experience_level, intensity, workout_type, 
                         sets_reps_weight=None, bmi=None, mood=None, fatigue=None):
    """
    Tính điểm suitability_x dựa trên nhiều yếu tố
    """
    suitability_score = 1.0
    
    # Điều chỉnh theo tuổi
    if age < 18:
        if intensity in ['High', 'Maximal']:
            suitability_score -= 0.3
    elif age > 60:
        if intensity in ['High', 'Maximal']:
            suitability_score -= 0.4
        elif intensity == 'Medium':
            suitability_score -= 0.1
    elif age > 50:
        if intensity == 'Maximal':
            suitability_score -= 0.3
        elif intensity == 'High':
            suitability_score -= 0.1
    
    # Điều chỉnh theo giới tính và trọng lượng tạ
    if workout_type == 'Strength' and sets_reps_weight:
        weights = []
        for set_info in sets_reps_weight.split(' | '):
            parts = set_info.split('x')
            if len(parts) >= 2:
                try:
                    weights.append(int(parts[1]))
                except:
                    pass
        
        if weights:
            avg_weight = sum(weights) / len(weights)
            
            if gender.lower() == 'female':
                if avg_weight > 60:
                    suitability_score -= 0.4
                elif avg_weight > 40:
                    suitability_score -= 0.2
                elif avg_weight > 25:
                    suitability_score -= 0.1
            else:
                if avg_weight > 90:
                    suitability_score -= 0.2
                elif avg_weight > 70:
                    suitability_score -= 0.1
    
    # Điều chỉnh theo kinh nghiệm
    if experience_level == 'Beginner':
        if intensity in ['High', 'Maximal']:
            suitability_score -= 0.3
        elif intensity == 'Medium':
            suitability_score -= 0.05
        
        if workout_type == 'Strength' and sets_reps_weight:
            weights = []
            for set_info in sets_reps_weight.split(' | '):
                parts = set_info.split('x')
                if len(parts) >= 2:
                    try:
                        weights.append(int(parts[1]))
                    except:
                        pass
            if weights:
                avg_weight = sum(weights) / len(weights)
                if avg_weight > 50:
                    suitability_score -= 0.3
                elif avg_weight > 30:
                    suitability_score -= 0.15
    
    elif experience_level == 'Intermediate':
        if intensity == 'Maximal':
            suitability_score -= 0.1
    
    # Điều chỉnh theo BMI
    if bmi:
        if bmi > 30:
            if intensity in ['High', 'Maximal']:
                suitability_score -= 0.2
            if workout_type == 'HIIT':
                suitability_score -= 0.15
        elif bmi < 18.5:
            if intensity in ['High', 'Maximal']:
                suitability_score -= 0.15
    
    # Điều chỉnh theo tâm trạng
    if mood:
        if mood in ['Bad', 'Tired', 'Poor']:
            if intensity in ['High', 'Maximal']:
                suitability_score -= 0.2
            elif intensity == 'Medium':
                suitability_score -= 0.1
    
    # Điều chỉnh theo mức độ mệt mỏi
    if fatigue:
        if fatigue >= 8:
            if intensity in ['High', 'Maximal']:
                suitability_score -= 0.25
            elif intensity == 'Medium':
                suitability_score -= 0.1
        elif fatigue >= 6:
            if intensity == 'Maximal':
                suitability_score -= 0.15
    
    suitability_score = max(0.0, min(1.0, suitability_score))
    suitability_score += random.uniform(-0.05, 0.05)
    suitability_score = max(0.0, min(1.0, suitability_score))
    
    return round(suitability_score, 2)

def create_mapped_dataset():
    """Tạo dataset mới theo cấu trúc merged_omni_health_dataset.xlsx"""
    
    # Đọc dữ liệu gốc
    gym_data = pd.read_excel(r'd:\dacn_omnimer_health\3T-FIT\Data\data\gym_member_exercise_tracking.xlsx')
    
    # Đọc dữ liệu bài tập strength từ merged_omni_health_dataset
    strength_data = load_exercise_data()
    
    # Lấy danh sách các workout sessions (mỗi workout_id là một buổi tập hoàn chỉnh)
    workout_sessions = {}
    for workout_id in strength_data['workout_id'].unique():
        if pd.notna(workout_id):
            session_exercises = strength_data[strength_data['workout_id'] == workout_id]
            session_exercises = session_exercises[session_exercises['exercise_name'].notna()]
            if len(session_exercises) > 0:
                workout_sessions[workout_id] = session_exercises
    
    print(f"Đã tải {len(gym_data)} records từ gym_member_exercise_tracking.xlsx")
    print(f"Đã tải {len(workout_sessions)} workout sessions hoàn chỉnh")
    
    # Danh sách để lưu các records mới
    new_records = []
    record_id = 1
    
    # Dictionary để lưu suitability_x của từng user
    user_suitability_scores = {}
    
    # Xử lý từng record
    for idx, row in gym_data.iterrows():
        # Thông tin cơ bản
        age = row['Age']
        gender = row['Gender']
        weight_kg = row['Weight (kg)']
        height_m = row['Height (m)']
        max_bpm = row['Max_BPM']
        avg_bpm = row['Avg_BPM']
        resting_bpm = row['Resting_BPM']
        duration_hours = row['Session_Duration (hours)']
        duration_min = duration_hours * 60
        workout_type = row['Workout_Type']
        fat_percentage = row['Fat_Percentage']
        workout_frequency = row['Workout_Frequency (days/week)']
        experience_level = row['Experience_Level']
        bmi = row['BMI']
        
        # Tính toán các metrics
        hr_max = calculate_hr_max(age)
        intensity = get_intensity_level(workout_type, avg_bpm, hr_max, resting_bpm)
        mets = get_mets_value(workout_type, intensity)
        calculated_calories = calculate_calories_mets(mets, weight_kg, duration_min)
        whr = estimate_whr(gender, bmi, fat_percentage)
        
        # Tạo IDs
        user_profile_id = generate_user_profile_id(idx)
        workout_id = generate_workout_id(idx, workout_type)
        
        # Tạo ngày tháng
        birthday = datetime.now() - timedelta(days=age*365 + random.randint(0, 365))
        workout_date = datetime.now() - timedelta(days=random.randint(0, 30))
        checkup_date = workout_date - timedelta(days=random.randint(1, 7))
        
        # Nếu là Strength training, chọn một workout session hoàn chỉnh
        if workout_type == 'Strength' and len(workout_sessions) > 0:
            # Chọn ngẫu nhiên một workout session
            selected_workout_id = random.choice(list(workout_sessions.keys()))
            selected_session = workout_sessions[selected_workout_id]
            
            num_exercises = len(selected_session)
            
            for ex_idx, (_, exercise) in enumerate(selected_session.iterrows()):
                exercise_duration = duration_min / num_exercises
                exercise_calories = calculated_calories / num_exercises
                
                sets_format = generate_strength_sets_format()
                fatigue_val = random.randint(3, 7)
                mood_val = random.choice(['Good', 'Great', 'Normal'])
                
                suitability_x = calculate_suitability(
                    age=age,
                    gender=gender,
                    experience_level=map_experience_level(experience_level),
                    intensity=intensity,
                    workout_type=workout_type,
                    sets_reps_weight=sets_format,
                    bmi=bmi,
                    mood=mood_val,
                    fatigue=fatigue_val
                )
                
                user_id = f"U{idx + 1}"
                if user_id not in user_suitability_scores:
                    user_suitability_scores[user_id] = []
                user_suitability_scores[user_id].append(suitability_x)
                
                record = {
                    'id': record_id,
                    'user_health_profile_id': user_profile_id,
                    'workout_id': workout_id,
                    'done': 1,
                    'exercise_name': exercise['exercise_name'],
                    'equipment': exercise['equipment'] if pd.notna(exercise['equipment']) else 'None',
                    'target_muscle': exercise['target_muscle'] if pd.notna(exercise['target_muscle']) else 'Unknown',
                    'secondary_muscles': exercise['secondary_muscles'] if pd.notna(exercise['secondary_muscles']) else None,
                    'sets/reps/weight/timeresteachset': sets_format,
                    'sets/time_m/timeresteachset': None,
                    'distance_km': None,
                    'duration_min': round(exercise_duration, 2),
                    'intensity': intensity,
                    'avg_hr': avg_bpm,
                    'max_hr': max_bpm,
                    'calories': round(exercise_calories, 2),
                    'fatigue': fatigue_val,
                    'effort': random.randint(6, 9),
                    'mood': mood_val,
                    'recovery_h': random.randint(24, 48),
                    'effectiveness': random.choice(['Muscle Gain', 'Strength', 'Endurance']),
                    'suitability_x': suitability_x,
                    'unnamed:_22': None,
                    'unnamed:_23': None,
                    'unnamed:_24': None,
                    'user_id': user_id,
                    'age': age,
                    'height_m': height_m,
                    'weight_kg': weight_kg,
                    'whr': round(whr, 2),
                    'bmi': bmi,
                    'fat_percentage': fat_percentage,
                    'resting_heartrate': resting_bpm,
                    'experience_level': map_experience_level(experience_level),
                    'workout_frequency': workout_frequency,
                    'activity_level': map_activity_level(workout_frequency),
                    'health_status': 'Good',
                    'checkup_date': checkup_date.strftime('%Y-%m-%d'),
                    'bodypart_target': exercise['target_muscle'] if pd.notna(exercise['target_muscle']) else 'Unknown',
                    'workout_date': workout_date.strftime('%Y-%m-%d'),
                    'total_duration_min': duration_min,
                    'category_exercise_want_todo': 'Strength',
                    'category_type_want_todo': workout_type,
                    'location': random.choice(['Gym', 'Home']),
                    'suitability_y': 0.0,
                    'workout_goal_achieved': random.choice([0, 1]),
                    'target_muscle_felt': 1,
                    'injury_or_pain_notes': None,
                    'exercise_not_suitable': 0,
                    'gender': 1 if gender == 'Male' else 0,
                    'birthday': birthday.strftime('%Y-%m-%d')
                }
                
                new_records.append(record)
                record_id += 1
        
        else:
            # Đối với các loại workout khác (Cardio, Yoga, HIIT)
            fatigue_val = random.randint(3, 8)
            mood_val = random.choice(['Good', 'Great', 'Normal', 'Tired'])
            
            suitability_x = calculate_suitability(
                age=age,
                gender=gender,
                experience_level=map_experience_level(experience_level),
                intensity=intensity,
                workout_type=workout_type,
                sets_reps_weight=None,
                bmi=bmi,
                mood=mood_val,
                fatigue=fatigue_val
            )
            
            user_id = f"U{idx + 1}"
            if user_id not in user_suitability_scores:
                user_suitability_scores[user_id] = []
            user_suitability_scores[user_id].append(suitability_x)
            
            record = {
                'id': record_id,
                'user_health_profile_id': user_profile_id,
                'workout_id': workout_id,
                'done': 1,
                'exercise_name': workout_type,
                'equipment': {'Cardio': 'Treadmill', 'Yoga': 'Mat', 'HIIT': 'Bodyweight'}.get(workout_type, 'None'),
                'target_muscle': {'Cardio': 'Cardiovascular', 'Yoga': 'Full Body', 'HIIT': 'Full Body'}.get(workout_type, 'Full Body'),
                'secondary_muscles': None,
                'sets/reps/weight/timeresteachset': None,
                'sets/time_m/timeresteachset': generate_cardio_sets_format(duration_min) if workout_type in ['Cardio', 'Yoga'] else None,
                'distance_km': round(random.uniform(3, 10), 2) if workout_type == 'Cardio' else None,
                'duration_min': duration_min,
                'intensity': intensity,
                'avg_hr': avg_bpm,
                'max_hr': max_bpm,
                'calories': round(calculated_calories, 2),
                'fatigue': fatigue_val,
                'effort': random.randint(5, 9),
                'mood': mood_val,
                'recovery_h': random.randint(12, 36),
                'effectiveness': {'Cardio': 'Cardio Endurance', 'Yoga': 'Flexibility', 'HIIT': 'Fat Loss'}.get(workout_type, 'General Fitness'),
                'suitability_x': suitability_x,
                'unnamed:_22': None,
                'unnamed:_23': None,
                'unnamed:_24': None,
                'user_id': user_id,
                'age': age,
                'height_m': height_m,
                'weight_kg': weight_kg,
                'whr': round(whr, 2),
                'bmi': bmi,
                'fat_percentage': fat_percentage,
                'resting_heartrate': resting_bpm,
                'experience_level': map_experience_level(experience_level),
                'workout_frequency': workout_frequency,
                'activity_level': map_activity_level(workout_frequency),
                'health_status': 'Good',
                'checkup_date': checkup_date.strftime('%Y-%m-%d'),
                'bodypart_target': {'Cardio': 'Cardiovascular', 'Yoga': 'Full Body', 'HIIT': 'Full Body'}.get(workout_type, 'Full Body'),
                'workout_date': workout_date.strftime('%Y-%m-%d'),
                'total_duration_min': duration_min,
                'category_exercise_want_todo': workout_type,
                'category_type_want_todo': workout_type,
                'location': random.choice(['Gym', 'Home', 'Outdoor']),
                'suitability_y': 0.0,
                'workout_goal_achieved': random.choice([0, 1]),
                'target_muscle_felt': random.choice([0, 1]),
                'injury_or_pain_notes': None,
                'exercise_not_suitable': 0,
                'gender': 1 if gender == 'Male' else 0,
                'birthday': birthday.strftime('%Y-%m-%d')
            }
            
            new_records.append(record)
            record_id += 1
        
        if (idx + 1) % 100 == 0:
            print(f"Đã xử lý {idx + 1}/{len(gym_data)} records...")
    
    # Tạo DataFrame
    result_df = pd.DataFrame(new_records)
    
    # Cập nhật suitability_y
    print("\nĐang tính toán suitability_y...")
    for user_id, scores in user_suitability_scores.items():
        avg_suitability = round(sum(scores) / len(scores), 2)
        result_df.loc[result_df['user_id'] == user_id, 'suitability_y'] = avg_suitability
    
    print(f"\nĐã tạo {len(result_df)} records mới")
    
    return result_df

# ==================== MAIN ====================

def main():
    """Hàm chính"""
    print("=" * 60)
    print("BẮT ĐẦU TẠO DATASET MỚI")
    print("=" * 60)
    
    result_df = create_mapped_dataset()
    
    # Lưu file với timestamp
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    output_file = rf'd:\dacn_omnimer_health\3T-FIT\Data\data\mapped_workout_dataset_{timestamp}.xlsx'
    result_df.to_excel(output_file, index=False)
    
    print(f"\n✓ Đã lưu file: {output_file}")
    print(f"✓ Tổng số records: {len(result_df)}")
    print(f"✓ Tổng số cột: {len(result_df.columns)}")
    
    # Hiển thị thống kê
    print("\n" + "=" * 60)
    print("THỐNG KÊ DỮ LIỆU")
    print("=" * 60)
    print(f"Số lượng users: {result_df['user_id'].nunique()}")
    print(f"Số lượng workouts: {result_df['workout_id'].nunique()}")
    print(f"\nPhân bố theo loại workout:")
    print(result_df['category_type_want_todo'].value_counts())
    print(f"\nPhân bố theo cường độ:")
    print(result_df['intensity'].value_counts())
    print(f"\nThống kê suitability_x:")
    print(f"  - Trung bình: {result_df['suitability_x'].mean():.2f}")
    print(f"  - Min: {result_df['suitability_x'].min():.2f}")
    print(f"  - Max: {result_df['suitability_x'].max():.2f}")
    print(f"\nThống kê suitability_y:")
    print(f"  - Trung bình: {result_df['suitability_y'].mean():.2f}")
    print(f"  - Min: {result_df['suitability_y'].min():.2f}")
    print(f"  - Max: {result_df['suitability_y'].max():.2f}")
    
    print("\n" + "=" * 60)
    print("HOÀN THÀNH!")
    print("=" * 60)

if __name__ == "__main__":
    main()

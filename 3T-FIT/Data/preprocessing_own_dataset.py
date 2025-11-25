"""
Script để xử lý lại dữ liệu merged_omni_health_dataset.xlsx để tạo ra file gym_member_exercise_tracking.xlsx
Dữ liệu sẽ được loại bỏ các thông tin không cần thiết và được chuyển đổi thành dạng số liệu để dễ dàng xử lý và phân tích.

"""

import pandas as pd
import numpy as np
from pathlib import Path


def calculate_1rm(weight, reps):
    """
    Tính 1RM ước tính theo công thức Epley: 1RM = Weight * (1 + Reps/30)
    """
    if weight == 0: return 0
    return weight * (1 + reps / 30)


def extract_intensity(row):
    """
    Tính toán các chỉ số năng lực (Capability Metrics) dựa trên loại bài tập.
    Trả về Series gồm:
    - estimated_1rm: Sức mạnh tối đa (kg) cho bài Strength
    - pace: Tốc độ (km/h) cho bài Cardio
    - duration_capacity: Thời gian chịu đựng (phút/giây) cho bài Static
    - rest_period: Thời gian nghỉ (giây)
    - intensity_score: Điểm cường độ (1-4) cho các bài khác
    """
    result = {
        'estimated_1rm': 0.0,
        'pace': 0.0,
        'duration_capacity': 0.0,
        'rest_period': 0.0,
        'intensity_score': 0.0
    }

    # 1. Xử lý Strength: sets/reps/weight/timeresteachset
    # Format dự kiến: "Reps x Weight x Rest" (VD: 12x40x2)
    if pd.notna(row.get('sets/reps/weight/timeresteachset')):
        try:
            data = str(row['sets/reps/weight/timeresteachset'])
            sets = data.replace('|', ',').split(',')
            max_1rm = 0
            max_rest = 0
            has_valid_set = False
            
            for s in sets:
                parts = s.strip().lower().split('x')
                if len(parts) >= 2:
                    try:
                        reps = float(parts[0])
                        weight = float(parts[1])
                        
                        # Parse Rest if available (3rd component)
                        if len(parts) >= 3:
                            rest = float(parts[2])
                            if rest > max_rest: max_rest = rest

                        # Chỉ tính nếu weight > 0 (bài tập tạ)
                        if weight > 0:
                            rm = calculate_1rm(weight, reps)
                            if rm > max_1rm:
                                max_1rm = rm
                            has_valid_set = True
                    except ValueError:
                        continue
            
            if has_valid_set and max_1rm > 0:
                result['estimated_1rm'] = round(max_1rm, 2)
            
            if max_rest > 0:
                result['rest_period'] = round(max_rest, 2)
                
        except Exception:
            pass

    # 2. Xử lý Static/Endurance: sets/time_m/timeresteachset
    # Format: "Sets x Time(min/sec) x Rest" (VD: 3x60x30)
    if pd.notna(row.get('sets/time_m/timeresteachset')):
        try:
            data = str(row['sets/time_m/timeresteachset'])
            sets = data.replace('|', ',').split(',')
            max_duration = 0
            max_rest = 0
            
            for s in sets:
                parts = s.strip().lower().split('x')
                if len(parts) >= 2:
                    try:
                        val1 = float(parts[0])
                        val2 = float(parts[1])
                        
                        if len(parts) == 3:
                            # 3x60x30 -> Sets x Duration x Rest
                            duration = val2
                            rest = float(parts[2])
                        else:
                            # 60x30 -> Duration x Rest (per set entry)
                            duration = val1
                            rest = val2
                            
                        if duration > max_duration: max_duration = duration
                        if rest > max_rest: max_rest = rest
                        
                    except ValueError:
                        continue
            
            if max_duration > 0:
                result['duration_capacity'] = round(max_duration, 2)
            
            # Update rest if found here and greater than existing
            if max_rest > 0 and max_rest > result['rest_period']:
                result['rest_period'] = round(max_rest, 2)
                
        except Exception:
            pass

    # 3. Xử lý Cardio Distance: distance_km
    # Tính tốc độ km/h = distance_km / session_duration (giờ)
    if pd.notna(row.get('distance_km')) and row.get('distance_km') > 0:
        if pd.notna(row.get('session_duration')) and row.get('session_duration') > 0:
            speed = row['distance_km'] / row['session_duration']
            result['pace'] = round(speed, 2)

    # 4. Fallback: Intensity Score (1-4)
    if pd.notna(row.get('intensity')):
        result['intensity_score'] = round(row['intensity'], 2)
    
    return pd.Series(result)


def clean_dataset(df: pd.DataFrame) -> pd.DataFrame:
    """
    Làm sạch dữ liệu theo các yêu cầu sau:
    1. Loại bỏ các cột mà không có bất kì dữ liệu gì
    2. Xóa các cột không cần thiết (nhưng GIỮ LẠI SePA metrics: mood, fatigue, effort)
    3. Loại bỏ các dòng của cột done có giá trị = 0 và sau đó loại bỏ cột done
    4. Sắp xếp các cột user_health_profile_id, workout_id, user_id ở đầu
    5. Đổi tên cột total_duration_min thành session_duration và chuyển đổi từ phút sang giờ
    6. Biến đổi dữ liệu experience_level và intensity sang dạng số
    7. Tách các cột cường độ thành estimated_1rm, pace, duration, rest
    8. Đổi tên cột category_type_want_todo thành workout_type
    
    Args:
        df (pd.DataFrame): DataFrame cần làm sạch
        
    Returns:
        pd.DataFrame: DataFrame đã được làm sạch
    """
    # Tạo bản sao để không ảnh hưởng đến dữ liệu gốc
    df_cleaned = df.copy()
    
    print(f"Số lượng dòng ban đầu: {len(df_cleaned)}")
    print(f"Số lượng cột ban đầu: {len(df_cleaned.columns)}")
    print(f"Tên các cột ban đầu: {list(df_cleaned.columns)}\n")
    
    # Bước 1: Loại bỏ các cột mà không có bất kì dữ liệu gì
    empty_columns = []
    for col in df_cleaned.columns:
        if df_cleaned[col].isna().all() or (df_cleaned[col].astype(str).str.strip() == '').all():
            empty_columns.append(col)
    
    if empty_columns:
        print(f"Loại bỏ {len(empty_columns)} cột rỗng: {empty_columns}")
        df_cleaned = df_cleaned.drop(columns=empty_columns)
    else:
        print("Không có cột nào hoàn toàn rỗng")
    
    # Bước 2: Xóa các cột cụ thể
    # LƯU Ý: Giữ lại mood, fatigue, effort, injury_or_pain_notes cho SePA integration
    columns_to_drop = [
        'checkup_date', 'id', 'recovery_h', 'effectiveness', 
        'equipment', 'target_muscle', 'secondary_muscles', 'bodypart_target', 
        'workout_goal_achieved', 'target_muscle_felt', 'category_exercise_want_todo', 'birthday',
        'whr', 'workout_date', 'exercise_not_suitable', 'activity_level', 'suitability_y', 'user_health_profile_id', 'workout_id', 'user_id'
    ]
    existing_columns_to_drop = [col for col in columns_to_drop if col in df_cleaned.columns]
    
    if existing_columns_to_drop:
        print(f"\nXóa các cột: {existing_columns_to_drop}")
        df_cleaned = df_cleaned.drop(columns=existing_columns_to_drop)
    else:
        print(f"\nKhông tìm thấy các cột cần xóa trong danh sách: {columns_to_drop}")
    
    # Bước 3: Loại bỏ các dòng của cột done có giá trị = 0
    if 'done' in df_cleaned.columns:
        rows_before = len(df_cleaned)
        df_cleaned = df_cleaned[df_cleaned['done'] != 0]
        rows_removed = rows_before - len(df_cleaned)
        print(f"\nLoại bỏ {rows_removed} dòng có done = 0")
        df_cleaned = df_cleaned.drop(columns=['done'])
        print("Đã xóa cột 'done'")
    else:
        print("\nKhông tìm thấy cột 'done' trong dữ liệu")
    
    # Bước 4: Sắp xếp các cột ID ở đầu
    priority_columns = ['user_health_profile_id', 'workout_id', 'user_id']
    existing_priority_cols = [col for col in priority_columns if col in df_cleaned.columns]
    
    if existing_priority_cols:
        other_columns = [col for col in df_cleaned.columns if col not in existing_priority_cols]
        new_column_order = existing_priority_cols + other_columns
        df_cleaned = df_cleaned[new_column_order]
        print(f"\nSắp xếp lại thứ tự cột: {existing_priority_cols} được đặt ở đầu")
    else:
        print(f"\nKhông tìm thấy các cột ưu tiên: {priority_columns}")
    
    # Bước 5: Đổi tên cột total_duration_min thành session_duration và chuyển đổi từ phút sang giờ
    if 'total_duration_min' in df_cleaned.columns:
        df_cleaned['session_duration'] = (df_cleaned['total_duration_min'] / 60).round(2)
        df_cleaned = df_cleaned.drop(columns=['total_duration_min'])
        print(f"\nĐã đổi tên 'total_duration_min' thành 'session_duration' và chuyển đổi từ phút sang giờ")
    else:
        print("\nKhông tìm thấy cột 'total_duration_min' trong dữ liệu")

    # Bước 6: Biến đổi dữ liệu experience_level và intensity
    experience_map = {
        'beginner': 1,
        'intermediate': 2,
        'advanced': 3,
        'expert': 4
    }
    
    if 'experience_level' in df_cleaned.columns:
        df_cleaned['experience_level'] = df_cleaned['experience_level'].astype(str).str.lower().map(experience_map)
        print(f"\nĐã biến đổi cột 'experience_level' sang dạng số: {experience_map}")
    else:
        print("\nKhông tìm thấy cột 'experience_level'")

    intensity_map = {
        'low': 1,
        'medium': 2,
        'high': 3,
        'maximal': 4
    }
    
    if 'intensity' in df_cleaned.columns:
        df_cleaned['intensity'] = df_cleaned['intensity'].astype(str).str.lower().map(intensity_map)
        print(f"\nĐã biến đổi cột 'intensity' sang dạng số: {intensity_map}")
    else:
        print("\nKhông tìm thấy cột 'intensity'")

    # Bước 7: Tách các cột cường độ (Capability Metrics)
    print("\nBắt đầu tính toán các chỉ số năng lực (1RM, Pace, Duration, Rest)...")
    intensity_metrics = df_cleaned.apply(extract_intensity, axis=1)
    df_cleaned = pd.concat([df_cleaned, intensity_metrics], axis=1)
    
    # Xóa các cột cũ
    cols_to_remove = [
        'sets/reps/weight/timeresteachset', 
        'sets/time_m/timeresteachset', 
        'distance_km', 
        'intensity'
    ]
    existing_cols_to_remove = [col for col in cols_to_remove if col in df_cleaned.columns]
    
    if existing_cols_to_remove:
        df_cleaned = df_cleaned.drop(columns=existing_cols_to_remove)
        print(f"Đã xóa các cột cường độ cũ: {existing_cols_to_remove}")
    
    if 'estimated_1rm' in df_cleaned.columns:
        print(f"Ví dụ giá trị 1RM: {df_cleaned['estimated_1rm'].head().tolist()}")
    if 'pace' in df_cleaned.columns:
        print(f"Ví dụ giá trị Pace: {df_cleaned['pace'].head().tolist()}")
    if 'duration_capacity' in df_cleaned.columns:
        print(f"Ví dụ giá trị Duration: {df_cleaned['duration_capacity'].head().tolist()}")
    if 'rest_period' in df_cleaned.columns:
        print(f"Ví dụ giá trị Rest: {df_cleaned['rest_period'].head().tolist()}")
    
    # Bước 8: Đổi tên cột category_type_want_todo thành workout_type
    if 'category_type_want_todo' in df_cleaned.columns:
        df_cleaned = df_cleaned.rename(columns={'category_type_want_todo': 'workout_type'})
        print(f"\nĐã đổi tên cột 'category_type_want_todo' thành 'workout_type'")
    else:
        print("\nKhông tìm thấy cột 'category_type_want_todo'")
    
    print(f"\nSố lượng dòng sau khi làm sạch: {len(df_cleaned)}")
    print(f"Số lượng cột sau khi làm sạch: {len(df_cleaned.columns)}")
    print(f"Tên các cột còn lại: {list(df_cleaned.columns)}")
    
    return df_cleaned


def process_dataset(input_file: str, output_file: str = None) -> pd.DataFrame:
    """
    Đọc file dữ liệu, làm sạch và lưu kết quả
    """
    print(f"Đọc dữ liệu từ: {input_file}")
    df = pd.read_excel(input_file)
    
    print("\n" + "="*60)
    print("BẮT ĐẦU QUÁ TRÌNH LÀM SẠCH DỮ LIỆU")
    print("="*60 + "\n")
    
    df_cleaned = clean_dataset(df)
    
    if output_file is None:
        input_path = Path(input_file)
        output_file = input_path.parent / f"{input_path.stem}_cleaned{input_path.suffix}"
    
    print(f"\n" + "="*60)
    print(f"Lưu dữ liệu đã làm sạch vào: {output_file}")
    print("="*60)
    
    df_cleaned.to_excel(output_file, index=False)
    
    return df_cleaned


if __name__ == "__main__":
    input_file = "./data/merged_omni_health_dataset.xlsx"
    output_file = "./preprocessing_data/own_gym_member_exercise_tracking.xlsx"
    
    if Path(input_file).exists():
        df_cleaned = process_dataset(input_file, output_file)
        print("\n✅ Hoàn thành quá trình làm sạch dữ liệu!")
    else:
        print(f"❌ Không tìm thấy file: {input_file}")
        print("Vui lòng cập nhật đường dẫn file trong script hoặc đặt file vào thư mục hiện tại.")
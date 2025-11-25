"""
Script để xử lý dữ liệu test dataset với chuẩn hóa SePA và tính toán 1RM
- Chuẩn hóa các cột SePA (mood, fatigue, effort) về thang điểm 1-5
- Tính toán estimated_1rm sử dụng công thức Epley
- Áp dụng các xử lý tương tự như preprocessing_own_dataset.py

Author: Claude Code Assistant
Date: 2025-11-25
"""

import pandas as pd
import numpy as np
from pathlib import Path

# ==================== SEPA MAPPING FUNCTIONS ====================

# Mapping cho các giá trị SePA từ text sang số (1-5)
MOOD_MAPPING = {
    'Very Bad': 1,
    'Bad': 2,
    'Neutral': 3,
    'Good': 4,
    'Very Good': 5,
    'Excellent': 5,
    # Các giá trị có thể có khác
    'Rất tệ': 1,
    'Tệ': 2,
    'Bình thường': 3,
    'Tốt': 4,
    'Rất tốt': 5,
    'Tuyệt vời': 5
}

FATIGUE_MAPPING = {
    'Very Low': 1,
    'Low': 2,
    'Medium': 3,
    'High': 4,
    'Very High': 5,
    # Các giá trị có thể có khác
    'Rất thấp': 1,
    'Thấp': 2,
    'Trung bình': 3,
    'Cao': 4,
    'Rất cao': 5
}

EFFORT_MAPPING = {
    'Very Low': 1,
    'Low': 2,
    'Medium': 3,
    'High': 4,
    'Very High': 5,
    # Các giá trị có thể có khác
    'Rất thấp': 1,
    'Thấp': 2,
    'Trung bình': 3,
    'Cao': 4,
    'Rất cao': 5
}

def map_sepa_to_numeric(value, mapping_dict, default_value=3):
    """
    Chuyển đổi giá trị SePA từ text sang số (1-5)

    Args:
        value: Giá trị cần chuyển đổi (có thể là text, số, hoặc NaN)
        mapping_dict: Dictionary mapping tương ứng
        default_value: Giá trị mặc định nếu không thể mapping (3 = Neutral/Medium)

    Returns:
        int: Giá trị số từ 1-5
    """
    if pd.isna(value):
        return default_value

    # Nếu đã là số, kiểm tra và trả về
    try:
        num_val = int(float(value))
        if 1 <= num_val <= 5:
            return num_val
    except (ValueError, TypeError):
        pass

    # Nếu là string, thử mapping
    if isinstance(value, str):
        value_str = value.strip()

        # Thử direct mapping
        if value_str in mapping_dict:
            return mapping_dict[value_str]

        # Thử case-insensitive matching
        for key, val in mapping_dict.items():
            if key.lower() == value_str.lower():
                return val

        # Thử mapping theo từ khóa
        value_lower = value_str.lower()
        for key, val in mapping_dict.items():
            if key.lower() in value_lower or value_lower in key.lower():
                return val

    return default_value

def standardize_sepa_columns(df):
    """
    Chuẩn hóa các cột SePA về thang điểm 1-5

    Args:
        df: DataFrame chứa các cột SePA

    Returns:
        DataFrame với các cột SePA đã được chuẩn hóa
    """
    sepa_columns = ['mood', 'fatigue', 'effort']

    for col in sepa_columns:
        if col in df.columns:
            print(f"\nChuẩn hóa cột {col}...")

            # Hiển thị thông tin về cột trước khi chuẩn hóa
            unique_values = df[col].dropna().unique()
            print(f"  - Giá trị duy nhất trước chuẩn hóa: {list(unique_values[:10])}{'...' if len(unique_values) > 10 else ''}")

            # Chọn mapping dictionary tương ứng
            if col == 'mood':
                mapping_dict = MOOD_MAPPING
            elif col == 'fatigue':
                mapping_dict = FATIGUE_MAPPING
            elif col == 'effort':
                mapping_dict = EFFORT_MAPPING
            else:
                continue

            # Áp dụng mapping
            original_col = df[col].copy()
            df[col] = df[col].apply(lambda x: map_sepa_to_numeric(x, mapping_dict))

            # Thống kê kết quả
            changed_count = (original_col != df[col]).sum()
            print(f"  - Đã chuẩn hóa {changed_count} giá trị")
            print(f"  - Phân phối sau chuẩn hóa: {df[col].value_counts().sort_index().to_dict()}")
        else:
            print(f"\nKhông tìm thấy cột {col}")

    return df

# ==================== 1RM CALCULATION ====================

def calculate_1rm(weight, reps):
    """
    Tính 1RM ước tính theo công thức Epley: 1RM = Weight * (1 + Reps/30)

    Args:
        weight: Cân nặng (kg)
        reps: Số lần lặp

    Returns:
        float: 1RM ước tính
    """
    if weight == 0 or reps == 0:
        return 0.0
    return weight * (1 + reps / 30)

def extract_intensity_with_1rm(row):
    """
    Tính toán các chỉ số năng lực bao gồm cả 1RM

    Args:
        row: Dòng dữ liệu workout

    Returns:
        Series với các metrics: estimated_1rm, pace, duration_capacity, rest_period, intensity_score
    """
    result = {
        'estimated_1rm': 0.0,
        'pace': 0.0,
        'duration_capacity': 0.0,
        'rest_period': 0.0,
        'intensity_score': 0.0
    }

    # 1. Xử lý Strength: sets/reps/weight/timeresteachset
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

                        # Parse Rest nếu có (thành phần thứ 3)
                        if len(parts) >= 3:
                            rest = float(parts[2])
                            if rest > max_rest:
                                max_rest = rest

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
                            # 60x30 -> Duration x Rest
                            duration = val1
                            rest = val2

                        if duration > max_duration:
                            max_duration = duration
                        if rest > max_rest:
                            max_rest = rest

                    except ValueError:
                        continue

            if max_duration > 0:
                result['duration_capacity'] = round(max_duration, 2)

            # Update rest nếu lớn hơn giá trị hiện tại
            if max_rest > 0 and max_rest > result['rest_period']:
                result['rest_period'] = round(max_rest, 2)

        except Exception:
            pass

    # 3. Xử lý Cardio Distance
    if pd.notna(row.get('distance_km')) and row.get('distance_km') > 0:
        if pd.notna(row.get('session_duration')) and row.get('session_duration') > 0:
            speed = row['distance_km'] / row['session_duration']
            result['pace'] = round(speed, 2)

    # 4. Fallback: Intensity Score
    if pd.notna(row.get('intensity')):
        result['intensity_score'] = round(row['intensity'], 2)

    return pd.Series(result)

# ==================== MAIN PROCESSING FUNCTION ====================

def clean_test_dataset(df: pd.DataFrame) -> pd.DataFrame:
    """
    Làm sạch dữ liệu test với SePA standardization và 1RM calculation

    Args:
        df: DataFrame cần xử lý

    Returns:
        DataFrame đã được làm sạch và chuẩn hóa
    """
    print(f"Số lượng dòng ban đầu: {len(df)}")
    print(f"Số lượng cột ban đầu: {len(df.columns)}")
    print(f"Tên các cột ban đầu: {list(df.columns)}\n")

    # Tạo bản sao để không ảnh hưởng dữ liệu gốc
    df_cleaned = df.copy()

    # Bước 1: Loại bỏ các cột rỗng
    empty_columns = []
    for col in df_cleaned.columns:
        if df_cleaned[col].isna().all() or (df_cleaned[col].astype(str).str.strip() == '').all():
            empty_columns.append(col)

    if empty_columns:
        print(f"Loại bỏ {len(empty_columns)} cột rỗng: {empty_columns}")
        df_cleaned = df_cleaned.drop(columns=empty_columns)

    # Bước 2: Chuẩn hóa các cột SePA
    print("\n" + "="*50)
    print("CHUẨN HÓA CÁC CỘT SEPA (1-5 SCALE)")
    print("="*50)
    df_cleaned = standardize_sepa_columns(df_cleaned)

    # Bước 3: Xóa các cột không cần thiết (nhưng GIỮ các cột SePA)
    columns_to_drop = [
        'checkup_date', 'id', 'recovery_h', 'effectiveness',
        'equipment', 'target_muscle', 'secondary_muscles', 'bodypart_target',
        'workout_goal_achieved', 'target_muscle_felt', 'category_exercise_want_todo', 'birthday',
        'whr', 'workout_date', 'exercise_not_suitable', 'activity_level', 'suitability_y', 
        'user_health_profile_id', 'workout_id', 'user_id'
    ]

    existing_columns_to_drop = [col for col in columns_to_drop if col in df_cleaned.columns]

    if existing_columns_to_drop:
        print(f"\nXóa các cột: {existing_columns_to_drop}")
        df_cleaned = df_cleaned.drop(columns=existing_columns_to_drop)

    # Bước 4: Loại bỏ các dòng có done = 0
    if 'done' in df_cleaned.columns:
        rows_before = len(df_cleaned)
        df_cleaned = df_cleaned[df_cleaned['done'] != 0]
        rows_removed = rows_before - len(df_cleaned)
        print(f"\nLoại bỏ {rows_removed} dòng có done = 0")
        df_cleaned = df_cleaned.drop(columns=['done'])

    # Bước 5: Đổi tên và chuyển đổi total_duration_min
    if 'total_duration_min' in df_cleaned.columns:
        df_cleaned['session_duration'] = (df_cleaned['total_duration_min'] / 60).round(2)
        df_cleaned = df_cleaned.drop(columns=['total_duration_min'])
        print("\nĐã đổi tên 'total_duration_min' thành 'session_duration' (giờ)")

    # Bước 6: Biến đổi experience_level và intensity
    experience_map = {
        'beginner': 1,
        'intermediate': 2,
        'advanced': 3,
        'expert': 4
    }

    if 'experience_level' in df_cleaned.columns:
        df_cleaned['experience_level'] = df_cleaned['experience_level'].astype(str).str.lower().map(experience_map)
        print(f"\nĐã biến đổi cột 'experience_level' sang dạng số")

    intensity_map = {
        'low': 1,
        'medium': 2,
        'high': 3,
        'maximal': 4
    }

    if 'intensity' in df_cleaned.columns:
        df_cleaned['intensity'] = df_cleaned['intensity'].astype(str).str.lower().map(intensity_map)
        print(f"Đã biến đổi cột 'intensity' sang dạng số")

    # Bước 7: Tính toán các chỉ số năng lực (bao gồm 1RM)
    print("\n" + "="*50)
    print("TÍNH TOÁN CÁC CHỈ SỐ NĂNG LỰC (1RM, PACE, DURATION)")
    print("="*50)

    intensity_metrics = df_cleaned.apply(extract_intensity_with_1rm, axis=1)
    df_cleaned = pd.concat([df_cleaned, intensity_metrics], axis=1)

    # Xóa các cột cũ không cần thiết
    cols_to_remove = [
        'sets/reps/weight/timeresteachset',
        'sets/time_m/timeresteachset',
        'distance_km',
        'intensity'
    ]
    existing_cols_to_remove = [col for col in cols_to_remove if col in df_cleaned.columns]

    if existing_cols_to_remove:
        df_cleaned = df_cleaned.drop(columns=existing_cols_to_remove)
        print(f"Đã xóa các cột cũ: {existing_cols_to_remove}")

    # Bước 8: Đổi tên category_type_want_todo thành workout_type
    if 'category_type_want_todo' in df_cleaned.columns:
        df_cleaned = df_cleaned.rename(columns={'category_type_want_todo': 'workout_type'})
        print("\nĐã đổi tên 'category_type_want_todo' thành 'workout_type'")

    # Hiển thị thông tin về 1RM
    if 'estimated_1rm' in df_cleaned.columns:
        non_zero_1rm = df_cleaned[df_cleaned['estimated_1rm'] > 0]
        print(f"\nThông tin 1RM:")
        print(f"  - Số bài tập có 1RM > 0: {len(non_zero_1rm)}/{len(df_cleaned)}")
        if len(non_zero_1rm) > 0:
            print(f"  - 1RM min: {non_zero_1rm['estimated_1rm'].min():.2f} kg")
            print(f"  - 1RM max: {non_zero_1rm['estimated_1rm'].max():.2f} kg")
            print(f"  - 1RM mean: {non_zero_1rm['estimated_1rm'].mean():.2f} kg")
            print(f"  - Sample 1RM values: {non_zero_1rm['estimated_1rm'].head().tolist()}")

    # Hiển thị thống kê SePA cuối cùng
    print(f"\nThống kê SePA cuối cùng:")
    for col in ['mood', 'fatigue', 'effort']:
        if col in df_cleaned.columns:
            stats = df_cleaned[col].value_counts().sort_index()
            print(f"  - {col}: {stats.to_dict()}")

    print(f"\nKết quả xử lý:")
    print(f"  - Số dòng cuối cùng: {len(df_cleaned)}")
    print(f"  - Số cột cuối cùng: {len(df_cleaned.columns)}")
    print(f"  - Các cột: {list(df_cleaned.columns)}")

    return df_cleaned


def process_test_dataset(input_file: str, output_file: str = None) -> pd.DataFrame:
    """
    Xử lý dataset test với SePA standardization và 1RM calculation

    Args:
        input_file: Đường dẫn file input
        output_file: Đường dẫn file output (tự động tạo nếu không cung cấp)

    Returns:
        DataFrame đã được xử lý
    """
    print(f"Đọc dữ liệu test từ: {input_file}")
    df = pd.read_excel(input_file)

    print("\n" + "="*60)
    print("XỬ LÝ TEST DATASET VỚI SEPA STANDARDIZATION & 1RM")
    print("="*60 + "\n")

    df_processed = clean_test_dataset(df)

    if output_file is None:
        input_path = Path(input_file)
        output_file = input_path.parent / f"{input_path.stem}_processed{input_path.suffix}"

    print(f"\n" + "="*60)
    print(f"Lưu dữ liệu đã xử lý vào: {output_file}")
    print("="*60)

    df_processed.to_excel(output_file, index=False)

    # Lưu báo cáo xử lý
    report_file = str(output_file).replace('.xlsx', '_processing_report.json')
    processing_report = {
        'input_file': input_file,
        'output_file': str(output_file),
        'processing_date': '2025-11-25',
        'records': {
            'input_count': len(df),
            'output_count': len(df_processed),
            'removed_count': len(df) - len(df_processed)
        },
        'sepa_standardization': {
            'mood_mapping': MOOD_MAPPING,
            'fatigue_mapping': FATIGUE_MAPPING,
            'effort_mapping': EFFORT_MAPPING
        },
        'columns': {
            'input_columns': list(df.columns),
            'output_columns': list(df_processed.columns)
        },
        'statistics': {
            'workout_types': df_processed['workout_type'].value_counts().to_dict() if 'workout_type' in df_processed.columns else {},
            'estimated_1rm_stats': {
                'mean': float(df_processed['estimated_1rm'].mean()) if 'estimated_1rm' in df_processed.columns else 0,
                'max': float(df_processed['estimated_1rm'].max()) if 'estimated_1rm' in df_processed.columns else 0,
                'non_zero_count': int(len(df_processed[df_processed['estimated_1rm'] > 0])) if 'estimated_1rm' in df_processed.columns else 0
            }
        }
    }

    import json
    with open(report_file, 'w', encoding='utf-8') as f:
        json.dump(processing_report, f, indent=2, ensure_ascii=False)

    print(f"Báo cáo xử lý đã được lưu vào: {report_file}")

    return df_processed


if __name__ == "__main__":
    # Cấu đường dẫn file
    input_file = "./data/merged_omni_health_dataset.xlsx"  # Thay đổi đường dẫn này nếu cần
    output_file = "./preprocessing_data/test_dataset.xlsx"

    # Kiểm tra file input
    if Path(input_file).exists():
        df_processed = process_test_dataset(input_file, output_file)
        print("\n✅ Hoàn thành xử lý test dataset!")
        print(f"📊 Dataset đã xử lý: {len(df_processed)} records")
    else:
        print(f"❌ Không tìm thấy file: {input_file}")
        print("Vui lòng cập nhật đường dẫn file trong script")
        print("Hoặc đặt file test dataset vào thư mục data/")

        # Hiển thị các file có sẵn trong thư mục data
        data_dir = Path("./data")
        if data_dir.exists():
            print(f"\nCác file có sẵn trong thư mục {data_dir}:")
            for file in data_dir.glob("*.xlsx"):
                print(f"  - {file.name}")
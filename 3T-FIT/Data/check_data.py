import os
import pandas as pd
import re
from typing import List, Set, Tuple
from fuzzywuzzy import fuzz # Cần cài đặt: pip install fuzzywuzzy python-levenshtein

# --- CẤU HÌNH ---
# Tên thư mục chứa các file JSON của bài tập
EXERCISES_DIR = '../../exercises'
# Đường dẫn đến file chứa dữ liệu Workout Tracker (thay đổi nếu cần)
WORKOUT_DATA_FILE = './data/WorkoutTrackerDataset.xlsx'
# Tên sheet chứa cột Exercise_Name (thay đổi nếu cần)
SHEET_NAME = 'Workout Tracker Dataset' 
# Tên cột chứa tên bài tập trong file data
EXERCISE_NAME_COLUMN = 'Exercise_Name'

# NGƯỠNG TƯƠNG ĐỒNG (80%)
SIMILARITY_THRESHOLD = 80 
# --- KẾT THÚC CẤU HÌNH ---

def standardize_name(name: str) -> str:
    """
    Chuẩn hóa tên bài tập để so sánh cơ bản trước khi áp dụng fuzzy matching.
    
    Tương tự như trước: loại bỏ chữ hoa, dấu gạch dưới, khoảng trắng.
    """
    # 1. Chuyển tất cả thành chữ thường
    standardized = name.lower()
    # 2. Loại bỏ dấu gạch dưới, khoảng trắng và các ký tự không phải chữ/số khác
    standardized = re.sub(r'[\s_-]+', '', standardized)
    return standardized

def get_json_filenames(directory: str) -> Set[Tuple[str, str]]:
    """
    Lấy tên file gốc VÀ tên đã chuẩn hóa của các file JSON trong thư mục.
    
    Trả về một Set chứa các tuple (tên_file_gốc, tên_chuẩn_hóa).
    """
    json_names = set()
    try:
        # Kiểm tra sự tồn tại của thư mục trước khi listdir
        if not os.path.isdir(directory):
             raise FileNotFoundError
             
        for filename in os.listdir(directory):
            # Chỉ xử lý các file kết thúc bằng .json
            if filename.endswith('.json'):
                # Loại bỏ phần mở rộng .json
                base_name = filename[:-5]
                # Chuẩn hóa tên 
                standardized = standardize_name(base_name)
                # Lưu cả tên file gốc (.json) và tên đã chuẩn hóa
                json_names.add((filename, standardized))
                
    except FileNotFoundError:
        print(f"LỖI: Thư mục '{directory}' không được tìm thấy. Vui lòng kiểm tra lại đường dẫn.")
    return json_names

def get_exercise_names_from_data(file_path: str, sheet: str, column: str) -> Set[str]:
    """
    Đọc và chuẩn hóa tên các bài tập từ file Workout Tracker Data.
    """
    exercise_names = set()
    try:
        if file_path.endswith('.xlsx'):
            # Sử dụng engine 'openpyxl' cho các file .xlsx
            df = pd.read_excel(file_path, sheet_name=sheet, engine='openpyxl')
        elif file_path.endswith('.csv'):
             df = pd.read_csv(file_path)
        else:
            print("LỖI: Định dạng file không được hỗ trợ. Vui lòng dùng .xlsx hoặc .csv.")
            return exercise_names

        # Lấy cột tên bài tập, loại bỏ các giá trị rỗng và chuẩn hóa
        if column in df.columns:
            # Lấy tất cả các tên bài tập, loại bỏ NaN và chuẩn hóa
            # KHÔNG loại bỏ trùng lặp ở đây để có thể báo cáo trùng lặp sau này nếu cần
            # Nhưng để so sánh mờ, ta chỉ cần các tên đã chuẩn hóa duy nhất.
            unique_names = df[column].dropna().astype(str).unique()
            exercise_names = {standardize_name(name) for name in unique_names}
        else:
            print(f"LỖI: Cột '{column}' không được tìm thấy trong sheet '{sheet}'.")
            
    except FileNotFoundError:
        print(f"LỖI: File data '{file_path}' không được tìm thấy. Vui lòng kiểm tra lại đường dẫn.")
    except ValueError as e:
         print(f"LỖI: Không tìm thấy sheet '{sheet}'. Chi tiết: {e}")
    return exercise_names

def find_matching_files_fuzzy(json_file_data: Set[Tuple[str, str]], data_names_set: Set[str], threshold: int) -> List[Tuple[str, str, int]]:
    """
    Tìm tên file JSON có tên chuẩn hóa trùng với tên bài tập đã chuẩn hóa
    với độ tương đồng (fuzziness) trên một ngưỡng nhất định.
    
    Trả về List of Tuples: (tên_file_json_gốc, tên_bài_tập_từ_data_chuẩn_hóa, điểm_tương_đồng)
    """
    matching_results = []
    
    # Chuyển tên data sang list để dễ dàng lặp và so sánh 
    data_list = list(data_names_set)

    # Lặp qua từng file JSON và tên đã chuẩn hóa của nó
    for json_filename_orig, json_name_standardized in json_file_data:
        
        # So sánh tên JSON đã chuẩn hóa với TẤT CẢ tên data đã chuẩn hóa
        for data_name_standardized in data_list:
            
            # Sử dụng fuzz.ratio để tính toán độ tương đồng (0-100)
            # fuzz.ratio là phương pháp đơn giản nhất, thường hoạt động tốt 
            # cho các chuỗi ngắn và hơi khác biệt.
            score = fuzz.ratio(json_name_standardized, data_name_standardized)
            
            if score >= threshold:
                # Tìm thấy sự trùng khớp mờ (fuzzy match)
                matching_results.append((
                    json_filename_orig, 
                    data_name_standardized, 
                    score
                ))
                # Thoát khỏi vòng lặp data_list để tránh một file JSON match với nhiều tên data khác nhau
                # nếu bạn chỉ muốn tìm một match tốt nhất cho mỗi file JSON.
                break 
                
    return matching_results

# --- CHẠY CHƯƠNG TRÌNH CHÍNH ---
if __name__ == '__main__':
    print(f"--- BẮT ĐẦU SO SÁNH DỮ LIỆU BÀI TẬP (Ngưỡng: {SIMILARITY_THRESHOLD}%) ---")

    # 1. Lấy danh sách tên file JSON gốc và đã chuẩn hóa
    json_file_data = get_json_filenames(EXERCISES_DIR)
    print(f"✅ Đã tìm thấy {len(json_file_data)} tên bài tập JSON.")
    
    print("-" * 40)

    # 2. Lấy danh sách tên bài tập từ Workout Data đã chuẩn hóa
    workout_standardized_names = get_exercise_names_from_data(
        WORKOUT_DATA_FILE, SHEET_NAME, EXERCISE_NAME_COLUMN
    )
    print(f"✅ Đã tìm thấy {len(workout_standardized_names)} tên bài tập duy nhất từ Workout Data đã chuẩn hóa.")
    
    print("-" * 40)

    # 3. Tìm các file JSON có tên trùng khớp mờ
    matching_results = find_matching_files_fuzzy(
        json_file_data, 
        workout_standardized_names,
        SIMILARITY_THRESHOLD
    )

    if matching_results:
        print(f"🎉 ĐÃ TÌM THẤY {len(matching_results)} KẾT NỐI TRÙNG KHỚP MỜ (FUZZY MATCH):")
        print("\n| File JSON Gốc | Tên Data Chuẩn Hóa | Điểm Tương Đồng |")
        print("|:--- |:--- |:--- |")
        
        # Sắp xếp theo điểm tương đồng giảm dần
        sorted_results = sorted(matching_results, key=lambda x: x[2], reverse=True)
        
        for json_file, data_name, score in sorted_results:
            print(f"| **{json_file}** | {data_name} | **{score}%** |")
    else:
        print("❌ KHÔNG TÌM THẤY BẤT KỲ FILE JSON NÀO TRÙNG KHỚP MỜ VỚI DỮ LIỆU WORKOUT.")

    print("--- KẾT THÚC SO SÁNH ---")
import pandas as pd

"""
Script để merge dữ liệu từ WorkoutTrackerDataset.xlsx sang merged_omni_health_dataset.xlsx
Mục đích để tổng hợp dữ liệu các sheet về cùng 1 sheet để dễ phân tích

"""

# ========== 1️⃣ Đọc dữ liệu từ 4 sheet ==========
file_path = "./data/WorkoutTrackerDataset.xlsx"

user_df = pd.read_excel(file_path, sheet_name="User")
health_df = pd.read_excel(file_path, sheet_name="User Health Profile")
session_df = pd.read_excel(file_path, sheet_name="Workout Tracker Dataset")
response_df = pd.read_excel(file_path, sheet_name="Workout Detail")

# ========== 2️⃣ Ghép Workout Tracker Data ↔ User Health Profile ==========
merged_workout_health = pd.merge(
    session_df,
    health_df,
    on="User_Health_Profile_ID",
    how="left"
)

# ========== 3️⃣ Ghép với Workout Detail ==========
merged_workout_detail = pd.merge(
    merged_workout_health,
    response_df,
    on="Workout_ID",
    how="left"
)

# ========== 4️⃣ Ghép thêm User ==========
final_df = pd.merge(
    merged_workout_detail,
    user_df,
    on="User_ID",
    how="left"
)

# ========== 5️⃣ Xử lý cột (Tên cột) ==========
# Xóa cột trùng
final_df = final_df.loc[:, ~final_df.columns.duplicated()]

# Chuyển toàn bộ tên cột về lowercase + thay dấu cách/thừa
final_df.columns = (
    final_df.columns
    .str.strip()       # xóa khoảng trắng đầu/cuối
    .str.lower()       # chuyển thường
    .str.replace(" ", "_")   # thay khoảng trắng bằng _
)

# ========== 6️⃣ Xử lý dữ liệu (Giá trị trong cột) ==========
# 👉 YÊU CẦU CỦA BẠN: Chỉnh lại tên bài tập thành In Hoa Chữ Cái Đầu
if 'exercise_name' in final_df.columns:
    # Chuyển sang dạng chuỗi (đề phòng dữ liệu không phải string) rồi dùng .title()
    final_df['exercise_name'] = final_df['exercise_name'].astype(str).str.title()

# ========== 7️⃣ Xuất file Excel ==========
output_path = "./data/merged_omni_health_dataset.xlsx"
final_df.to_excel(output_path, index=False)

print(f"✅ Đã ghép, chuẩn hóa tên cột và chỉnh sửa exercise_name, lưu tại: {output_path}")
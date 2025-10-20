import pandas as pd
from difflib import get_close_matches
import re

# ==== 1. Đọc dữ liệu ====
file1 = "./Exercise/Danh sách bài tập 2.xlsx"
file2 = "./Exercise/Danh sách bài tập chi tiết.xlsx"

df1 = pd.read_excel(file1)  # chứa Title
df2 = pd.read_excel(file2)  # chứa name, Target, Secondary Muscles

# ==== 2. Hàm chuẩn hóa (normalize) ====
def normalize(text):
    if pd.isna(text):
        return ""
    text = str(text).lower()
    text = re.sub(r'[^a-z\s]', '', text)  # bỏ ký tự đặc biệt, số
    text = re.sub(r'\s+', ' ', text)      # bỏ khoảng trắng thừa
    return text.strip()

df1["Title_norm"] = df1["Title"].apply(normalize)
df2["name_norm"] = df2["name"].apply(normalize)

# ==== 3. Fuzzy matching ====
mapping = {}
for title in df1["Title_norm"].dropna().unique():
    matches = get_close_matches(
        title,
        df2["name_norm"].dropna().unique(),
        n=1,
        cutoff=0.65   # ngưỡng, có thể tăng lên 0.75 để khớp chặt hơn
    )
    if matches:
        mapping[title] = matches[0]

# ==== 4. Chuẩn bị dữ liệu file2 ====
# Lấy tất cả các cột tên có chứa "secondaryMuscles/"
secondary_cols = [col for col in df2.columns if col.startswith("secondaryMuscles/")]
cols_to_keep = ["name_norm", "target"] + secondary_cols
df2_subset = df2[cols_to_keep]

# ==== 5. Map kết quả vào df1 ====
df1["Matched_Name_norm"] = df1["Title_norm"].map(mapping)

merged_df = pd.merge(
    df1,
    df2_subset,
    how="left",
    left_on="Matched_Name_norm",
    right_on="name_norm"
)

# ==== 6. Tách matched / unmatched ====
matched = merged_df[merged_df["target"].notna()]
unmatched = merged_df[merged_df["target"].isna()]

# ==== 7. Xuất file ====
merged_df.to_excel("merged_workout_dataset.xlsx", index=False)
unmatched.to_excel("unmatched_workout_dataset.xlsx", index=False)

print("✅ Merge xong!")
print("Matched:", len(matched))
print("Unmatched:", len(unmatched))

# 🎯 Exercise Recommendation Model - Testing Guide

Hướng dẫn test và sử dụng Exercise Recommendation Model

## 📋 Tổng quan

Model này nhận vào:

- **Health Profile**: Thông tin sức khỏe của người dùng
- **Exercise List**: Danh sách bài tập để model chọn lọc

Model trả về:

- **Top K Exercises**: Bài tập phù hợp nhất
- **Suitability Score**: Điểm phù hợp (0-1)
- **Intensity Parameters**: Sets, reps, weight, HR, etc.

## 🚀 Cách 1: Test nhanh với Demo Script

### Chạy demo với 4 test cases có sẵn:

```bash
cd ai_server/artifacts_unified/src
python test_inference_demo.py
```

**Output:**

```
═══════════════════════════════════════════════════════════════════════════════
🎯 EXERCISE RECOMMENDATION MODEL - DEMO TEST
═══════════════════════════════════════════════════════════════════════════════

📦 Loading model from: ../artifacts_exercise_rec
✓ Loaded model from: ../artifacts_exercise_rec
  - 66 exercises
  - Input dim: 18
  - Device: cpu

═══════════════════════════════════════════════════════════════════════════════
TEST CASE 1: NGƯỜI MỚI BẮT ĐẦU (BEGINNER)
═══════════════════════════════════════════════════════════════════════════════

👤 Health Profile:
   Age: 22, Gender: Male
   Height: 1.7m, Weight: 65kg
   BMI: 22.5, Body Fat: 18.0%
   Experience: Beginner, Activity: Low
   Workout Frequency: 2 times/week

✨ TOP 5 RECOMMENDATIONS:
────────────────────────────────────────────────────────────────────────────────

1. Push Up
   ──────────────────────────────────────────────────────────────────────
   📊 Suitability Score: 0.523
   💪 Sets: 3
   🔁 Reps: 12
   ⚖️  Weight: 0.0 kg
   ⏱️  Rest: 1.5 min
   ❤️  Heart Rate: 120 avg / 145 peak
...
```

### Test Cases bao gồm:

1. **Beginner** - Người mới bắt đầu
2. **Advanced** - Người có kinh nghiệm
3. **Weight Loss** - Nữ giới muốn giảm cân
4. **Muscle Building** - Người muốn tăng cơ

Kết quả được lưu vào: `test_results.json`

## 🔧 Cách 2: Test với Input JSON tùy chỉnh

### Bước 1: Tạo file input

Tạo file `my_input.json`:

```json
{
  "healthProfile": {
    "age": 25,
    "height_m": 1.75,
    "weight_kg": 70,
    "bmi": 22.86,
    "fat_percentage": 15.5,
    "resting_heartrate": 65,
    "workout_frequency": 4,
    "gender": "Male",
    "experience_level": "Intermediate",
    "activity_level": "Moderate"
  },
  "exercises": [
    { "exerciseName": "Barbell Bench Press (Wide Grip)" },
    { "exerciseName": "Squat" },
    { "exerciseName": "Pull-Up" },
    { "exerciseName": "Bicep Curl" },
    { "exerciseName": "Lat Pulldown" }
  ]
}
```

### Bước 2: Chạy inference

```bash
python inference_exercise_recommendation.py \
    --input my_input.json \
    --output my_output.json \
    --top-k 5
```

### Bước 3: Xem kết quả

File `my_output.json`:

```json
{
  "exercises": [
    {
      "rank": 1,
      "name": "Squat",
      "suitabilityScore": 0.782,
      "sets": [
        {
          "reps": 12,
          "kg": 60.5,
          "km": 0.0,
          "min": 0.0,
          "minRest": 2.0
        },
        {
          "reps": 12,
          "kg": 60.5,
          "km": 0.0,
          "min": 0.0,
          "minRest": 2.0
        },
        {
          "reps": 12,
          "kg": 60.5,
          "km": 0.0,
          "min": 0.0,
          "minRest": 2.0
        }
      ],
      "predictedAvgHR": 135.2,
      "predictedPeakHR": 162.8
    },
    ...
  ],
  "totalRecommendations": 5
}
```

## 📊 Cách 3: Sử dụng trong Python Code

```python
from inference_exercise_recommendation import ExerciseRecommender

# Load model
recommender = ExerciseRecommender('../artifacts_exercise_rec')

# Prepare input
health_profile = {
    "age": 25,
    "height_m": 1.75,
    "weight_kg": 70,
    "bmi": 22.86,
    "fat_percentage": 15.5,
    "resting_heartrate": 65,
    "workout_frequency": 4,
    "gender": "Male",
    "experience_level": "Intermediate",
    "activity_level": "Moderate"
}

exercises = [
    "Barbell Bench Press (Wide Grip)",
    "Squat",
    "Pull-Up",
    "Bicep Curl",
    "Lat Pulldown"
]

# Get recommendations
recommendations = recommender.recommend(
    health_profile=health_profile,
    exercise_names=exercises,
    top_k=5
)

# Print results
for rec in recommendations:
    print(f"{rec['rank']}. {rec['name']}")
    print(f"   Score: {rec['suitabilityScore']:.3f}")
    print(f"   Sets: {len(rec['sets'])}, Reps: {rec['sets'][0]['reps']}")
    print(f"   Weight: {rec['sets'][0]['kg']:.1f} kg")
    print()
```

## 📝 Health Profile Fields

| Field               | Type   | Required | Description      | Example                              |
| ------------------- | ------ | -------- | ---------------- | ------------------------------------ |
| `age`               | int    | ✅       | Tuổi             | 25                                   |
| `height_m`          | float  | ✅       | Chiều cao (m)    | 1.75                                 |
| `weight_kg`         | float  | ✅       | Cân nặng (kg)    | 70                                   |
| `bmi`               | float  | ✅       | Chỉ số BMI       | 22.86                                |
| `fat_percentage`    | float  | ⚠️       | % mỡ cơ thể      | 15.5                                 |
| `resting_heartrate` | int    | ⚠️       | Nhịp tim nghỉ    | 65                                   |
| `workout_frequency` | int    | ⚠️       | Số buổi tập/tuần | 4                                    |
| `gender`            | string | ✅       | Giới tính        | "Male"/"Female"                      |
| `experience_level`  | string | ✅       | Trình độ         | "Beginner"/"Intermediate"/"Advanced" |
| `activity_level`    | string | ✅       | Mức độ hoạt động | "Low"/"Moderate"/"High"              |

⚠️ = Nếu không có, model sẽ impute giá trị mặc định

## 🎨 Output Format

```json
{
  "rank": 1,
  "name": "Squat",
  "suitabilityScore": 0.782,
  "sets": [
    {
      "reps": 12,
      "kg": 60.5,
      "km": 0.0,
      "min": 0.0,
      "minRest": 2.0
    }
  ],
  "predictedAvgHR": 135.2,
  "predictedPeakHR": 162.8
}
```

### Fields giải thích:

- **rank**: Thứ hạng (1 = tốt nhất)
- **name**: Tên bài tập (chính xác để map với DB)
- **suitabilityScore**: Điểm phù hợp (0-1, càng cao càng tốt)
- **sets**: Mảng các set (mỗi set có reps, kg, km, min, minRest)
- **predictedAvgHR**: Nhịp tim trung bình dự đoán
- **predictedPeakHR**: Nhịp tim đỉnh dự đoán

## 🔍 Troubleshooting

### Lỗi: "Exercise not found"

```
✓ Input exercises: 10
✓ Generated 0 recommendations
```

**Nguyên nhân:** Tên bài tập không khớp với database

**Giải pháp:** Kiểm tra tên bài tập trong `metadata.json`:

```bash
cat ../artifacts_exercise_rec/metadata.json | grep "exercise_list"
```

### Lỗi: "Module not found"

```
ModuleNotFoundError: No module named 'train_exercise_recommendation'
```

**Giải pháp:** Đảm bảo chạy từ đúng thư mục:

```bash
cd ai_server/artifacts_unified/src
python test_inference_demo.py
```

### Lỗi: "Checkpoint not found"

```
FileNotFoundError: ../artifacts_exercise_rec/best_model.pt
```

**Giải pháp:** Kiểm tra đường dẫn artifacts:

```bash
ls ../artifacts_exercise_rec/
# Phải có: best_model.pt, metadata.json, preprocessor.joblib
```

## 📚 Tham khảo

- [README_EXERCISE_REC.md](README_EXERCISE_REC.md) - Chi tiết về model
- [README_EVALUATION.md](README_EVALUATION.md) - Hướng dẫn đánh giá model
- [workflow.md](../../workflow.md) - Quy trình training

## 🎯 Next Steps

1. ✅ Test model với demo script
2. ✅ Tạo input JSON tùy chỉnh
3. ✅ Tích hợp vào backend API
4. ✅ Deploy model lên production

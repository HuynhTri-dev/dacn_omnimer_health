# Exercise Recommendation Model - Hướng Dẫn Sử Dụng

## Tổng Quan

Model gợi ý bài tập sử dụng **Exercise Embeddings** và **Multi-Task Learning** để:

1. Đánh giá mức độ phù hợp (suitability score) của từng bài tập
2. Dự đoán cường độ tập luyện (sets, reps, kg, km, min, minRest, avgHR, peakHR)

### Đặc điểm chính:

- ✅ **Exercise Embeddings**: Học representation cho mỗi bài tập
- ✅ **Exact Name Matching**: Giữ nguyên tên bài tập để mapping với database
- ✅ **Multi-Task Learning**: Kết hợp classification và regression
- ✅ **Separate Train/Test**: Train trên mapped_workout_dataset, test trên merged_omni_health_dataset

## Cấu Trúc Files

```
ai_server/artifacts_unified/src/
├── train_exercise_recommendation.py    # Script training
├── inference_exercise_recommendation.py # Script inference
└── README_EXERCISE_REC.md             # File này

artifacts_exercise_rec/                 # Artifacts sau khi train
├── best_model.pt                       # Model weights
├── preprocessor.joblib                 # Feature preprocessor
└── metadata.json                       # Metadata (exercise list, scales, etc.)
```

## 1. Training Model

### Chuẩn Bị Dữ Liệu

**Training Data**: `Data/data/mapped_workout_dataset_20251120_012453.xlsx`

- Dữ liệu đã được mapping với exercise database
- Chứa thông tin chi tiết về sets/reps/weight

**Test Data**: `Data/data/merged_omni_health_dataset.xlsx`

- Dữ liệu gốc để đánh giá model
- Đảm bảo model generalize tốt

### Chạy Training

```bash
cd ai_server/artifacts_unified/src

# Cách 1: Sử dụng mặc định
python train_exercise_recommendation.py

# Cách 2: Tùy chỉnh parameters
python train_exercise_recommendation.py \
  --train "../../../Data/data/mapped_workout_dataset_20251120_012453.xlsx" \
  --test "../../../Data/data/merged_omni_health_dataset.xlsx" \
  --artifacts "../artifacts_exercise_rec" \
  --epochs 100 \
  --batch-size 64 \
  --lr 0.001 \
  --load-cap-kg 200.0
```

### Tham Số Training

| Tham số         | Mặc định                                      | Mô tả                            |
| --------------- | --------------------------------------------- | -------------------------------- |
| `--train`       | `mapped_workout_dataset_20251120_012453.xlsx` | File training data               |
| `--test`        | `merged_omni_health_dataset.xlsx`             | File test data                   |
| `--artifacts`   | `../artifacts_exercise_rec`                   | Thư mục lưu artifacts            |
| `--epochs`      | 100                                           | Số epochs training               |
| `--batch-size`  | 64                                            | Batch size                       |
| `--lr`          | 0.001                                         | Learning rate                    |
| `--load-cap-kg` | 200.0                                         | Giới hạn trọng lượng tối đa (kg) |

### Output Training

```
================================================================================
EXERCISE RECOMMENDATION MODEL TRAINING
================================================================================

[1/10] Loading training data from: ...
  ✓ Loaded 12,345 training records

[2/10] Loading test data from: ...
  ✓ Loaded 1,234 test records

[3/10] Building exercise vocabulary...
  ✓ Found 150 unique exercises
  Top 10 exercises: ['Push up', 'Squat', 'Bench Press', ...]

...

[10/10] Starting training...
================================================================================
Epoch   1/100 | Train Loss: 0.5234 | Val Loss: 0.4567 | P@5: 0.678 | R@5: 0.543
  → Saved best model (P@5: 0.678)
Epoch   2/100 | Train Loss: 0.4123 | Val Loss: 0.3890 | P@5: 0.723 | R@5: 0.598
  → Saved best model (P@5: 0.723)
...
```

## 2. Inference (Sử Dụng Model)

### Format Input

Tạo file JSON với format sau (ví dụ: `input_example.json`):

```json
{
  "healthProfile": {
    "gender": "male",
    "age": 25,
    "height_m": 1.75,
    "weight_kg": 70,
    "bmi": 22.9,
    "bmr": 1750,
    "bodyFatPct": 15,
    "resting_hr": 65,
    "workout_frequency_per_week": 4,
    "experience_level": "Intermediate",
    "activity_level": "Active"
  },
  "exercises": [
    { "exerciseName": "Push up" },
    { "exerciseName": "Bench Press" },
    { "exerciseName": "Squat" },
    { "exerciseName": "Deadlift" },
    { "exerciseName": "Pull up" },
    { "exerciseName": "Shoulder Press" },
    { "exerciseName": "Bicep Curl" },
    { "exerciseName": "Tricep Dip" }
  ]
}
```

### Chạy Inference

```bash
python inference_exercise_recommendation.py \
  --artifacts "../artifacts_exercise_rec" \
  --input "input_example.json" \
  --output "output_recommendations.json" \
  --top-k 5
```

### Format Output

File `output_recommendations.json`:

```json
{
  "exercises": [
    {
      "rank": 1,
      "name": "Push up",
      "suitabilityScore": 0.892,
      "sets": [
        {
          "reps": 12,
          "kg": 0,
          "km": 0,
          "min": 0,
          "minRest": 2
        },
        {
          "reps": 12,
          "kg": 0,
          "km": 0,
          "min": 0,
          "minRest": 2
        },
        {
          "reps": 12,
          "kg": 0,
          "km": 0,
          "min": 0,
          "minRest": 2
        }
      ],
      "predictedAvgHR": 125,
      "predictedPeakHR": 145
    },
    {
      "rank": 2,
      "name": "Bench Press",
      "suitabilityScore": 0.856,
      "sets": [
        {
          "reps": 10,
          "kg": 60,
          "km": 0,
          "min": 0,
          "minRest": 3
        },
        {
          "reps": 10,
          "kg": 60,
          "km": 0,
          "min": 0,
          "minRest": 3
        },
        {
          "reps": 10,
          "kg": 60,
          "km": 0,
          "min": 0,
          "minRest": 3
        },
        {
          "reps": 10,
          "kg": 60,
          "km": 0,
          "min": 0,
          "minRest": 3
        }
      ],
      "predictedAvgHR": 130,
      "predictedPeakHR": 150
    }
  ],
  "totalRecommendations": 5
}
```

## 3. Tích Hợp với Backend

### Flow Hoàn Chỉnh

```
1. Frontend gửi request với health profile + goals
   ↓
2. Backend sử dụng RAG để lọc exercises phù hợp
   (dựa trên goal, muscle target, equipment, etc.)
   ↓
3. Backend gọi AI Model với:
   - healthProfile
   - exercises (danh sách từ RAG)
   ↓
4. AI Model trả về top-K exercises với:
   - name (chính xác để mapping DB)
   - suitabilityScore
   - sets/reps/kg/etc.
   - predictedAvgHR, predictedPeakHR
   ↓
5. Backend mapping exercise names với DB
   ↓
6. Trả về cho Frontend
```

### API Integration Example (Python)

```python
import json
import subprocess

def get_exercise_recommendations(health_profile, exercise_names, top_k=5):
    """
    Gọi AI model để lấy recommendations
    """
    # Tạo input
    input_data = {
        "healthProfile": health_profile,
        "exercises": [{"exerciseName": name} for name in exercise_names]
    }

    # Lưu input
    with open('temp_input.json', 'w') as f:
        json.dump(input_data, f)

    # Chạy inference
    subprocess.run([
        'python', 'inference_exercise_recommendation.py',
        '--artifacts', '../artifacts_exercise_rec',
        '--input', 'temp_input.json',
        '--output', 'temp_output.json',
        '--top-k', str(top_k)
    ])

    # Đọc output
    with open('temp_output.json', 'r') as f:
        recommendations = json.load(f)

    return recommendations['exercises']

# Sử dụng
health_profile = {
    "gender": "male",
    "age": 25,
    "weight_kg": 70,
    "height_m": 1.75,
    # ... other fields
}

# Danh sách exercises từ RAG
exercise_names = ["Push up", "Bench Press", "Squat", "Deadlift"]

# Lấy recommendations
recommendations = get_exercise_recommendations(health_profile, exercise_names, top_k=5)

# Mapping với DB
for rec in recommendations:
    exercise_name = rec['name']  # Tên chính xác
    # Query DB để lấy thông tin chi tiết
    exercise_details = db.query(Exercise).filter(Exercise.name == exercise_name).first()
    # ...
```

## 4. Model Architecture

### Input

- **Health Profile Features**: age, weight, height, BMI, BMR, body fat %, resting HR, etc.
- **Exercise Names**: Danh sách tên bài tập (từ RAG filtering)

### Model Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Health Profile                           │
│              (age, weight, BMI, etc.)                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │  Health Encoder      │
              │  (MLP: 256 → 256)    │
              └──────────┬───────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │  Health Projection   │
              │  (256 → 128)         │
              └──────────┬───────────┘
                         │
                         ├─────────────────────────────────┐
                         │                                 │
                         ▼                                 ▼
              ┌──────────────────────┐         ┌──────────────────────┐
              │ Exercise Embeddings  │         │ Exercise Embeddings  │
              │  (Learnable: 128-d)  │         │  (Learnable: 128-d)  │
              └──────────┬───────────┘         └──────────┬───────────┘
                         │                                 │
                         ▼                                 ▼
              ┌──────────────────────┐         ┌──────────────────────┐
              │ Joint Representation │         │ Joint Representation │
              │ [health, ex, h*ex]   │         │ [health, ex, h*ex]   │
              └──────────┬───────────┘         └──────────┬───────────┘
                         │                                 │
                         ▼                                 ▼
              ┌──────────────────────┐         ┌──────────────────────┐
              │ Suitability Head     │         │  Intensity Head      │
              │ (MLP → 1 score)      │         │  (MLP → 8 params)    │
              └──────────┬───────────┘         └──────────┬───────────┘
                         │                                 │
                         ▼                                 ▼
              ┌──────────────────────┐         ┌──────────────────────┐
              │ Suitability Scores   │         │ Intensity Parameters │
              │ [B, num_exercises]   │         │ [B, num_ex, 8]       │
              └──────────────────────┘         └──────────────────────┘
```

### Output

- **Suitability Scores**: [0, 1] cho mỗi exercise
- **Intensity Parameters**: 8 giá trị cho mỗi exercise
  1. `sets`: Số sets (1-5)
  2. `reps`: Số reps (5-20)
  3. `kg`: Trọng lượng (0-200 kg)
  4. `km`: Khoảng cách (0-20 km)
  5. `min`: Thời gian (0-120 phút)
  6. `minRest`: Thời gian nghỉ (0-5 phút)
  7. `avgHR`: Nhịp tim trung bình (60-180 bpm)
  8. `peakHR`: Nhịp tim đỉnh (100-200 bpm)

## 5. Metrics và Evaluation

### Training Metrics

- **Precision@5**: Tỷ lệ exercises đúng trong top-5 predictions
- **Recall@5**: Tỷ lệ exercises đúng được retrieve trong top-5
- **Classification Loss**: BCEWithLogitsLoss với pos_weight
- **Regression Loss**: Masked SmoothL1Loss (chỉ tính trên GT exercise)

### Evaluation

```bash
# Xem kết quả training
cat ../artifacts_exercise_rec/metadata.json

# Check best validation precision
grep "best_val_precision" ../artifacts_exercise_rec/metadata.json
```

## 6. Troubleshooting

### Lỗi: Exercise name không tìm thấy

**Nguyên nhân**: Exercise name trong input không có trong training data

**Giải pháp**:

1. Kiểm tra danh sách exercises trong `metadata.json`:

```bash
python -c "import json; f=open('../artifacts_exercise_rec/metadata.json'); print(json.load(f)['exercise_list'][:20])"
```

2. Đảm bảo tên exercise khớp chính xác (case-sensitive)

### Lỗi: Model performance thấp

**Nguyên nhân**: Dữ liệu training không đủ hoặc không cân bằng

**Giải pháp**:

1. Tăng số epochs: `--epochs 150`
2. Điều chỉnh learning rate: `--lr 0.0005`
3. Tăng batch size: `--batch-size 128`
4. Kiểm tra data distribution

### Lỗi: Out of memory

**Nguyên nhân**: Batch size quá lớn

**Giải pháp**:

```bash
python train_exercise_recommendation.py --batch-size 32
```

## 7. Best Practices

### Training

1. **Data Quality**: Đảm bảo dữ liệu training sạch và đầy đủ
2. **Validation**: Monitor validation metrics để tránh overfitting
3. **Checkpointing**: Model tự động save best checkpoint dựa trên P@5

### Inference

1. **Caching**: Cache model trong memory để tránh load lại nhiều lần
2. **Batch Processing**: Xử lý nhiều requests cùng lúc nếu có thể
3. **Error Handling**: Xử lý trường hợp exercise không tồn tại

### Production

1. **Model Versioning**: Lưu version của model và metadata
2. **A/B Testing**: Test model mới trước khi deploy
3. **Monitoring**: Track model performance trong production

## 8. Tham Khảo

- **README.md**: Yêu cầu tổng quan của hệ thống
- **workflow.md**: Quy trình training và deployment
- **train_unified_mtl.py**: Implementation tham khảo

## 9. Contact & Support

Nếu có vấn đề, vui lòng:

1. Kiểm tra logs trong quá trình training
2. Xem metadata.json để debug
3. Liên hệ team AI Server

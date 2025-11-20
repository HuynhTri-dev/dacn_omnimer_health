# Model Evaluation Guide

Hướng dẫn đánh giá mô hình AI cho hệ thống gợi ý bài tập và dự đoán cường độ tập luyện.

## 📋 Tổng quan

Có 2 loại model cần đánh giá:

1. **Exercise Recommendation Model** - Model gợi ý bài tập với exercise embeddings
2. **Multi-Task Learning (MTL) Model** - Model đa nhiệm vụ (classification + regression)

## 🎯 Các chỉ số đánh giá (Metrics)

### Classification Task (Gợi ý bài tập)

| Metric          | Ý nghĩa                                         | Target | Excellent |
| --------------- | ----------------------------------------------- | ------ | --------- |
| **Precision@5** | Tỷ lệ bài tập được gợi ý đúng trong Top 5       | ≥ 0.70 | ≥ 0.85    |
| **Recall@5**    | Tỷ lệ bài tập phù hợp được tìm thấy trong Top 5 | ≥ 0.60 | ≥ 0.75    |
| **F1-Score@5**  | Trung bình điều hòa của Precision và Recall     | ≥ 0.65 | ≥ 0.80    |

### Regression Task (Dự đoán cường độ)

| Metric   | Parameter         | Target             | Excellent |
| -------- | ----------------- | ------------------ | --------- |
| **MAE**  | Sets (số hiệp)    | ≤ 0.5              | ≤ 0.3     |
| **MAE**  | Reps (số lần lặp) | ≤ 2.0              | ≤ 1.0     |
| **MAE**  | Load (kg)         | ≤ 5.0              | ≤ 3.0     |
| **RMSE** | Tất cả parameters | Càng thấp càng tốt | -         |
| **R²**   | Tất cả parameters | ≥ 0.70             | ≥ 0.85    |

## 🚀 Cách sử dụng

### 1. Đánh giá Exercise Recommendation Model

```bash
cd ai_server/artifacts_unified/src

# Sử dụng đường dẫn mặc định
python evaluate_exercise_model.py

# Hoặc chỉ định đường dẫn cụ thể
python evaluate_exercise_model.py \
    --model_path ../artifacts_exercise_rec/best_model.pt \
    --test_data ../../../Data/data/merged_omni_health_dataset.xlsx \
    --artifacts ../artifacts_exercise_rec
```

**Output mẫu:**

```
================================================================================
EXERCISE RECOMMENDATION MODEL EVALUATION
================================================================================

[1/6] Loading metadata from: ../artifacts_exercise_rec/metadata.json
  ✓ Model trained on: 2025-11-20T12:30:45
  ✓ Number of exercises: 66

[2/6] Loaded preprocessor from: ../artifacts_exercise_rec/preprocessor.joblib

[3/6] Loading test data from: ../../../Data/data/merged_omni_health_dataset.xlsx
  ✓ Loaded 204 test samples

[4/6] Loading model from: ../artifacts_exercise_rec/best_model.pt
  ✓ Model loaded (epoch 85)

[5/6] Running evaluation...

[6/6] Evaluation Results:
================================================================================

📊 CLASSIFICATION METRICS (Exercise Recommendation)
--------------------------------------------------------------------------------
  Precision@5:  0.7823
  Recall@5:     0.6541
  F1-Score@5:   0.7123
  Precision@10: 0.7234
  Recall@10:    0.7012
  F1-Score@10:  0.7121

📈 REGRESSION METRICS (Intensity Parameters)
--------------------------------------------------------------------------------
Parameter       MAE          RMSE         R²           Samples
--------------------------------------------------------------------------------
sets            0.3245       0.4521       0.8234       195
reps            1.2341       1.8923       0.7823       195
kg              2.8934       4.1234       0.8512       180
km              0.4523       0.6234       0.7234       24
min             3.2341       5.1234       0.7923       204
minRest         0.2341       0.3456       0.6234       150
avgHR           5.2341       8.1234       0.7512       180
peakHR          6.3412       9.2341       0.7234       180

✅ Evaluation completed!
Results saved to: ../artifacts_exercise_rec/evaluation_results.json
================================================================================
```

### 2. Đánh giá MTL Model

```bash
cd ai_server/artifacts_unified/src

# Sử dụng đường dẫn mặc định
python evaluate_mtl_model.py

# Hoặc chỉ định đường dẫn cụ thể
python evaluate_mtl_model.py \
    --model_path ../artifacts_omni_mlbce/best.pt \
    --test_data ../data/merged_omni_health_dataset.xlsx \
    --artifacts ../artifacts_omni_mlbce
```

**Output mẫu:**

```
================================================================================
MULTI-TASK LEARNING (MTL) MODEL EVALUATION
================================================================================

[1/6] Loading metadata from: ../artifacts_omni_mlbce/meta.json
  ✓ Number of exercises: 200
  ✓ Input dimension: 15

[2/6] Loaded preprocessor from: ../artifacts_omni_mlbce/preprocessor.joblib

[3/6] Loading test data from: ../data/merged_omni_health_dataset.xlsx
  ✓ Loaded 204 test samples

[4/6] Loading model from: ../artifacts_omni_mlbce/best.pt
  ✓ Model loaded successfully

[5/6] Running evaluation...

[6/6] Evaluation Results:
================================================================================

📊 CLASSIFICATION METRICS (Exercise Recommendation)
--------------------------------------------------------------------------------
  Precision@5:  0.8123
  Recall@5:     0.6823
  F1-Score@5:   0.7412
  Precision@10: 0.7534
  Recall@10:    0.7234
  F1-Score@10:  0.7381

📈 REGRESSION METRICS (Intensity Parameters)
--------------------------------------------------------------------------------
Parameter       MAE          RMSE         R²           Samples
--------------------------------------------------------------------------------
sets            0.2834       0.3921       0.8634       195
reps            1.0234       1.5234       0.8234       195
load_kg         2.3412       3.4521       0.8823       180

🎯 PERFORMANCE ASSESSMENT
--------------------------------------------------------------------------------
  Classification P@5: 0.8123 - ✅ Good
  Classification R@5: 0.6823 - ✅ Good
  Regression Sets MAE: 0.2834 - 🌟 Excellent
  Regression Reps MAE: 1.0234 - 🌟 Excellent
  Regression Load MAE: 2.3412 kg - 🌟 Excellent

✅ Evaluation completed!
Results saved to: ../artifacts_omni_mlbce/evaluation_results.json
================================================================================
```

## 📊 Kết quả đầu ra

Sau khi chạy evaluation, file `evaluation_results.json` sẽ được tạo ra với cấu trúc:

```json
{
  "classification": {
    "precision@5": 0.8123,
    "recall@5": 0.6823,
    "f1@5": 0.7412,
    "precision@10": 0.7534,
    "recall@10": 0.7234,
    "f1@10": 0.7381
  },
  "regression": {
    "sets": {
      "mae": 0.2834,
      "rmse": 0.3921,
      "r2": 0.8634,
      "n_samples": 195
    },
    "reps": {
      "mae": 1.0234,
      "rmse": 1.5234,
      "r2": 0.8234,
      "n_samples": 195
    },
    "load_kg": {
      "mae": 2.3412,
      "rmse": 3.4521,
      "r2": 0.8823,
      "n_samples": 180
    }
  },
  "test_samples": 204,
  "model_path": "../artifacts_omni_mlbce/best.pt",
  "test_data_path": "../data/merged_omni_health_dataset.xlsx"
}
```

## 🔍 Phân tích kết quả

### Giải thích các metrics

#### **Precision@K**

- Đo lường độ chính xác của các gợi ý
- Công thức: `TP / (TP + FP)`
- Ví dụ: Precision@5 = 0.80 nghĩa là 80% trong 5 bài tập được gợi ý là phù hợp

#### **Recall@K**

- Đo lường độ bao phủ của các gợi ý
- Công thức: `TP / (TP + FN)`
- Ví dụ: Recall@5 = 0.70 nghĩa là 70% bài tập phù hợp được tìm thấy trong Top 5

#### **F1-Score@K**

- Trung bình điều hòa của Precision và Recall
- Công thức: `2 * (P * R) / (P + R)`
- Cân bằng giữa độ chính xác và độ bao phủ

#### **MAE (Mean Absolute Error)**

- Sai số tuyệt đối trung bình
- Công thức: `Σ|y_pred - y_true| / n`
- Ví dụ: MAE = 1.5 reps nghĩa là trung bình sai lệch 1.5 lần lặp

#### **RMSE (Root Mean Square Error)**

- Căn bậc hai của sai số bình phương trung bình
- Công thức: `√(Σ(y_pred - y_true)² / n)`
- Phạt nặng hơn các sai số lớn

#### **R² Score**

- Hệ số xác định - đo mức độ phù hợp của mô hình
- Giá trị từ 0 đến 1 (1 là hoàn hảo)
- R² = 0.85 nghĩa là mô hình giải thích được 85% phương sai của dữ liệu

### Khi nào cần cải thiện model?

⚠️ **Cần cải thiện nếu:**

- Precision@5 < 0.70
- Recall@5 < 0.60
- MAE (Sets) > 0.5
- MAE (Reps) > 2.0
- MAE (Load) > 5.0 kg
- R² < 0.70

✅ **Model tốt nếu:**

- 0.70 ≤ Precision@5 < 0.85
- 0.60 ≤ Recall@5 < 0.75
- 0.3 < MAE (Sets) ≤ 0.5
- 1.0 < MAE (Reps) ≤ 2.0
- 3.0 < MAE (Load) ≤ 5.0 kg
- 0.70 ≤ R² < 0.85

🌟 **Model xuất sắc nếu:**

- Precision@5 ≥ 0.85
- Recall@5 ≥ 0.75
- MAE (Sets) ≤ 0.3
- MAE (Reps) ≤ 1.0
- MAE (Load) ≤ 3.0 kg
- R² ≥ 0.85

## 🛠️ Troubleshooting

### Lỗi: "File not found"

```bash
# Kiểm tra đường dẫn
ls ../artifacts_exercise_rec/best_model.pt
ls ../../../Data/data/merged_omni_health_dataset.xlsx
```

### Lỗi: "Module not found"

```bash
# Đảm bảo đang ở đúng thư mục
cd ai_server/artifacts_unified/src

# Hoặc thêm PYTHONPATH
export PYTHONPATH="${PYTHONPATH}:$(pwd)"
```

### Lỗi: "CUDA out of memory"

```python
# Trong script, thay đổi:
device = torch.device('cpu')  # Thay vì 'cuda'
```

## 📚 Tham khảo

- [Workflow Training](../../workflow.md) - Quy trình training model
- [README Exercise Recommendation](README_EXERCISE_REC.md) - Chi tiết về Exercise Recommendation Model
- [Scikit-learn Metrics](https://scikit-learn.org/stable/modules/model_evaluation.html) - Tài liệu về metrics

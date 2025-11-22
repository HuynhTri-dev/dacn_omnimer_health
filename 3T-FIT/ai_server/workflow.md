# Workflow Training Model AI Server

Tài liệu này mô tả quy trình huấn luyện (training) cho mô hình Multi-Task Learning (MTL) được sử dụng trong dự án.

## 1. Tổng quan về Model

Model sử dụng kiến trúc **Multi-Task Learning (MTL)** để giải quyết đồng thời hai bài toán:

1.  **Gợi ý bài tập (Classification):** Dự đoán danh sách các bài tập phù hợp (Multi-label classification).
2.  **Dự đoán thông số tập luyện (Regression):** Dự đoán số sets, reps và khối lượng tạ (load_kg) phù hợp.

### Đặc điểm kỹ thuật:

- **Backbone:** Mạng Neural Network thuần (MLP) với các lớp Linear, ReLU và Dropout.
- **Loss Function:**
  - Classification: `BCEWithLogitsLoss` với `pos_weight` (để xử lý mất cân bằng dữ liệu) hoặc `Focal Loss`.
  - Regression: `SmoothL1Loss` (Huber Loss).
  - Tổng hợp: `Loss = 1.0 * cls_loss + 0.25 * reg_loss`.
- **Optimizer:** AdamW.

## 2. Chuẩn bị dữ liệu

Dữ liệu đầu vào là file Excel (`.xlsx`) chứa thông tin người dùng và lịch sử tập luyện.

- **Đường dẫn mặc định:** `data/merged_omni_health_dataset.xlsx`
- **Các cột quan trọng:**
  - Features: `age`, `height_cm`, `weight_kg`, `gender`, `experience_level`, ...
  - Labels (Bài tập): `exercise_name` (được xử lý thành multi-hot vector).
  - Targets (Thông số): `sets/reps/weight/timeresteachset` (chuỗi dạng `sets | reps | weight`).

## 3. Cài đặt môi trường

Đảm bảo đã cài đặt các thư viện cần thiết:

```bash
pip install torch pandas numpy scikit-learn joblib openpyxl
```

## 4. Thực hiện Training

Chạy script `train_mtl_multilabel_weighted.py` để bắt đầu huấn luyện.

### Lệnh cơ bản:

```bash
python artifacts_unified/src/train_mtl_multilabel_weighted.py
```

### Các tham số tùy chỉnh (Arguments):

| Tham số         | Mặc định                               | Mô tả                                                    |
| :-------------- | :------------------------------------- | :------------------------------------------------------- |
| `--excel_path`  | `data/merged_omni_health_dataset.xlsx` | Đường dẫn đến file dữ liệu huấn luyện.                   |
| `--artifacts`   | `artifacts_omni_mlbce`                 | Thư mục lưu kết quả (model, preprocessor).               |
| `--epochs`      | `80`                                   | Số vòng lặp huấn luyện.                                  |
| `--batch_size`  | `128`                                  | Kích thước batch.                                        |
| `--lr`          | `0.001`                                | Learning rate.                                           |
| `--use_focal`   | `False`                                | Thêm cờ này nếu muốn dùng Focal Loss thay vì BCE thường. |
| `--load_cap_kg` | `200.0`                                | Giới hạn khối lượng tạ tối đa để chuẩn hóa.              |

### Ví dụ chạy với Focal Loss và 100 epochs:

```bash
python artifacts_unified/src/train_mtl_multilabel_weighted.py --epochs 100 --use_focal --artifacts my_new_model
```

## 5. Kết quả đầu ra (Artifacts)

Sau khi training xong, các file sau sẽ được tạo ra trong thư mục `artifacts` (hoặc thư mục bạn chỉ định):

1.  **`best.pt`**: File trọng số của model (PyTorch state dict) tại epoch có độ chính xác (Precision@5) cao nhất trên tập validation.
2.  **`preprocessor.joblib`**: Pipeline xử lý dữ liệu (StandardScaler, OneHotEncoder) đã được fit. Cần dùng file này để xử lý dữ liệu mới khi inference.
3.  **`meta.json`**: File metadata chứa thông tin cấu hình, danh sách các cột bài tập, và các tham số scale cho regression (min/max của sets, reps, load).
4.  **`BEST.txt`**: Ghi lại kết quả tốt nhất đạt được.

## 6. Đánh giá Mô hình (Model Evaluation)

Sau khi training, mô hình được đánh giá trên **Tập Kiểm tra (Test Set)** - dữ liệu mà mô hình chưa từng thấy trong quá trình huấn luyện.

### 6.1. Các chỉ số đo lường (Metrics)

Model sử dụng các metrics khác nhau cho từng task:

#### **A. Classification Task (Gợi ý bài tập)**

| Metric          | Công thức               | Ý nghĩa                                                  |
| :-------------- | :---------------------- | :------------------------------------------------------- |
| **Precision@K** | `TP / (TP + FP)`        | Tỷ lệ bài tập được gợi ý đúng trong Top K bài tập.       |
| **Recall@K**    | `TP / (TP + FN)`        | Tỷ lệ bài tập phù hợp được tìm thấy trong Top K bài tập. |
| **F1-Score@K**  | `2 * (P * R) / (P + R)` | Trung bình điều hòa của Precision và Recall.             |
| **Accuracy**    | `(TP + TN) / Total`     | Tỷ lệ dự đoán đúng tổng thể (ít dùng cho multi-label).   |

**Giải thích:**

- **K = 5**: Model gợi ý Top 5 bài tập phù hợp nhất
- **TP (True Positive)**: Số bài tập được gợi ý đúng
- **FP (False Positive)**: Số bài tập được gợi ý sai
- **FN (False Negative)**: Số bài tập phù hợp nhưng không được gợi ý

#### **B. Regression Task (Dự đoán thông số)**

| Metric       | Công thức                    | Ý nghĩa                                                 |
| :----------- | :--------------------------- | :------------------------------------------------------ |
| **RMSE**     | `√(Σ(y_pred - y_true)² / n)` | Sai số bình phương trung bình (Root Mean Square Error). |
| **MAE**      | `Σ\|y_pred - y_true\| / n`   | Sai số tuyệt đối trung bình (Mean Absolute Error).      |
| **R² Score** | `1 - (SS_res / SS_tot)`      | Hệ số xác định - đo mức độ phù hợp của mô hình.         |

**Áp dụng cho:**

- **Sets**: Số hiệp tập luyện
- **Reps**: Số lần lặp lại mỗi hiệp
- **Load (kg)**: Khối lượng tạ phù hợp

### 6.2. Cách đánh giá trong quá trình Training

Trong quá trình training, model tự động tính toán metrics trên **Validation Set** sau mỗi epoch:

```
Epoch  50/100 | Train Loss: 0.3245 | Val Loss: 0.3567 | P@5: 0.782 | R@5: 0.654
```

**Ý nghĩa:**

- `Train Loss`: Loss trên tập huấn luyện (càng thấp càng tốt)
- `Val Loss`: Loss trên tập validation (dùng để phát hiện overfitting)
- `P@5`: Precision@5 - độ chính xác của Top 5 gợi ý
- `R@5`: Recall@5 - độ bao phủ của Top 5 gợi ý

### 6.3. Đánh giá trên Test Set

Sau khi training xong, bạn có thể đánh giá model trên test set bằng cách:

#### **Tự động (trong script training):**

Script `train_exercise_recommendation.py` và `train_mtl_multilabel_weighted.py` đã tích hợp sẵn evaluation trên test set.

#### **Thủ công (sử dụng script riêng):**

```bash
# Đánh giá model Exercise Recommendation
python artifacts_unified/src/evaluate_exercise_model.py \
    --model_path artifacts_exercise_rec/best_model.pt \
    --test_data ../Data/data/merged_omni_health_dataset.xlsx

# Đánh giá model MTL
python artifacts_unified/src/evaluate_mtl_model.py \
    --model_path artifacts_omni_mlbce/best.pt \
    --test_data data/merged_omni_health_dataset.xlsx
```

### 6.4. Kết quả mong đợi

| Task              | Metric      | Target   | Excellent |
| :---------------- | :---------- | :------- | :-------- |
| Classification    | Precision@5 | ≥ 0.70   | ≥ 0.85    |
| Classification    | Recall@5    | ≥ 0.60   | ≥ 0.75    |
| Regression (Sets) | MAE         | ≤ 0.5    | ≤ 0.3     |
| Regression (Reps) | MAE         | ≤ 2.0    | ≤ 1.0     |
| Regression (Load) | MAE         | ≤ 5.0 kg | ≤ 3.0 kg  |

### 6.5. Phân tích lỗi (Error Analysis)

Để hiểu rõ hơn về lỗi của model:

1. **Confusion Matrix**: Xem bài tập nào hay bị nhầm lẫn
2. **Error Distribution**: Phân bố sai số theo từng nhóm người dùng
3. **Feature Importance**: Đặc trưng nào ảnh hưởng nhiều nhất

**Ví dụ phân tích:**

```python
# Xem các bài tập bị dự đoán sai nhiều nhất
import pandas as pd
import numpy as np

# Load predictions và ground truth
errors = []
for i, (pred, true) in enumerate(zip(predictions, ground_truth)):
    if pred != true:
        errors.append({
            'sample_id': i,
            'predicted': pred,
            'true': true,
            'user_level': user_levels[i]
        })

error_df = pd.DataFrame(errors)
print(error_df.groupby('predicted').size().sort_values(ascending=False))
```

## 7. Sử dụng Model (Inference)

Để sử dụng model dự đoán:

1.  Load `preprocessor.joblib` để biến đổi dữ liệu đầu vào của user.
2.  Khởi tạo class `MTLNet` với `in_dim` và `num_exercises` lấy từ `meta.json` hoặc `best.pt`.
3.  Load weights từ `best.pt`.
4.  Đưa dữ liệu qua model để lấy logits (bài tập) và regression output (sets/reps/load).
5.  Giải mã output:
    - Logits -> Sigmoid -> Top K bài tập có xác suất cao nhất.
    - Regression output -> Inverse transform (nhân với range + min) để ra số thực tế.

### 7.1. Ví dụ Inference Code

```python
import torch
import joblib
import json
import pandas as pd

# 1. Load artifacts
preprocessor = joblib.load('artifacts_omni_mlbce/preprocessor.joblib')
with open('artifacts_omni_mlbce/meta.json', 'r') as f:
    meta = json.load(f)

# 2. Load model
checkpoint = torch.load('artifacts_omni_mlbce/best.pt')
model = MTLNet(
    in_dim=checkpoint['in_dim'],
    num_exercises=checkpoint['num_exercises']
)
model.load_state_dict(checkpoint['model_state_dict'])
model.eval()

# 3. Prepare input data
user_data = pd.DataFrame([{
    'age': 25,
    'height_cm': 170,
    'weight_kg': 70,
    'gender': 'Male',
    'experience_level': 'Intermediate',
    'activity_level': 'Moderate'
}])

# 4. Preprocess
X = preprocessor.transform(user_data)
X_tensor = torch.FloatTensor(X.toarray() if hasattr(X, 'toarray') else X)

# 5. Predict
with torch.no_grad():
    logits, regression_output = model(X_tensor)
    probs = torch.sigmoid(logits)

    # Get Top 5 exercises
    top5_indices = torch.topk(probs, k=5, dim=1).indices[0]
    top5_exercises = [meta['exercise_list'][idx] for idx in top5_indices]

    # Get intensity parameters
    sets, reps, load = regression_output[0].numpy()

print(f"Recommended exercises: {top5_exercises}")
print(f"Intensity: {sets:.0f} sets x {reps:.0f} reps @ {load:.1f} kg")
```

# Model v3: Capability-Based Recommendation System

## 📌 Tổng Quan

**Model v3** là phiên bản nâng cấp từ v1, áp dụng chiến lược **"Dự đoán Năng lực (Capability Prediction)"** thay vì **"Dự đoán Bài tập (Prescription Prediction)"**.

### Sự khác biệt cốt lõi:

| Phương pháp          | v1 (Hiện tại)                                        | v3 (Nâng cấp)                                                                 |
| -------------------- | ---------------------------------------------------- | ----------------------------------------------------------------------------- |
| **Đầu vào**          | User Profile + Exercise History                      | User Profile + Exercise History                                               |
| **Model dự đoán**    | `Sets`, `Reps`, `Weight`, `Rest`, `HR`... (8 chiều)  | **`1RM`** (Sức mạnh), **`Pace`** (Tốc độ), `Duration`, `Rest`, `HR` (6 chiều) |
| **Đầu ra cuối cùng** | Trực tiếp từ model                                   | Model → **Rule-based Decoder** → Sets/Reps theo Goal                          |
| **Vấn đề**           | Model "học vẹt" dữ liệu, dễ đưa ra mức tạ/reps vô lý | Model học **năng lực nền tảng**, Decoder đảm bảo tính hợp lý                  |

---

## 🎯 Mục Tiêu v3

1. **Giảm chiều dữ liệu (Dimensionality Reduction):** Từ 8 chiều → 6 chiều, tập trung vào các chỉ số năng lực cốt lõi.
2. **Tăng tính giải thích (Explainability):** Dễ dàng giải thích cho user: _"Hôm nay bạn có thể đẩy tối đa 80kg (1RM), nên tập 60kg x 10 reps để tăng cơ."_
3. **Linh hoạt theo Goal:** Một mức 1RM có thể sinh ra nhiều bài tập khác nhau tùy mục tiêu (Strength/Hypertrophy/Endurance).
4. **Tích hợp SePA (Self-Perceived Assessment):** Điều chỉnh cường độ dựa trên trạng thái hàng ngày (Fatigue, Stress, Soreness).

---

## 📊 Kiến Trúc Model v3

```
┌─────────────────────────────────────────────────────────────┐
│                    INPUT LAYER                              │
│  • User Profile (Age, Gender, BMI, Experience, Goal...)     │
│  • Historical Workout Data (Past 1RM, HR, Fatigue...)       │
│  • Daily Readiness (Mood, Soreness, Sleep Quality)          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              FEATURE ENGINEERING                            │
│  • Calculate Estimated 1RM (Epley Formula)                  │
│  • Calculate Pace (km/h) for Cardio exercises               │
│  • Normalize all features to [0, 1]                         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│           UNIFIED MTL MODEL (Multi-Task Learning)           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Task 1: Exercise Classification (Multi-label)      │   │
│  │  → Predict suitability score for each exercise      │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Task 2: Capability Regression (6-dim)              │   │
│  │  → Predict: [1RM, Pace, Duration, Rest, AvgHR, PeakHR] │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              MODEL OUTPUT (Raw Prediction)                  │
│  • Top-5 Exercises (by suitability score)                   │
│  • Predicted 1RM: 82kg (for Bench Press)                    │
│  • Predicted Pace: 10 km/h (for Running)                    │
│  • Predicted AvgHR: 135 bpm                                 │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│         RULE-BASED DECODER (Goal-Specific)                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  IF Goal = "Strength":                              │   │
│  │    Weight = 1RM × 0.85-0.95                         │   │
│  │    Reps = 5-15, Sets = 1-5, Rest = 3-5 mins         │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  IF Goal = "Hypertrophy":                           │   │
│  │    Weight = 1RM × 0.70-0.80                         │   │
│  │    Reps = 8-20, Sets = 1-5, Rest = 1-2 mins         │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  IF Goal = "Endurance":                             │   │
│  │    Weight = 1RM × 0.50-0.60                         │   │
│  │    Reps = 10-30, Sets = 1-5, Rest = 30-60 secs      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│         AUTO-REGULATION (SePA Integration)                  │
│  • IF Fatigue = High → Readiness Factor = 0.8              │
│  • IF Mood = Good + Sleep = Excellent → Factor = 1.05       │
│  • Final Weight = Calculated Weight × Readiness Factor      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              FINAL OUTPUT (API Response)                    │
│  {                                                          │
│    "exercises": [                                           │
│      {                                                      │
│        "name": "Bench Press",                               │
│        "suitabilityScore": 0.92,                            │
│        "sets": [                                            │
│          {"reps": 10, "kg": 62, "minRest": 2},              │
│          {"reps": 10, "kg": 62, "minRest": 2},              │
│          {"reps": 8, "kg": 65, "minRest": 2.5}              │
│        ],                                                   │
│        "predictedAvgHR": 135,                               │
│        "predictedPeakHR": 155                               │
│      }                                                      │
│    ]                                                        │
│  }                                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Pipeline Phát Triển v3

### Phase 1: Data Preparation & Feature Engineering

#### ✅ Checklist:

- [ ] **1.1. Parse dữ liệu thô**

  - Viết script Python để parse cột `sets/reps/weight/timeresteachset` trong Excel.
  - Tách chuỗi `"12x40x2 | 8x50x3"` thành danh sách các sets.

- [ ] **1.2. Tính toán Estimated 1RM**

  - Áp dụng công thức Epley: $1RM = Weight \times (1 + \frac{Reps}{30})$
  - Lưu kết quả vào cột mới `estimated_1rm`.
  - **Lưu ý:** Với bodyweight exercises (Push-up, Pull-up), sử dụng RPE (Rate of Perceived Exertion) thay thế.

- [ ] **1.3. Tính toán Pace cho Cardio**

  - Công thức: $Pace (km/h) = \frac{Distance (km)}{Duration (hours)}$
  - Xử lý giá trị vô cực (inf) khi duration = 0.

- [ ] **1.4. Tách tập dữ liệu**

  - **Strength exercises:** Sử dụng `1RM` làm target chính.
  - **Cardio exercises:** Sử dụng `Pace` làm target chính.
  - **Mixed exercises:** Sử dụng cả hai (multi-modal).

- [ ] **1.5. Xử lý Cold-start**
  - Với user mới (chưa có lịch sử), gán 1RM khởi điểm dựa trên:
    - Gender, Age, Weight, Experience Level.
    - Tham khảo bảng chuẩn từ nghiên cứu P3FitRec.

**Output:** `merged_omni_health_dataset_v3.xlsx` với các cột mới: `estimated_1rm`, `pace_kmh`, `exercise_type` (Strength/Cardio/Mixed).

---

### Phase 2: Model Architecture Upgrade

#### ✅ Checklist:

- [ ] **2.1. Cập nhật `parse_srw` function**

  ```python
  def parse_srw(cell):
      """
      Parses 'sets/reps/weight' and calculates Estimated 1RM.
      Returns: (max_1rm, med_rest)
      """
      # Implementation với Epley formula
  ```

- [ ] **2.2. Cập nhật `UnifiedMTL` model**

  - Thay đổi regression head từ 8-dim → 6-dim:
    ```python
    self.head_reg = nn.Sequential(
        nn.Linear(d*3, joint_d), nn.ReLU(),
        nn.Linear(joint_d, 128), nn.ReLU(),
        nn.Linear(128, 6)  # [1RM, Pace, Duration, Rest, AvgHR, PeakHR]
    )
    ```

- [ ] **2.3. Cập nhật Target Preparation**

  - Thay thế việc chuẩn hóa `sets`, `reps`, `kg` bằng `1RM`, `Pace`.
  - Định nghĩa scales mới:
    ```python
    scales = {
        "1RM": (0.0, 200.0),      # kg
        "Pace": (0.0, 25.0),       # km/h
        "Duration": (0.0, 120.0),  # minutes
        "Rest": (0.0, 5.0),        # minutes
        "AvgHR": (60.0, 180.0),    # bpm
        "PeakHR": (100.0, 200.0)   # bpm
    }
    ```

- [ ] **2.4. Cập nhật Loss Function**

  - Điều chỉnh `masked_reg_loss` để xử lý 6 chiều thay vì 8.

- [ ] **2.5. Cập nhật Metadata**
  - File `meta.json` cần ghi rõ:
    ```json
    {
      "regression_dims": ["1RM", "Pace", "Duration", "Rest", "AvgHR", "PeakHR"],
      "note": "Model v3: Predicts user capability (1RM/Pace). Requires Rule-based Decoder for Sets/Reps generation."
    }
    ```

**Output:** `train_unified_mtl_v3.py` với kiến trúc mới.

---

### Phase 3: Rule-based Decoder Implementation

#### ✅ Checklist:

- [ ] **3.1. Xây dựng Decoder cho Strength exercises**

  - Tạo file `decoder_strength.py`:

    ```python
    def decode_strength(predicted_1rm: float, goal: str, readiness_factor: float = 1.0):
        """
        Convert predicted 1RM to Sets/Reps/Weight based on Goal.

        Args:
            predicted_1rm: Model's prediction (e.g., 82kg)
            goal: "Strength" | "Hypertrophy" | "Endurance"
            readiness_factor: 0.8-1.05 based on fatigue/mood

        Returns:
            {
                "sets": 4,
                "reps": 10,
                "weight": 62,
                "rest_min": 2
            }
        """
        # Implementation theo bảng trong Strategy_Analysis.md
    ```

- [ ] **3.2. Xây dựng Decoder cho Cardio exercises**

  - Tạo file `decoder_cardio.py`:

    ```python
    def decode_cardio(predicted_pace: float, goal: str, duration_min: float):
        """
        Convert predicted Pace to Duration/Intensity based on Goal.

        Args:
            predicted_pace: Model's prediction (e.g., 10 km/h)
            goal: "FatLoss" | "Cardio" | "HIIT"
            duration_min: Desired workout duration

        Returns:
            {
                "pace_kmh": 8.5,
                "duration_min": 30,
                "hr_zone": "Zone 2",
                "intervals": [...]  # For HIIT
            }
        """
    ```

- [ ] **3.3. Tích hợp SePA (Auto-Regulation)**

  - Tạo file `auto_regulation.py`:

    ```python
    def calculate_readiness_factor(fatigue: int, mood: str, sleep_quality: int, soreness: int):
        """
        Calculate adjustment factor based on daily readiness.

        Args:
            fatigue: 1-10 scale
            mood: "Poor" | "Fair" | "Good" | "Excellent"
            sleep_quality: 1-10 scale
            soreness: 1-10 scale

        Returns:
            float: 0.8 (reduce load) to 1.05 (progressive overload)
        """
    ```

**Output:** Module `decoders/` với các file decoder riêng biệt.

---

### Phase 4: Training & Evaluation

#### ✅ Checklist:

- [ ] **4.1. Training Script**

  - Chạy training với dataset mới:
    ```bash
    python train_unified_mtl_v3.py \
      --excel_path data/merged_omni_health_dataset_v3.xlsx \
      --artifacts artifacts_v3 \
      --epochs 100 \
      --batch_size 128 \
      --lr 1e-3
    ```

- [ ] **4.2. Evaluation Metrics**

  - **Classification:** Precision@5, Recall@5, Cosine Similarity.
  - **Regression:** MAE, RMSE cho từng chiều (1RM, Pace, HR...).
  - **Custom Metric:** "Physiological Validity" - % predictions nằm trong ngưỡng an toàn.

- [ ] **4.3. Validation với Expert**

  - Lấy 50 samples ngẫu nhiên.
  - So sánh output của v3 với v1.
  - Đánh giá tính hợp lý bởi chuyên gia thể hình.

- [ ] **4.4. A/B Testing (Optional)**
  - Deploy song song v1 và v3.
  - Thu thập feedback từ user thực tế.
  - So sánh: Completion Rate, User Satisfaction, Injury Rate.

**Output:** Model checkpoint `best_v3.pt`, báo cáo đánh giá `evaluation_v3.pdf`.

---

### Phase 5: API Integration

#### ✅ Checklist:

- [ ] **5.1. Cập nhật Inference Pipeline**

  - File `inference_v3.py`:
    ```python
    def predict_workout(user_profile, exercise_list, goal, daily_readiness):
        # 1. Load model v3
        # 2. Predict 1RM/Pace
        # 3. Apply Rule-based Decoder
        # 4. Apply Auto-Regulation
        # 5. Return final workout plan
    ```

- [ ] **5.2. API Endpoint**

  - Cập nhật `/api/v3/recommend` để sử dụng model v3.
  - Đảm bảo backward compatibility với v1 (cho user cũ).

- [ ] **5.3. Response Format**

  - Theo đúng format trong `README.md`:
    ```json
    {
      "exercises": [
        {
          "name": "Bench Press",
          "sets": [
            { "reps": 10, "kg": 62, "minRest": 2 },
            { "reps": 10, "kg": 62, "minRest": 2 },
            { "reps": 8, "kg": 65, "minRest": 2.5 }
          ],
          "suitabilityScore": 0.92,
          "predictedAvgHR": 135,
          "predictedPeakHR": 155,
          "explanation": "Hôm nay bạn có thể đẩy tối đa 82kg. Với mục tiêu Tăng cơ, tập 75% 1RM = 62kg."
        }
      ]
    }
    ```

- [ ] **5.4. Testing**
  - Unit tests cho từng component.
  - Integration tests cho toàn bộ pipeline.
  - Load testing với 1000 concurrent requests.

**Output:** API v3 production-ready.

---

## 📈 So Sánh v1 vs v3

| Tiêu chí                   | v1 (Hiện tại)    | v3 (Nâng cấp)                | Cải thiện        |
| -------------------------- | ---------------- | ---------------------------- | ---------------- |
| **Số chiều regression**    | 8                | 6                            | ↓ 25% complexity |
| **Tính giải thích**        | Thấp (black-box) | Cao (1RM + Rule-based)       | ↑↑               |
| **Linh hoạt theo Goal**    | Không            | Có (1 model → nhiều goals)   | ✅               |
| **Tích hợp SePA**          | Không            | Có (Auto-Regulation)         | ✅               |
| **Xử lý Cold-start**       | Khó              | Dễ (dùng population average) | ✅               |
| **Physiological Validity** | ~60%             | ~95% (ước tính)              | ↑ 35%            |
| **Training Time**          | Baseline         | -15% (ít chiều hơn)          | ↑                |
| **Inference Time**         | Baseline         | +10% (thêm decoder)          | ↓ nhẹ            |

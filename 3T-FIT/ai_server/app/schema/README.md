# 📝 Quy trình Đánh giá & Phản hồi Sau tập (Post-Workout Evaluation Flow)

Phần này mô tả chi tiết cách hệ thống xử lý dữ liệu sau khi người dùng hoàn thành buổi tập (`evaluate_input.json`) để đưa ra đánh giá hiệu quả và độ phù hợp (`evaluate_output.json`).

Quy trình này đóng vai trò quan trọng trong việc **Cập nhật Hồ sơ Sức khỏe (Health Profile Update)** và **Tinh chỉnh Mô hình Gợi ý (Recommendation Fine-tuning)** cho các lần sau.

---

## 1. Phân tích Dữ liệu Đầu vào (Input Analysis)

Dữ liệu đầu vào (`evaluate_input.json`) bao gồm 3 thành phần chính:

1.  **User Context (`healthProfile`):** Thông tin nền tảng để chuẩn hóa dữ liệu (Tuổi, Cân nặng, Max HR dự kiến, Chấn thương).
2.  **Workout Detail (`workoutDetail`):** Chi tiết từng bài tập đã thực hiện.
    - Hỗ trợ 3 loại bài tập chính: `reps` (Tạ/Gym), `distance` (Chạy/Đạp xe), `time` (Plank/HIIT).
3.  **Device Data (`deviceData`):** Dữ liệu sinh trắc học từ thiết bị đeo (Nhịp tim, Calo).

---

## 2. Tiền xử lý & Tính toán Cường độ (Preprocessing & Feature Engineering)

Hệ thống sẽ duyệt qua từng bài tập trong `workoutDetail` và tính toán **Intensity Score (1-5)** dựa trên loại bài tập.

### A. Xử lý theo Loại bài tập (Type-Specific Logic)

#### **Loại 1: Strength / Reps (Tập tạ)**

- **Dữ liệu:** `Sets`, `Reps`, `Weight`, `BodyWeight`.
- **Công thức:**
  1.  Tính **Volume Load**: $VL = \sum (Reps \times Weight)$.
  2.  Tính **Relative Strength**: $Ratio = Weight_{max} / BodyWeight$.
  3.  **Intensity Score:** Map $Ratio$ vào thang 1-5.
      - < 0.3 BW: 1 (Very Light)
      - 0.3 - 0.5 BW: 2 (Light)
      - 0.5 - 0.8 BW: 3 (Moderate)
      - 0.8 - 1.2 BW: 4 (Hard)
      - > 1.2 BW: 5 (Max Effort)

#### **Loại 2: Cardio / Distance (Chạy bộ, Đạp xe)**

- **Dữ liệu:** `Distance`, `Duration`, `HeartRateAvg`.
- **Công thức:**
  1.  Tính **Pace**: $Pace = Duration / Distance$ (min/km).
  2.  **Intensity Score:** Dựa trên %Max Heart Rate ($HR_{zone}$).
      - Zone 1 (50-60%): 1
      - Zone 2 (60-70%): 2
      - Zone 3 (70-80%): 3
      - Zone 4 (80-90%): 4
      - Zone 5 (>90%): 5

#### **Loại 3: Conditioning / Time (HIIT, Plank)**

- **Dữ liệu:** `Duration`, `Rest`, `HeartRateAvg`.
- **Công thức:**
  1.  Tính **Work Density**: $Density = WorkTime / (WorkTime + RestTime)$.
  2.  **Intensity Score:** Kết hợp $Density$ và $HR_{zone}$ (tương tự Cardio).

### B. Chuẩn hóa Dữ liệu Sinh trắc học (Biometric Normalization)

- **Heart Rate Reserve (HRR):** Tính % nỗ lực thực tế.
  $$Effort \% = \frac{HR_{avg} - HR_{rest}}{HR_{max} - HR_{rest}}$$

---

## 3. Mô hình Đánh giá Độ phù hợp (Suitability Assessment Model)

Sau khi có `Intensity Score`, hệ thống sẽ đánh giá xem bài tập đó có **Phù hợp (`suitability`: 0-1)** với người dùng hay không.

**Input Vector cho Model:**

- `Intensity Score` (vừa tính ở bước 2).
- `Effort %` (từ Heart Rate).
- `Target Goal` (từ User Profile, ví dụ: MuscleGain vs WeightLoss).
- `Injury Status` (vùng chấn thương).

**Logic Đánh giá (Evaluation Logic):**

1.  **Kiểm tra An toàn (Safety Check - Hard Rule):**

    - Nếu bài tập tác động vào vùng chấn thương (`injuries` contains `bodyPart`) $\rightarrow$ **Suitability = 0.0**.

2.  **Đánh giá Hiệu quả (Performance Check):**
    - **Trường hợp Tốt (High Suitability > 0.8):**
      - Intensity phù hợp với Goal (ví dụ: Goal là Strength và Intensity Score >= 4).
      - Heart Rate nằm trong Target Zone.
    - **Trường hợp Cần điều chỉnh (Medium Suitability 0.4 - 0.7):**
      - Intensity thấp hơn mong đợi nhưng HR cao (Người dùng yếu hơn dự kiến).
      - Intensity cao nhưng HR thấp (Người dùng khỏe hơn dự kiến -> Cần tăng tạ).
    - **Trường hợp Kém (Low Suitability < 0.4):**
      - Bỏ tập giữa chừng (`done` = false).
      - HR vượt quá ngưỡng an toàn (>95% MaxHR) trong thời gian dài.

---

## 4. Tạo Output (Output Generation)

Tổng hợp kết quả thành file JSON `evaluate_output.json`.

**Mapping:**

- `exerciseName`: Lấy từ Input.
- `intensityScore`: Kết quả từ bước 2 (Integer 1-5).
- `suitability`: Kết quả từ bước 3 (Float 0.0 - 1.0).

**Ví dụ Luồng xử lý:**

1.  **Input:** Bench Press, 60kg, 8 reps. User 70kg. HR Avg 115.
2.  **Calc Intensity:** Weight/BW = 60/70 = 0.85 $\rightarrow$ **Score: 4 (Hard)**.
3.  **Calc Suitability:**
    - Goal: MuscleGain.
    - Score 4 là tốt cho MuscleGain.
    - HR 115 (Zone 2) là hơi thấp cho bài nặng, nhưng chấp nhận được vì là bài sức mạnh, nghỉ nhiều.
    - Không có chấn thương vai/ngực.
    - $\rightarrow$ **Suitability: 0.85**.
4.  **Output:** `{ "exerciseName": "Barbell Bench Press", "intensityScore": 4, "suitability": 0.85 }`

---

## 🚀 Quy trình Xử lý RAG & Generative Recommendation (Updated Flow)

Phần này mô tả chi tiết cách xử lý yêu cầu từ `recommend_input.json` để tạo ra kết quả `recommend_output.json` thông qua quy trình RAG và Generative AI.

### 1. Input Processing & RAG Filtering

**Input:** JSON object chứa `healthProfile`, `goals`, `exercises` (danh sách ứng viên), và `k` (số lượng bài cần chọn).

**Bước 1: RAG Selection (Retrieval-Augmented Generation)**
Hệ thống Backend thực hiện lọc sơ bộ để chọn ra `k` bài tập phù hợp nhất từ danh sách `exercises` đầu vào.

- **Query Context:** Kết hợp `Goal` (ví dụ: "MuscleGain") và `HealthStatus` (ví dụ: "Knee Injury") của user.
- **Document Corpus:** Danh sách `exercises` được gửi lên (bao gồm tên và ID).
- **Logic:**
  - Sử dụng thuật toán tìm kiếm ngữ nghĩa (Semantic Search) hoặc Rule-based filtering.
  - Ưu tiên các bài tập khớp với nhóm cơ mục tiêu (từ Goal).
  - Loại bỏ các bài tập xung đột với chấn thương (từ HealthStatus).
- **Output:** Danh sách rút gọn gồm `k` bài tập tốt nhất.

### 2. AI Model Inference (Intensity & Suitability)

Gửi danh sách `k` bài tập đã lọc vào mô hình 2 nhánh (Two-Branch Model).

- **Input:**
  - `User Vector`: Được tạo từ `healthProfile` và `goals`.
  - `Exercise Vector`: Được tạo từ metadata của từng bài tập trong danh sách `k`.
- **Model Execution:**
  - **Branch A:** Dự đoán `Predicted_RPE` (Intensity Score - thang 1-10).
  - **Branch B:** Dự đoán `Suitability_Score` (0-1).

### 3. Generative Parameter Calculation (Tính toán Thông số Tập luyện)

Đây là bước chuyển đổi từ `Predicted_RPE` (Intensity) sang các thông số cụ thể (Sets, Reps, Kg, Duration) để trả về client.

**Logic Generative:**

#### **A. Đối với bài tập Kháng lực (Resistance - Gym)**

Dựa trên `Predicted_RPE` và `Goal`:

1.  **Xác định %1RM (One Rep Max Percentage):**
    - Nếu Goal = Strength: `%1RM` cao (85-95%).
    - Nếu Goal = Hypertrophy: `%1RM` trung bình (70-80%).
    - Điều chỉnh theo `Predicted_RPE`: RPE càng cao -> %1RM càng gần giới hạn.
2.  **Tính Weight (Mức tạ):**
    - `Weight` = `User_Estimated_1RM` \* `%1RM`.
    - _(Nếu không có 1RM, dùng BodyWeight ratio mặc định)_.
3.  **Tính Reps:**
    - Dựa trên Goal (ví dụ: 5 reps cho Strength, 8-12 cho Hypertrophy).
4.  **Tính Sets:** Mặc định 3-4 sets tùy theo `Suitability_Score` (Score cao -> nhiều sets hơn).

#### **B. Đối với bài tập Cardio**

Dựa trên `Predicted_RPE` và `VO2Max`:

1.  **Tính Target Heart Rate:**
    - `Target_HR` = `RestingHR` + (`HeartRateReserve` \* `Intensity_Factor`).
2.  **Tính Duration/Distance:**
    - Dựa trên `ActivityLevel` của user (ví dụ: Level thấp -> 15-20p, Level cao -> 30-45p).

### 4. Output Formatting

Tổng hợp dữ liệu đã tính toán vào cấu trúc JSON cuối cùng (`recommend_output.json`).

- Đảm bảo tên bài tập (`name`) khớp chính xác với `exerciseName` trong input.
- Cấu trúc `sets` chứa chi tiết `reps`, `kg`, `minRest` (cho Resistance) hoặc `distance`, `duration` (cho Cardio).

```json
// Ví dụ Mapping Logic
Input Exercise: "Bench Press"
-> RAG chọn "Bench Press"
-> Model dự đoán RPE: 8.5 (High Intensity)
-> Generator tính toán:
   - Goal: MuscleGain -> Reps: 8
   - User 1RM: 80kg -> Weight: 60kg (75%)
   - Rest: 90s
-> Output JSON:
   {
     "name": "Bench Press",
     "sets": [ {"reps": 8, "kg": 60, "minRest": 90}, ... ]
   }
```

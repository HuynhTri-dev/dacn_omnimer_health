# Tổng quan về kiến trúc Model 2 Nhánh (Two-Branch Architecture)

Mô hình được xây dựng lại với 2 nhánh xử lý riêng biệt để tối ưu hóa việc dự đoán cường độ và độ phù hợp của bài tập.

## **Nhánh A: Dự đoán Cường độ (Intensity Prediction)**

### 1. Input (Đầu vào)

- **User Health Profile (Tĩnh):**
  - Dữ liệu từ database cơ bản.
  - Sức khỏe hiện tại (Current Health).
  - Mục tiêu hiện tại (Current Goals).
- **Danh sách bài tập phù hợp:**
  - Exercise: name (Tên bài tập).

### 2. Processing (Xử lý)

- Dữ liệu đi qua các lớp xử lý (Dense Layers).

### 3. Output (Đầu ra)

- **Output_Intensity:** Một con số thực đại diện cho cường độ dự đoán (ví dụ: 0.8, 1.5...).

---

## **Nhánh B: Dự đoán Nhãn (Label/Suitability Prediction)**

### 1. Input (Đầu vào)

Nhánh này nhận kết hợp các nguồn dữ liệu sau:

- **Exercise_Info (Gốc):** Thông tin chi tiết về bài tập.
- **Output_Intensity:** Kết quả từ Nhánh A.
- **Chỉ số sức khỏe:** Từ `WatchLog` (Heart Rate, Calories, Sleep, etc.).

**Cấu trúc dữ liệu Input gộp:**

Các thông số thô từ bài tập (reps, kg, km, min, minRest) sẽ được **tiền xử lý (preprocessing)** để chuyển đổi thành các **Hệ số Cường độ (Intensity Coefficients)** chuẩn hóa trước khi đưa vào model. Điều này giúp model học được bản chất cường độ thay vì các con số thô chênh lệch lớn.

```json
[
  {
    "name": "Push up",
    "intensity_features": {
      "resistance_intensity": 0.65, // Hệ số kháng lực (Tính từ: reps * kg / User_1RM)
      "cardio_intensity": 0.0, // Hệ số tim mạch (Tính từ: km / min / User_MaxPace)
      "volume_load": 0.7, // Hệ số thể tích tập (Normalized Volume)
      "rest_density": 0.3, // Mật độ nghỉ (Rest time / Total time)
      "tempo_factor": 0.5 // Hệ số tốc độ thực hiện (nếu có)
    }
  }
  // ... các bài tập khác
]
```

_Kết hợp với các chỉ số từ `WatchLog.model.ts`:_

- Vital Signs: `heartRateRest`, `heartRateAvg`, `heartRateMax`.
- Activity Data: `steps`, `distance`, `caloriesBurned`, `activeMinutes`.
- Cardio Fitness: `vo2max`.
- Recovery & Wellness: `sleepDuration`, `sleepQuality`, `stressLevel`.

### 2. Processing (Xử lý)

- **Concatenate:** Gộp tất cả các vector đặc trưng lại.
- **Dense Layers:** Đi qua các lớp xử lý riêng biệt cho nhánh B.

### 3. Output (Đầu ra)

- **Output_Suitable:** Một giá trị thực trong khoảng `0 - 1`.

---

## **Bảng Đánh giá & Hành động (Suitability Score Interpretation)**

Dựa trên `Output_Suitable`, hệ thống sẽ tự động xử lý và học cho các lần gợi ý sau:

| Score Range     | Nhãn / Đánh giá                            | Ý nghĩa                                                                                                                                      | Hành động của AI (Learning Action)                                                                                 |
| :-------------- | :----------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------- |
| **0.0 – 0.4**   | ❌ **Không hiệu quả / Không đạt mục tiêu** | Bài tập không giúp cải thiện mục tiêu chính (VD: tập vai nhưng mục tiêu tăng cơ chân). Có thể sai kỹ thuật, sai bài, hoặc cường độ quá thấp. | **Loại bỏ** hoặc thay bằng bài tương tự cùng nhóm cơ. AI học rằng bài này **không phù hợp** với mục tiêu hiện tại. |
| **0.4 – 0.6**   | ⚠️ **Tác động sai hoặc phụ trợ yếu**       | Bài tập liên quan gián tiếp, không tập trung đúng nhóm cơ/mục tiêu (VD: plank để tăng cơ tay).                                               | Có thể **giữ nếu dùng để hỗ trợ** ổn định/khởi động. AI học rằng bài này chỉ nên dùng **bổ trợ**.                  |
| **0.6 – 0.75**  | 🟡 **Đúng nhóm cơ nhưng sai cường độ**     | Đúng hướng nhưng tập quá nhẹ hoặc quá nặng → không đạt vùng hiệu quả (training zone).                                                        | AI **điều chỉnh reps/sets/weight** hoặc tempo để tối ưu vùng kích thích cơ.                                        |
| **0.75 – 0.85** | 🟢 **Hiệu quả tốt**                        | Đúng nhóm cơ, đúng mục tiêu, cường độ phù hợp. HR đạt 70–85% HRmax hoặc RPE hiệu quả.                                                        | **Giữ lại** trong chương trình. AI gán **trọng số ưu tiên cao** khi recommend.                                     |
| **0.85 – 0.95** | 🔵 **Rất hiệu quả**                        | Cường độ và kỹ thuật tối ưu, HR/RPE lý tưởng. Có cải thiện rõ rệt theo thời gian.                                                            | Bài tập **“signature”** của user – AI recommend **thường xuyên** cho chu kỳ chính.                                 |
| **0.95 – 1.00** | 🟣 **Tối ưu cá nhân hóa (Perfect Fit)**    | Hoàn toàn phù hợp thể trạng, mục tiêu, phản hồi. HR zone, RPE, recovery đều lý tưởng.                                                        | AI **“lock-in”** bài này làm **core exercise** trong kế hoạch tương lai.                                           |

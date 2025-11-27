# API v4 Documentation: Two-Branch Recommendation Engine

## Overview

API v4 giới thiệu kiến trúc **Two-Branch Neural Network** cho phép dự đoán đồng thời:

1.  **Intensity (RPE):** Mức độ gắng sức dự kiến (1-10).
2.  **Suitability:** Độ phù hợp của bài tập với trạng thái hiện tại (0-1).

Điểm khác biệt lớn nhất so với v3 là v4 yêu cầu thông tin **Real-time State** (Mood, Fatigue) để đưa ra gợi ý chính xác nhất tại thời điểm tập.

## Endpoint

`POST /recommend/v4`

## Request Structure

### 1. Health Metrics (`health_metrics`)

Thông tin cơ bản về thể trạng người dùng.

```json
{
  "age": 25,
  "height_cm": 175,
  "weight_kg": 70,
  "bmi": 22.8,
  "body_fat_percentage": 15.0,
  "resting_heart_rate": 60
}
```

### 2. User Context (`user_context`)

Thông tin nền tảng và thói quen.

```json
{
  "gender": "Male",
  "experience_level": "Intermediate",
  "activity_level": 3,
  "workout_frequency": 4,
  "injuries": ["Knee"]
}
```

### 3. Current State (`current_state`) - **NEW & CRITICAL**

Trạng thái hiện tại của người dùng. Đây là input quan trọng cho Branch B.

```json
{
  "mood": "Good", // Very Bad, Bad, Neutral, Good, Excellent
  "fatigue": "Low", // Very Low, Low, Medium, High, Very High
  "sleep_quality": "Good", // Optional
  "stress_level": "Low" // Optional
}
```

### 4. Goal Context (`goal_context`)

Mục tiêu của buổi tập này.

```json
{
  "goal_type": "MuscleGain",
  "duration_preference_min": 60
}
```

### 5. Available Exercises (`available_exercises`)

Danh sách các bài tập ứng viên để AI đánh giá.

```json
[
  {
    "id": "ex_001",
    "name": "Barbell Squat",
    "met_value": 6.0
  },
  {
    "id": "ex_002",
    "name": "Running",
    "met_value": 8.0
  }
]
```

## Response Structure

```json
{
  "recommendations": [
    {
      "exercise_id": "ex_001",
      "exercise_name": "Barbell Squat",
      "predicted_rpe": 7.5,
      "suitability_score": 0.92,
      "reason": "Matches your current mood and energy (Score: 92%)",
      "suggested_params": {
        "duration": 60
      }
    }
  ],
  "session_id": "sess_v4_demo",
  "model_version": "v4.0.0"
}
```

## Integration Guide (Frontend/Mobile)

1.  **Thu thập State:** Trước khi request, hãy hỏi người dùng: _"Hôm nay bạn cảm thấy thế nào?"_ (Mood & Fatigue).
2.  **Filter Candidates:** Lọc danh sách bài tập khả dụng ở Client (dựa trên dụng cụ có sẵn) trước khi gửi lên Server để giảm tải.
3.  **Hiển thị:**
    - Sắp xếp theo `suitability_score` giảm dần.
    - Hiển thị `predicted_rpe` để người dùng biết bài tập nặng nhẹ ra sao.
    - Nếu `suitability_score < 0.4`, cân nhắc ẩn hoặc cảnh báo người dùng.

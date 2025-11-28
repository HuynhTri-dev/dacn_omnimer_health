# API v4 Documentation: Two-Branch Recommendation Engine

## Overview

API v4 giới thiệu kiến trúc **Two-Branch Neural Network** cho phép dự đoán đồng thời:

1.  **Intensity (RPE):** Mức độ gắng sức dự kiến (1-10).
2.  **Suitability:** Độ phù hợp của bài tập với trạng thái hiện tại (0-1).

Điểm khác biệt lớn nhất so với v3 là v4 yêu cầu thông tin **Real-time State** (Mood, Fatigue) để đưa ra gợi ý chính xác nhất tại thời điểm tập.

## Endpoint

### Recommend Exercises

| Phương thức | Endpoint            | Chức năng                                                                                  |
| :---------- | :------------------ | :----------------------------------------------------------------------------------------- |
| **POST**    | `/api/ai/recommend` | Yêu cầu hệ thống gợi ý `k` bài tập phù hợp nhất dựa trên hồ sơ và mục tiêu của người dùng. |

---

**1. Request: Dữ liệu Đầu vào (IRAGUserContext)**

Dữ liệu mô tả hồ sơ sức khỏe, mục tiêu và danh sách các bài tập ứng viên có sẵn. Mục tiêu là gợi ý `k=3` bài tập.

```json
{
  "healthProfile": {
    "gender": "male",
    "age": 25,
    "height": 175,
    "weight": 70,
    "bmi": 22.86,
    "bodyFatPercentage": 15.0,
    "activityLevel": 3,
    "experienceLevel": "intermediate",
    "workoutFrequency": 4,
    "restingHeartRate": 60,
    "healthStatus": {
      "injuries": []
    }
  },
  "goals": [
    {
      "goalType": "muscle_gain",
      "targetMetric": ["hypertrophy", "strength"]
    }
  ],
  "exercises": [
    {
      "exerciseId": "ex_001",
      "exerciseName": "Barbell Bench Press"
    },
    {
      "exerciseId": "ex_002",
      "exerciseName": "Barbell Squat"
    },
    {
      "exerciseId": "ex_003",
      "exerciseName": "Treadmill Running"
    },
    {
      "exerciseId": "ex_004",
      "exerciseName": "Plank"
    },
    {
      "exerciseId": "ex_005",
      "exerciseName": "Dumbbell Curl"
    }
  ],
  "k": 3
}
```

**2. Response: Dữ liệu Đầu ra (IRAGAIResponse)**

Hệ thống đã chọn ra 3 bài tập (**Barbell Bench Press**, **Barbell Squat**, **Treadmill Running**) và tính toán các tham số cụ thể (Sets, Reps, Kg, Distance) dựa trên mục tiêu Tăng Cơ (Hypertrophy/Strength) và trình độ Trung bình (Intermediate).

---

## 🏋️ Chi tiết Gợi ý JSON

```json
{
  "exercises": [
    {
      "name": "Barbell Bench Press",
      "sets": [
        {
          "reps": 10,
          "kg": 25.0,
          "distance": null,
          "duration": null,
          "restAfterSetSeconds": 60
        },
        {
          "reps": 10,
          "kg": 25.0,
          "distance": null,
          "duration": null,
          "restAfterSetSeconds": 60
        },
        {
          "reps": 10,
          "kg": 25.0,
          "distance": null,
          "duration": null,
          "restAfterSetSeconds": 60
        },
        {
          "reps": 10,
          "kg": 25.0,
          "distance": null,
          "duration": null,
          "restAfterSetSeconds": 60
        }
      ]
    },
    {
      "name": "Barbell Squat",
      "sets": [
        {
          "reps": 10,
          "kg": 25.0,
          "distance": null,
          "duration": null,
          "restAfterSetSeconds": 60
        },
        {
          "reps": 10,
          "kg": 25.0,
          "distance": null,
          "duration": null,
          "restAfterSetSeconds": 60
        },
        {
          "reps": 10,
          "kg": 25.0,
          "distance": null,
          "duration": null,
          "restAfterSetSeconds": 60
        },
        {
          "reps": 10,
          "kg": 25.0,
          "distance": null,
          "duration": null,
          "restAfterSetSeconds": 60
        }
      ]
    },
    {
      "name": "Treadmill Running",
      "sets": [
        {
          "reps": null,
          "kg": null,
          "distance": 2.4,
          "duration": null,
          "restAfterSetSeconds": null
        }
      ]
    }
  ]
}
```

## Integration Guide (Frontend/Mobile)

1.  **Thu thập State:** Trước khi request, hãy hỏi người dùng: _"Hôm nay bạn cảm thấy thế nào?"_ (Mood & Fatigue).
2.  **Filter Candidates:** Lọc danh sách bài tập khả dụng ở Client (dựa trên dụng cụ có sẵn) trước khi gửi lên Server để giảm tải.
3.  **Hiển thị:**
    - Sắp xếp theo `suitability_score` giảm dần.
    - Hiển thị `predicted_rpe` để người dùng biết bài tập nặng nhẹ ra sao.
    - Nếu `suitability_score < 0.4`, cân nhắc ẩn hoặc cảnh báo người dùng.

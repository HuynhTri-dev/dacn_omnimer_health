# Tổng quan về đầu vào, đầu ra của model

## **Giai đoạn 1: Training mô hình chung (base model)**

Mục tiêu: xây dựng nền tảng AI biết **mapping dữ liệu sức khỏe ↔ bài tập phù hợp**.

### 1. Dữ liệu đầu vào

- **User health profile (tĩnh):**
    
    Lấy dữ liệu từ dabase dữ liệu cơ bản, sức khỏe hiện tại, mục tiêu hiện tại của người dùng
    
- **Danh sách bài tập phù hợp:**
    
    Exercise: name
    

Sử dụng phương pháp RAG để lọc ra các bài tập phù hợp với : Goal, Nhóm cơ muốn tập luyện (BodyPart, Muscle), Tình trạng cơ bản hiện tại (sung sức, bình thường, hơi mệt) để chọn ra các bài tập có độ khó và mức rep/set hợp lý. Từ phương pháp này lọc ra danh sách: 

```jsx
exercises: [{
	_id: Object.Id,
	name: "Push ups"
}]
```

⇒ Từ đó lấy danh sách exercises đưa vào input

- **Số lượng bài tập X tính theo mục tiêu: thì mình sẽ truyền vào:**
    - **Tăng cơ (hypertrophy):** chọn khoảng **5-8 bài tập** trong buổi, mỗi bài tập 2-4 hiệp (sets) với 8-12 lần (reps) mỗi hiệp, dùng mức tạ vừa tới nặng (~ 60-80% 1RM) là tối ưu. Ví dụ: 3 bài lớn (multi-joint) + 2-3 bài nhỏ (isolation). Nhiều nghiên cứu đề xuất rằng khối lượng huấn luyện (sets × reps × tải) là biến số quan trọng. [PMC+1](https://pmc.ncbi.nlm.nih.gov/articles/PMC6950543/?utm_source=chatgpt.com)
    - **Tăng sức mạnh (strength):** nên chọn khoảng **4-6 bài tập** vì bài tập nặng, mỗi bài 2-3 hiệp, mỗi hiệp khoảng 1-5 lần với tải rất nặng (~ 80-100% 1RM) sẽ kích thích tốt. [PMC+1](https://pmc.ncbi.nlm.nih.gov/articles/PMC7927075/?utm_source=chatgpt.com)
    - **Sức bền cơ bản / giảm mỡ / sức khỏe tổng thể:** có thể sử dụng **5-8 bài tập** nhẹ hơn, mỗi bài có thể 12-20 lần hoặc hơn, tập với tải nhẹ-vừa và/hoặc nhiều động tác kết hợp (compound + body-weight) để tăng nhịp tim và tiêu hao năng lượng. Ví dụ: 1-2 bài khởi động, 4-5 bài chính, 1 bài giãn cơ kết thúc.

```json
{
  healthProfile: {
    gender: 'male',
    age: 0,
    height: 175,
    weight: 68,
    whr: undefined,
    bmi: 22.2,
    bmr: 1839.18,
    bodyFatPercentage: 12.87,
    muscleMass: 33.54,
    maxWeightLifted: 80,
    activityLevel: 4,
    experienceLevel: 'Intermediate',
    workoutFrequency: 4,
    restingHeartRate: 70,
    healthStatus: {
      knownConditions: [Array],
      painLocations: [Array],
      jointIssues: [Array],
      injuries: [Array],
      abnormalities: [Array],
      notes: 'Feels tired after long workdays, currently on mild exercise routine.'
    }
  },
  goals: [ { goalType: 'WeightLoss', targetMetric: [Array] } ],
  exercises: [
    { exerciseName: '' }
  ]
}
```

### 2. Dữ liệu đầu ra

- Top x các name exercise có nhãn sutitable cao nhất và cường độ luyện tập của nó.

```json
"exercises": {
	[
		{
			"name": "Push up",
			"sets": [{ // Số lượng bài bao nhiêu set mảng có bao nhiêu
					"reps": 12,
					"kg": 20,
					"km": 12, // Đối với các bài liên quan về chạy, đạp xe
					"min": 2, // Đối với bài về cardio thì có
					"minRest": 3
			},
			{
					"reps": 12,
					"kg": 20,
					"km": 12, // Đối với các bài liên quan về chạy, đạp xe
					"min": 2, // Đối với bài về cardio thì có
					"minRest": 3 
			}],
		},
		{
			...
		}
		...
	],
	"suitabilityScore": 0.92,
	"predictedAvgHR": 115, 
	"predictedPeakHR": 135
}
```

## **Giai đoạn 2: Training cá nhân hóa (personalization)**

Mục tiêu: mô hình học theo **thói quen & feedback cá nhân**.

### 1. Dữ liệu thêm

- WatchLog
- Workout

⇒ Lấy và và xử lý để có thể mapping các dữ liệu sức khỏe từ apple watch với các bài tập trong workout. Ví dụ Push up có nhịp tim trung bình, nhịp tim tối đa bao nhiêu,…. Sau đó xử lý đối với các bài tập được dự đoán là có suitable thấp dưới **0,4 thì không cho tập lại**, **từ 0,4 - 0,9 thì cải thiện** các thông số cường độ: Sets/Reps/Weight/TimeRestEachSet, Sets/Time_m/TimeRestEachSet, Distance_km, Duration. Nếu **suitable = 1 thì block lại.**

### 2. Mục tiêu

Model AI có thể gợi ý riêng biệt cho từng userId.

### 3. Inference

- Với user mới (cold-start): dùng **giai đoạn 1**.
- Với user lâu năm: dùng **giai đoạn 2 + embedding** để gợi ý chuẩn hơn.

```json
(1) Input Data
 ├── Health Profile (BMI, HR, goals, age, gender, ...)
 ├── Workout History (bài tập, intensity, duration)
 ├── WatchLog (HR trend, calories, fatigue signals)
 └── Feedback (user rating, perceived fatigue)

        ↓

(2) Recommendation Engine (2 tầng)
 ├── Tầng 1: RAG / Rule-based Filtering
 │     → lọc danh sách bài tập phù hợp với mục tiêu, nhóm cơ, equipment
 │
 └── Tầng 2: ML Model (DNN | Neural Ranking)
       → predict “suitability_score”, “expected_heart_rate”, “expected_calories”
       → gợi ý top 5 bài tập có suitability cao nhất

        ↓

(3) Execution
 → người dùng thực hiện bài tập, Watch ghi dữ liệu thực tế

        ↓

(4) Evaluation
 ├── Tính toán “actual vs predicted” (HR, calories, hiệu quả)
 ├── Ghi nhận Feedback người dùng
 └── Sinh ra “fitness_score” cho mỗi session

        ↓

(5) Feedback Loop (Learning phase)
 ├── Cập nhật embedding / vector RAG
 ├── Re-train / fine-tune ML model định kỳ
 └── Lưu kết quả vào Personal Learning Profile

```
### **Hybrid Recommendation Model (Kết hợp RAG + ML)**

Kết hợp 2 tầng:

- **Tầng 1 (RAG / Rule-based Filtering):**
    
    Dùng dữ liệu bài tập (exercise dataset) và thông tin health profile để **lọc sơ bộ** các bài tập hợp lý (theo mục tiêu, muscle target, trạng thái sức khỏe, equipment,…).
    
    → Kết quả: danh sách “có khả năng phù hợp”. gồm
    
    ```json
    exercisesName: [string]
    ```
    
- **Tầng 2 (ML Model - Regression + Ranking):**
    
    Mô hình học sâu hoặc hồi quy (regression / neural ranking) để **ước lượng suitabilityScore**, **predict HR**, **calories** dựa trên dữ liệu tập luyện quá khứ (`workout_id`, `exercise_name`, `intensity`, `fatigue`, `calories`, `effectiveness`...).
    

> => Tầng 1 giống “retrieval” trong RAG, tầng 2 là “ranking/prediction”.

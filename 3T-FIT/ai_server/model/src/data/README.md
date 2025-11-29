# Nội dung cho file README.md

Bảng dưới đây mô tả chi tiết ý nghĩa các trường dữ liệu trong bộ dữ liệu theo dõi tập luyện (Gym Exercise Tracking).

| Tên trường (Field Name) | Ý nghĩa (Description)       | Loại dữ liệu    | Ghi chú quan trọng                                                       |
| :---------------------- | :-------------------------- | :-------------- | :----------------------------------------------------------------------- |
| **exercise_name**       | Tên bài tập                 | Text            | Ví dụ: Deadlift, Bench Press, Treadmill.                                 |
| **duration_min**        | Thời gian thực hiện bài tập | Số (phút)       | Thời gian tập luyện thực tế cho bài tập này.                             |
| **avg_hr**              | Nhịp tim trung bình         | Số (bpm)        | Chỉ số tim mạch trung bình trong lúc tập.                                |
| **max_hr**              | Nhịp tim tối đa             | Số (bpm)        | Cường độ cao nhất đạt được.                                              |
| **calories**            | Năng lượng tiêu thụ         | Số (kcal)       | Lượng calo đốt cháy.                                                     |
| **fatigue**             | Mức độ mệt mỏi              | Số (Thang 1-5)  | Chỉ số cảm nhận chủ quan của người tập.                                  |
| **effort**              | Mức độ nỗ lực               | Số (Thang 1-5)  | Đánh giá mức độ cố gắng bỏ ra.                                           |
| **mood**                | Tâm trạng                   | Số (Thang 1-5)) | Cảm xúc sau khi tập.                                                     |
| **suitability_x**       | Độ phù hợp (Label)          | Số (0.0 - 1.0)  | Đây có thể là nhãn mục tiêu (Target Label) cho mô hình AI gợi ý bài tập. |
| **age**                 | Tuổi                        | Số              | Thông tin nhân khẩu học.                                                 |
| **height_m**            | Chiều cao                   | Số (mét)        | Thông tin chỉ số cơ thể.                                                 |
| **weight_kg**           | Cân nặng                    | Số (kg)         | Thông tin chỉ số cơ thể.                                                 |
| **bmi**                 | Chỉ số khối cơ thể          | Số              | Tính toán từ chiều cao và cân nặng.                                      |
| **fat_percentage**      | Tỷ lệ mỡ cơ thể             | Số (%)          | Chỉ số sức khỏe quan trọng.                                              |
| **resting_heartrate**   | Nhịp tim nghỉ               | Số (bpm)        | Chỉ số sức bền tim mạch nền tảng.                                        |
| **experience_level**    | Kinh nghiệm tập luyện       | Số (Cấp độ)     | 1: Mới, 2: Trung bình, 3: Nâng cao.                                      |
| **workout_frequency**   | Tần suất tập luyện          | Số (buổi/tuần)  | Số ngày tập trong tuần.                                                  |
| **workout_type**        | Loại hình tập luyện         | Text            | Cardio, Strength (Sức mạnh), HIIT, v.v.                                  |
| **location**            | Địa điểm                    | Text            | Home,Gym,Outdoor,Pool, Volleyball Court                                  |
| **gender**              | Giới tính                   | Số              | 0/1                                                                      |
| **session_duration**    | Thời lượng cả buổi tập      | Số (phút)       | Tổng thời gian của phiên tập (có thể bao gồm nhiều bài).                 |
| **estimated_1rm**       | Ước tính 1RM                | Số (kg)         | Sức mạnh tối đa nâng được 1 lần (One Rep Max). Quan trọng cho tập tạ.    |
| **pace**                | Tốc độ                      | Số              | Dùng cho các bài Cardio (chạy bộ, đạp xe).                               |
| **duration_capacity**   | Khả năng duy trì            | Số              | Chỉ số thể lực liên quan đến sức bền.                                    |
| **rest_period**         | Thời gian nghỉ              | Số (giây/phút)  | Thời gian nghỉ giữa các hiệp (set).                                      |
| **intensity_score**     | Điểm cường độ               | Số              | Điểm tổng hợp đánh giá độ nặng của bài tập.                              |

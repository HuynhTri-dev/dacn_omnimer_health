# Phân Tích Dữ Liệu Training Model V3

Thư mục này chứa các biểu đồ phân tích dữ liệu training cho mô hình V3 Enhanced. Dưới đây là ý nghĩa và phân tích của từng biểu đồ:

## 1. Phân Phối Biến Mục Tiêu (`01_target_distributions.png`)

- **Estimated 1RM**: Cho thấy sự phân bố sức mạnh. Phân phối chuẩn là lý tưởng.
- **Suitability Score**: Điểm số phù hợp (0-1). Phân phối lệch phải cho thấy dữ liệu tập trung vào các bài tập phù hợp.
- **Readiness Factor**: Hệ số sẵn sàng.
- **BMI**: Chỉ số khối cơ thể.

## 2. Phân Tích SePA (`02_sepa_distributions.png`)

- Thể hiện sự cân bằng của các yếu tố Sleep, Psychology, Activity (Mood, Fatigue, Effort).
- Sự phân bố đồng đều giúp mô hình học tốt hơn trên mọi trạng thái của người dùng.

## 3. Ma Trận Tương Quan (`03_correlation_heatmap.png`)

- Hiển thị mối quan hệ giữa các đặc trưng.
- Các ô màu đỏ đậm/xanh đậm thể hiện mối tương quan mạnh (dương/âm).
- Quan trọng để xác định các yếu tố ảnh hưởng nhất đến 1RM.

## 4. Mối Quan Hệ 1RM (`04_1rm_relationships.png`)

- **Age vs 1RM**: Xu hướng thay đổi sức mạnh theo độ tuổi.
- **Weight/BMI vs 1RM**: Mối quan hệ giữa kích thước cơ thể và sức mạnh.
- **Experience vs 1RM**: Tác động của kinh nghiệm tập luyện.

## 5. Phân Tích Giới Tính (`05_gender_analysis.png`)

- So sánh sức mạnh và số lượng mẫu giữa Nam và Nữ.

## 6. Phân Tích Kinh Nghiệm (`06_experience_analysis.png`)

- Phân phối sức mạnh theo từng mức độ kinh nghiệm (Beginner -> Expert).

## 7. Lịch Sử Training (`07_training_history.png`)

- Biểu đồ Loss và Metrics qua các epochs.
- Giúp đánh giá quá trình hội tụ của mô hình (có bị overfitting/underfitting không).

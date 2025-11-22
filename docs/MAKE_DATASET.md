# PHÁT TRIỂN DATASET

## Các yếu tố ảnh hưởng tới số lượng dataset

- Độ phức tạp của mô hình:
  - Mô hình càng phức tạp (nhiều lớp, nhiều tham số), càng cần nhiều dữ liệu để tránh overfitting.
  - Ví dụ: Mô hình mạng nơ-ron sâu (deep learning) cần hàng chục nghìn đến hàng triệu mẫu.
- Số lượng đặc trưng (features):

  - Nếu bạn có nhiều cột dữ liệu (ví dụ: >20 features), bạn cần nhiều mẫu để mô hình học được mối quan hệ giữa các biến.

- Chất lượng dữ liệu:
  - Dữ liệu sạch, đầy đủ, không bị nhiễu sẽ giúp mô hình học tốt hơn với ít dữ liệu hơn.
- Tỷ lệ train/test/validation:
  - Thường dùng 70% train, 15% validation, 15% test. Tập test nên chỉ gồm dữ liệu thực tế để đánh giá đúng khả năng tổng quát hóa.

## Cách tạo thêm dữ liệu từ các nguồn có sẵn

- Tận dụng các dataset y tế trên Kaggle: Bạn có thể lấy các bộ dữ liệu có cấu trúc tương tự như dataset của bạn, sau đó áp dụng các công thức hoặc quy tắc để điều chỉnh cho phù hợp với mục tiêu huấn luyện.

- Kỹ thuật tổng hợp dữ liệu (Synthetic Data):
  - Data Augmentation: Áp dụng các biến đổi như thêm nhiễu, thay đổi giá trị trong ngưỡng cho phép, hoán đổi cột, v.v.
  - Generative Adversarial Networks (GANs): Dùng mạng đối kháng để tạo dữ liệu mới có đặc điểm thống kê giống dữ liệu thật.
  - Rule-based synthesis: Tạo dữ liệu bằng cách áp dụng các công thức y học, logic chuyên môn hoặc mô phỏng các tình huống lâm sàng.

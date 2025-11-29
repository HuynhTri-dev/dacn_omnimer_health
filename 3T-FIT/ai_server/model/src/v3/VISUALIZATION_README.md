# Hướng Dẫn Sử Dụng Visualization Script

## Tổng Quan

Script `visualize_training_data.py` được tạo ra để phân tích và vẽ biểu đồ cho dữ liệu training của model V3.

## Cách Sử Dụng

### 1. Chạy Script Visualization

```bash
python visualize_training_data.py --data_dir ./data --output_dir ./visualizations
```

### 2. Các Tham Số

- `--data_dir`: Thư mục chứa dữ liệu training (mặc định: `./data`)
- `--output_dir`: Thư mục lưu các biểu đồ (mặc định: `./visualizations`)

## Các Biểu Đồ Được Tạo

Script sẽ tạo ra 6 biểu đồ phân tích:

### 1. `01_target_distributions.png`

- Phân phối của Estimated 1RM
- Phân phối của Suitability Score
- Phân phối của Readiness Factor
- Phân phối của BMI

### 2. `02_sepa_distributions.png`

- Phân phối Mood (1-5)
- Phân phối Fatigue (1-5)
- Phân phối Effort (1-5)

### 3. `03_correlation_heatmap.png`

- Ma trận tương quan giữa các features
- Giúp xác định mối quan hệ giữa các biến

### 4. `04_1rm_relationships.png`

- Mối quan hệ giữa Age và 1RM
- Mối quan hệ giữa Weight và 1RM
- Mối quan hệ giữa BMI và 1RM
- Mối quan hệ giữa Experience Level và 1RM
- Mối quan hệ giữa Workout Frequency và 1RM
- Mối quan hệ giữa Readiness Factor và 1RM

### 5. `05_gender_analysis.png`

- Phân phối 1RM theo giới tính
- Số lượng mẫu theo giới tính

### 6. `06_experience_analysis.png`

- Phân phối 1RM theo mức độ kinh nghiệm

## Ví Dụ

```bash
# Phân tích dữ liệu từ thư mục data
python visualize_training_data.py

# Chỉ định thư mục output cụ thể
python visualize_training_data.py --output_dir ./my_visualizations

# Sử dụng dữ liệu từ thư mục khác
python visualize_training_data.py --data_dir ../other_data --output_dir ./analysis
```

## Lưu Ý

- Script yêu cầu các thư viện: `pandas`, `numpy`, `matplotlib`, `seaborn`
- Dữ liệu đầu vào phải ở định dạng Excel (.xlsx)
- Các biểu đồ được lưu với độ phân giải cao (300 DPI)

## Về Vấn Đề Sets Range

Trong file `train_v3_enhanced.py`, `sets_range` được định nghĩa là `(1, 5)` cho tất cả các mục tiêu workout:

```python
WORKOUT_GOAL_MAPPING = {
    'strength': {
        'sets_range': (1, 5),  # 1-5 sets
        ...
    },
    'hypertrophy': {
        'sets_range': (1, 5),  # 1-5 sets
        ...
    },
    ...
}
```

Tuy nhiên, trong `generate_workout_plan.py`, chúng ta đã thêm logic để clamp giá trị về `(2, 4)` để phù hợp với yêu cầu của bạn:

```python
# Sets: > 1 and < 5 => [2, 4]
raw_sets = rec_data['sets']['recommended']
num_sets = int(max(2, min(4, round(raw_sets))))
```

Điều này đảm bảo rằng số sets luôn nằm trong khoảng 2-4, phù hợp với tiêu chuẩn phòng gym.

## Phân Tích Chi Tiết Dữ Liệu

Dưới đây là phân tích chi tiết về các thông tin chiết xuất được từ các biểu đồ trong thư mục `model/visualizations`:

### 1. Phân Phối Biến Mục Tiêu (`01_target_distributions.png`)

Biểu đồ này cung cấp cái nhìn tổng quan về các biến số quan trọng nhất mà mô hình cần dự đoán:

- **Estimated 1RM**: Cho thấy sự phân bố sức mạnh của người dùng trong tập dữ liệu. Một phân phối chuẩn (hình chuông) là lý tưởng, cho thấy dữ liệu bao gồm cả người mới tập (1RM thấp), trung bình và vận động viên (1RM cao).
- **Suitability Score**: Điểm số phù hợp (0-1). Phân phối lệch phải (nhiều giá trị cao) cho thấy đa số bài tập được gán là phù hợp, giúp mô hình học được các mẫu bài tập tốt.
- **Readiness Factor**: Hệ số sẵn sàng tập luyện. Giá trị trung bình thường xoay quanh 1.0. Nếu phân phối lệch trái (nhiều giá trị thấp), dữ liệu có thể chứa nhiều mẫu người dùng đang mệt mỏi.
- **BMI**: Chỉ số khối cơ thể. Giúp xác định xem tập dữ liệu có đại diện cho nhiều loại hình thể khác nhau hay không.

### 2. Phân Tích SePA (`02_sepa_distributions.png`)

Biểu đồ này thể hiện sự cân bằng của các yếu tố Sleep, Psychology, Activity:

- **Mood, Fatigue, Effort**: Các thang điểm từ 1-5.
- **Ý nghĩa**: Sự phân bố đồng đều giữa các mức 1-5 là rất quan trọng để mô hình không bị thiên kiến (bias). Ví dụ: nếu dữ liệu chỉ toàn người có Mood tốt (4-5), mô hình sẽ dự đoán kém với người đang stress (Mood 1-2).

### 3. Ma Trận Tương Quan (`03_correlation_heatmap.png`)

Đây là biểu đồ quan trọng nhất để hiểu mối quan hệ giữa các đặc trưng (features):

- **Mối tương quan dương mạnh**: Thường thấy giữa `weight_kg` và `estimated_1rm` (người nặng cân thường mạnh hơn), hoặc `bmi` và `weight_kg`.
- **Mối tương quan âm**: Có thể thấy giữa `fatigue_numeric` và `readiness_factor` (càng mệt mỏi thì độ sẵn sàng càng thấp).
- **Feature Selection**: Các biến có tương quan quá thấp với `estimated_1rm` (gần 0) có thể không đóng góp nhiều cho việc dự đoán sức mạnh.

### 4. Mối Quan Hệ 1RM (`04_1rm_relationships.png`)

Các biểu đồ scatter plot này kiểm chứng các giả định thực tế:

- **Age vs 1RM**: Thường thấy đường xu hướng giảm nhẹ hoặc parabol (đỉnh cao sức mạnh ở độ tuổi 20-30).
- **Weight/BMI vs 1RM**: Xu hướng tăng rõ rệt. Người có khối lượng cơ thể lớn thường có 1RM cao hơn tuyệt đối.
- **Experience vs 1RM**: Xu hướng tăng mạnh. Kinh nghiệm tập luyện là yếu tố dự báo chính xác nhất cho sức mạnh.

### 5. Phân Tích Giới Tính (`05_gender_analysis.png`)

- **Boxplot 1RM**: So sánh sức mạnh trung bình giữa Nam và Nữ. Thông thường, trung vị của Nam sẽ cao hơn Nữ do đặc điểm sinh học.
- **Sample Count**: Kiểm tra sự cân bằng dữ liệu. Nếu chênh lệch quá lớn (ví dụ 90% Nam), mô hình cần kỹ thuật cân bằng (oversampling/undersampling) hoặc loss weighting.

### 6. Phân Tích Kinh Nghiệm (`06_experience_analysis.png`)

- **Boxplot theo Level**: Cho thấy sự phân tách rõ ràng giữa các nhóm Beginner, Intermediate, Advanced.
- **Ý nghĩa**: Nếu các hộp (box) chồng lấn quá nhiều, nghĩa là đặc trưng `experience_level` chưa phân loại tốt sức mạnh, hoặc dữ liệu gán nhãn chưa chuẩn. Một mô hình tốt cần thấy sự tăng tiến rõ rệt về 1RM khi level tăng.

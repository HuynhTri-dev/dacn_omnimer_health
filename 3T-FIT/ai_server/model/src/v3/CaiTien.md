● 🎯 Tóm tắt: Giải thích chi tiết 4 bước cải tiến

Tôi đã tạo 3 script Python chi tiết với giải thích đầy đủ cho từng bước cải tiến:

---

1. 🧹 Làm sạch dữ liệu: Loại bỏ giá trị 1RM gần bằng 0

Vấn đề hiện tại:

- Dataset có 200 samples với 1RM từ 0.0 - 224.0 kg
- MAPE (Mean Absolute Percentage Error) = 6.15×10¹⁸% - vô nghĩa do chia cho giá trị gần 0
- R² = -0.356 - mô hình dự đoán tệ hơn trung bình

Giải pháp trong data_cleaning.py:

- Xóa giá trị zero và âm (loại bỏ các mẫu không hợp lệ)
- Loại bỏ outliers bằng IQR method (Q1-1.5×IQR, Q3+1.5×IQR)
- Validate domain knowledge:
  - 1RM tối thiểu = 15-20kg (người lớn)
  - 1RM tối đa = 300kg (người nâng cao)
  - Kiểm tra tương quan với cân nặng và kinh nghiệm
- Xử lý missing values bằng median (chống outliers)
- Phân tích chất lượng data với visualizations

---

2. 🏗️ Tách mô hình: Huấn luyện mô hình riêng cho mỗi tác vụ

Vấn đề với Multi-task Learning:

- Interference giữa các tác vụ: Mô hình cố gắng tối ưu 3 đầu ra cùng lúc
- Khác biệt độ khó: 1RM (khó) vs Readiness (dễ) vs Suitability (trung bình)
- Kiến trúc không tối ưu: Cùng một kiến trúc cho 3 tác vụ khác nhau

Giải pháp trong specialized_models.py:

- Specialized1RMModel:
  - Feature extraction riêng cho 1RM (256 → 128 → 64)
  - Branch architecture: Body composition + Experience + SePA
  - Attention mechanism cho features quan trọng
  - Residual connections cho training stability
- SpecializedSuitabilityModel:
  - Enhanced MLP với GeLU activation
  - Auxiliary classifiers: Difficulty + Goal types
  - Batch normalization và dropout tối ưu
- SpecializedReadinessModel:
  - SePA-focused network (mood, fatigue, effort)
  - Physical factors network riêng biệt
  - Fusion layer kết hợp hai luồng thông tin
- Training pipeline chuyên biệt cho từng mô hình với hyperparameters riêng

---

3. 📈 Biến đổi mục tiêu: Áp dụng Log Transform cho 1RM

Vấn đề phân phối 1RM:

- Skewed distribution: Skewness = 1.264 (phân phối lệch phải)
- Heteroscedasticity: Phương sai tăng theo giá trị 1RM
- Non-linear relationships: 1RM có quan hệ non-linear với các features

Giải pháp trong target_transformation.py:

- Log Transformation Options:
  - log1p(y) = log(1 + y): Chuẩn nhất
  - safe_log(y) = log(y + constant): Tránh log(0)
  - log(y): Với clipping giá trị âm
- Power Transformation:
  - Box-Cox: Tìm λ tối ưu để chuẩn hóa phân phối
  - Yeo-Johnson: Xử lý giá trị âm và zero
  - Square Root: √y cho giảm skewness
- Advanced Methods:
  - Quantile Transformation: Chuyển thành phân phối chuẩn/uniform
  - Domain-Specific Transform: Dựa trên kiến thức exercise physiology
  - Auto-transformation: Tự động chọn phương pháp tốt nhất

Evaluation Framework:

- Test tất cả transformations với Ridge Regression baseline
- Metrics: MAE, RMSE, R², MAPE
- Automatic selection: Chọn transformation có MAPE thấp nhất
- Visual comparison: Histograms, Q-Q plots, metric comparisons

---

4. 🔧 Cải tiến kiến trúc: Tăng độ phức tạp cho 1RM

Các kỹ thuật đã implement:

A. Feature Engineering Nâng Cao:

# Body composition features

df['bmi_category'] = pd.cut(df['bmi'], bins=[0, 18.5, 25, 30, 100])

# Experience interactions

df['experience_intensity'] = df['experience_level'] _ df['workout_frequency']
df['age_experience_interaction'] = df['age'] _ df['experience_level']

# Strength potential

df['strength_potential'] = df['weight_kg'] _ (1 + df['experience_level'] _ 0.1)

B. Ensemble Methods:

- RandomForest (100 trees)
- GradientBoosting (100 estimators)
- XGBoost với regularization
- LightGBM với leaf-wise growth
- Best model selection tự động

C. Neural Network Enhancements:

- Layer Normalization: Giảm internal covariate shift
- GeLU Activation: Smooth hơn ReLU
- Residual Connections: Giúp training deeper networks
- Dropout scheduling: Dropout giảm dần theo epochs
- Gradient Clipping: Ngăn exploding gradients

D. Training Optimizations:

- AdamW optimizer với weight decay
- Learning Rate Scheduling: ReduceLROnPlateau
- Early Stopping: Dừng khi validation không cải thiện
- Batch Normalization: Stabilize training dynamics

---

🚀 Cách sử dụng các script:

1. Chạy Data Cleaning:

cd ai_server/model/src/v3
python data_cleaning.py --input ./data/enhanced_gym_member_exercise_tracking_10k.xlsx

2. Tìm Best Target Transformation:

python target_transformation.py --data ./data/test_dataset.xlsx --target estimated_1rm --visualize

3. Huấn luyện Models Chuyên biệt:

python specialized_models.py --data ./enhanced_gym_member_exercise_tracking_10k_cleaned.xlsx --output
./specialized_models

4. Deploy với Best Configuration:

# Áp dụng transformation tốt nhất

transformer = TargetTransformer()
y_transformed, method, params = transformer.apply_best_transformation(y_1rm, X_train)

# Huấn luyện với architecture mới

model = Specialized1RMModel(input_dim=len(features))

# ... training loop ...

📊 Kết quả kỳ vọng:

1. 1RM Prediction:


    - MAE giảm từ 40.3kg → dưới 15kg
    - R² cải thiện từ -0.356 → trên 0.6
    - MAPE từ vô hạn → dưới 20%

2. Suitability Prediction:


    - Giữ vững accuracy >95%
    - Cải thiện R² từ âm → dương

3. Readiness Prediction:


    - Duy trì accuracy ~100%
    - Cải thiện R² từ 0.012 → trên 0.3

Các script này cung cấp complete framework để cải tiến từng bước một cách hệ thống và có đo lường rõ
ràng! 🎉

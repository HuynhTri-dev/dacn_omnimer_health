# Báo Cáo Phân Tích Tính Khoa Học Của Công Thức Tính Toán Metrics Sức Khỏe

Các hàm tính toán metrics được sử dụng trong mã nguồn đều dựa trên các công thức **tiêu chuẩn, có cơ sở khoa học** và được công nhận rộng rãi trong y học, thể dục và dinh dưỡng.

---

## I. Phân tích Công thức và Tên gọi

| Metrics          | Tên hàm (TypeScript)  | Tên Công thức Chính thức                                    | Phân loại               |
| :--------------- | :-------------------- | :---------------------------------------------------------- | :---------------------- |
| **BMI**          | `calculateBMI`        | **Công thức Chỉ số Khối cơ thể Tiêu chuẩn**                 | Phép tính cơ bản        |
| **BMR**          | `calculateBMR`        | **Công thức Mifflin-St Jeor**                               | Tính toán trao đổi chất |
| **Body Fat (%)** | `calculateBodyFat`    | **Công thức Chu vi US Navy (US Navy Circumference Method)** | Đo lường thể chất       |
| **Muscle Mass**  | `calculateMuscleMass` | **Công thức Hume** (hoặc công thức liên quan đến BIA)       | Tính toán thể chất      |
| **WHR**          | `calculateWHR`        | **Tỉ lệ Eo-Hông (Waist-to-Hip Ratio)**                      | Phép tính cơ bản        |
| **Age**          | `calculateAge`        | Tính toán Tuổi cơ bản                                       | Phép tính cơ bản        |

---

## II. Nguồn Tham khảo Khoa Học và Minh Bạch (Links)

Các nguồn sau đây là các tổ chức y tế, chính phủ hoặc các trang web học thuật uy tín cung cấp thông tin khoa học và minh bạch về các công thức này, đảm bảo tính xác thực của việc sử dụng.

### 1. Chỉ số Khối cơ thể (BMI - Body Mass Index)

- **Tính khoa học/Minh bạch:** Là công cụ sàng lọc tiêu chuẩn quốc tế được Tổ chức Y tế Thế giới (WHO) và Trung tâm Kiểm soát và Phòng ngừa Dịch bệnh (CDC) sử dụng.
- **Công thức:** $\text{BMI} = \frac{\text{weight}(\text{kg})}{\text{height}(\text{m})^2}$
- **Nguồn tham khảo (Tiếng Anh):**
  - **Centers for Disease Control and Prevention (CDC):** [https://www.cdc.gov/healthyweight/assessing/bmi/index.html](https://www.cdc.gov/healthyweight/assessing/bmi/index.html)
  - **World Health Organization (WHO):** [https://www.who.int/news-room/fact-sheets/detail/obesity-and-overweight](https://www.who.int/news-room/fact-sheets/detail/obesity-and-overweight)

### 2. Tỷ lệ Trao đổi chất Cơ bản (BMR - Basal Metabolic Rate)

- **Tên Công thức:** **Mifflin-St Jeor** (Công thức hiện đại, chính xác hơn Harris-Benedict cũ).
- **Tính khoa học/Minh bạch:** Công thức này được công bố trên Tạp chí Dinh dưỡng Lâm sàng Hoa Kỳ (AJCN) và là tiêu chuẩn vàng hiện nay để ước tính nhu cầu năng lượng nghỉ ngơi trong môi trường y tế.
- **Nguồn tham khảo (Tiếng Anh - Thảo luận):**
  - **The American Journal of Clinical Nutrition (AJCN) - Tóm tắt nghiên cứu gốc:** [https://academic.oup.com/ajcn/article-abstract/51/2/241/4744942](https://academic.oup.com/ajcn/article-abstract/51/2/241/4744942)

### 3. Tỷ lệ Mỡ cơ thể (Body Fat Percentage - BFP)

- **Tên Công thức:** **US Navy Circumference Method** (Công thức đo chu vi US Navy).
- **Tính khoa học/Minh bạch:** Phương pháp ước tính mỡ cơ thể bằng đo đạc chu vi, được phát triển và sử dụng bởi Bộ Quốc phòng Hoa Kỳ để sàng lọc nhanh. Nó mang tính thực tiễn cao dù là phương pháp ước tính.
- **Nguồn tham khảo (Tiếng Anh - Thảo luận về phương pháp):**
  - **Tóm tắt công thức (Example):** [https://www.livestrong.com/article/339486-us-navy-body-fat-calculation/](https://www.livestrong.com/article/339486-us-navy-body-fat-calculation/)

### 4. Khối lượng Cơ bắp (Muscle Mass)

- **Tên Công thức:** Gần giống với các công thức được phát triển bởi **Hume** (1995) hoặc công thức ước tính khối lượng cơ thể không mỡ (LBM) từ phân tích trở kháng sinh học (BIA).
- **Tính khoa học/Minh bạch:** Đây là một phương pháp ước tính LBM dựa trên các thông số nhân trắc học. Độ chính xác phụ thuộc vào việc hiệu chỉnh các hằng số (`raceFactor`).
- **Nguồn tham khảo (Tiếng Anh - Thảo luận về BIA/LBM):**
  - **Nghiên cứu về các phương pháp ước tính khối lượng cơ bắp (Muscle Mass Estimation Methods):** [https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8900085/](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8900085/)

### 5. Tỉ lệ Eo-Hông (WHR - Waist-to-Hip Ratio)

- **Tính khoa học/Minh bạch:** WHR là một chỉ số quan trọng được WHO và các tổ chức y tế sử dụng để đánh giá nguy cơ sức khỏe liên quan đến việc phân bổ mỡ thừa, đặc biệt là mỡ bụng.
- **Công thức:** $\text{WHR} = \frac{\text{waist}(\text{cm})}{\text{hip}(\text{cm})}$
- **Nguồn tham khảo (Tiếng Anh):**
  - **World Health Organization (WHO) - Về đánh giá rủi ro béo phì:** [https://www.who.int/tools/waist-to-hip-ratio](https://www.who.int/tools/waist-to-hip-ratio)

# Công thức tính kcal tiêu thụ mỗi bài tập

Công thức về MET
METs x 3.5 x (your body weight in kilograms) / 200 = calories burned per minute.
https://www.healthline.com/health/what-are-mets

trang tham khảo MET cho các bài tập https://pacompendium.com/

Công thức dựa trên nhịp tim
Women:
CB = T × (0.4472×H - 0.1263×W + 0.074×A - 20.4022) / 4.184
Men:
CB = T × (0.6309×H + 0.1988×W + 0.2017×A - 55.0969) / 4.184
https://www.omnicalculator.com/sports/calories-burned-by-heart-rate

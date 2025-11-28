# Báo Cáo Phân Tích Công Thức Tính Calo Tiêu Thụ và Cường độ Tập luyện

Các công thức được sử dụng để ước tính Calo tiêu thụ (Calories Burned - CB) và xác định Cường độ tập luyện (Intensity) đều dựa trên các nghiên cứu khoa học được công nhận.

---

## I. Công thức Tính Calo Tiêu thụ (Calories Burned - CB)

Có hai phương pháp chính được khoa học chấp nhận để ước tính lượng calo tiêu thụ trong quá trình tập luyện:

### 1. Phương pháp dựa trên METs (Tương đương Trao đổi chất)

Đây là phương pháp chuẩn mực, thường được sử dụng khi bạn biết loại hoạt động và thời gian thực hiện.

#### A. Công thức Chuẩn (Standard METs Formula)

Công thức này chuyển đổi lượng oxy tiêu thụ (dựa trên METs) thành Calo tiêu thụ.

$$
\text{CB} (\text{kcal/phút}) = \frac{\text{METs} \times 3.5 \times \text{Weight}(\text{kg})}{200}
$$

**Giải thích các thành phần:**

- **METs (Metabolic Equivalents):** Giá trị chuẩn hóa cho cường độ hoạt động.
- **3.5:** Tỷ lệ tiêu thụ Oxy chuẩn ở trạng thái nghỉ (ml O₂/kg/phút).
- **Weight (kg):** Trọng lượng cơ thể.
- **200:** Hằng số chuyển đổi kcal/L O₂ và ml/L.

#### B. Nguồn Tham khảo Khoa học và Minh bạch:

- **Bảng Giá trị METs:** [The Compendium of Physical Activities](https://pacompendium.com/)
- **Công thức:** Được **American College of Sports Medicine (ACSM)** khuyến nghị và sử dụng rộng rãi.

---

### 2. Phương pháp dựa trên Nhịp tim (Heart Rate - HR)

Công thức này phù hợp khi sử dụng các thiết bị đeo (smartwatch) hoặc máy đo nhịp tim để theo dõi phản ứng sinh lý của cơ thể.

#### A. Công thức Keytel (2005)

Công thức điều chỉnh cho **Nhịp tim**, **Tuổi**, **Cân nặng** và **Giới tính** để ước tính lượng Calo tiêu thụ chính xác hơn.

$$
\text{CB} (\text{kcal/tổng thời gian}) = \text{Duration}(\text{phút}) \times \frac{\text{AHR} (\text{Nam/Nữ})}{4.184}
$$

Trong đó, $\text{AHR}$ (Tiêu thụ Oxy theo tuổi/giới tính/cân nặng):

- **Nam (Men):**
  $$
  \text{AHR} = (0.6309 \times \text{HR} + 0.1988 \times \text{Weight} + 0.2017 \times \text{Age} - 55.0969)
  $$
- **Nữ (Women):**
  $$
  \text{AHR} = (0.4472 \times \text{HR} - 0.1263 \times \text{Weight} + 0.074 \times \text{Age} - 20.4022)
  $$

_(Ghi chú: 4.184 là hệ số chuyển đổi từ **kJ** sang **kcal**)._

#### B. Nguồn Tham khảo Khoa học:

- **Tên Nghiên cứu:** Keytel et al. (2005)
- **PubMed ID:** [16017260](https://pubmed.ncbi.nlm.nih.gov/16017260/)
- **Tạp chí:** Journal of Sports Sciences

---

## II. Công thức Xác định Cường độ Tập luyện (Intensity)

Để đề xuất cường độ tập luyện an toàn và hiệu quả, cần sử dụng Công thức **Karvonen**, dựa trên **Dự trữ Nhịp tim ($\text{HRR}$)**.

### 1. Nhịp tim Tối đa ($\text{HR}_{\text{max}}$)

Sử dụng công thức hiệu chỉnh để có độ chính xác cao hơn công thức $220 - \text{Age}$ cũ.

$$
\text{HR}_{\text{max}} = 208 - (0.7 \times \text{Age})
$$

**Nguồn Tham khảo:** Công thức Tanaka (2001), [PubMed](https://pubmed.ncbi.nlm.nih.gov/11738784/)

---

### 2. Công thức Karvonen (Nhịp tim Mục tiêu)

Công thức ACSM khuyến nghị để xác định nhịp tim mục tiêu cho từng vùng cường độ.

$$
\text{HR}_{\text{mục tiêu}} = [(\text{HR}_{\text{max}} - \text{HR}_{\text{nghỉ}}) \times \% \text{Cường độ}] + \text{HR}_{\text{nghỉ}}
$$

| Vùng Cường độ (Intensity Zone) | % HRR (Karvonen) | Mục đích Tập luyện                        |
| :----------------------------- | :--------------- | :---------------------------------------- |
| Light (Nhẹ)                    | 50% - 60%        | Khởi động, Phục hồi                       |
| Moderate (Trung bình)          | 60% - 70%        | Đốt mỡ, Cải thiện sức bền cơ bản          |
| Vigorous (Cao)                 | 70% - 85%        | Cải thiện Tim mạch và Hiệu suất tập luyện |

**Nguồn Tham khảo:** ACSM's Guidelines for Exercise Testing and Prescription

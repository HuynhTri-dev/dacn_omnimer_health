# Tài liệu Mô tả Ontology OmniMer Health

Tài liệu này mô tả chi tiết cấu trúc Ontology và các mô hình dữ liệu (Data Models) được sử dụng trong hệ thống OmniMer Health Linked Open Data (LOD).

## 1. Namespaces & Prefixes

Các prefix sau được sử dụng để định danh các tài nguyên và thuộc tính trong hệ thống:

| Prefix   | URI                                     | Mô tả                                                       |
| -------- | --------------------------------------- | ----------------------------------------------------------- |
| `:`      | `http://omnimer.health/data/`           | Namespace mặc định cho dữ liệu instance                     |
| `ont`    | `http://omnimer.health/ontology/`       | Ontology riêng của OmniMer Health                           |
| `xsd`    | `http://www.w3.org/2001/XMLSchema#`     | Các kiểu dữ liệu cơ bản (string, int, date...)              |
| `sosa`   | `http://www.w3.org/ns/sosa/`            | Sensor, Observation, Sample, and Actuator (IoT/Sensor data) |
| `ssn`    | `http://www.w3.org/ns/ssn/`             | Semantic Sensor Network                                     |
| `snomed` | `http://snomed.info/id/`                | SNOMED CT (Thuật ngữ y khoa)                                |
| `loinc`  | `http://loinc.org/rdf/`                 | LOINC (Mã định danh cho quan sát y tế)                      |
| `fhir`   | `http://hl7.org/fhir/`                  | HL7 FHIR (Tiêu chuẩn trao đổi dữ liệu y tế)                 |
| `schema` | `http://schema.org/`                    | Schema.org (Metadata phổ biến)                              |
| `foaf`   | `http://xmlns.com/foaf/0.1/`            | Friend of a Friend (Thông tin người dùng)                   |
| `unit`   | `http://qudt.org/vocab/unit/`           | Đơn vị đo lường                                             |
| `prov`   | `http://www.w3.org/ns/prov#`            | Provenance (Nguồn gốc dữ liệu)                              |
| `rdfs`   | `http://www.w3.org/2000/01/rdf-schema#` | RDF Schema                                                  |

## 2. Mô hình Dữ liệu (Data Models)

### 2.1. Người dùng (User)

Đại diện cho người dùng trong hệ thống. Để đảm bảo quyền riêng tư, ID người dùng được ẩn danh (hash).

- **Class**: `schema:Person`
- **URI**: `:user_{hashed_id}`
- **Thuộc tính**:

| Thuộc tính     | Predicate          | Kiểu dữ liệu  | Mô tả                                 |
| -------------- | ------------------ | ------------- | ------------------------------------- |
| Giới tính      | `schema:gender`    | string        | Ví dụ: "Male", "Female"               |
| Năm sinh       | `schema:birthYear` | `xsd:gYear`   | Năm sinh của người dùng               |
| Đồng ý chia sẻ | `ont:hasConsent`   | `xsd:boolean` | Trạng thái đồng ý chia sẻ dữ liệu LOD |

### 2.2. Hồ sơ Sức khỏe (Health Profile)

Lưu trữ các chỉ số cơ thể và tình trạng sức khỏe tại một thời điểm kiểm tra.

- **Class**: `sosa:Observation`
- **URI**: `:hp_{profile_id}`
- **Thuộc tính chính**:
  - `sosa:hasFeatureOfInterest`: Tham chiếu đến URI của User.
  - `sosa:resultTime`: Ngày ghi nhận (`xsd:date`).
  - `sosa:hasMember`: Chứa các quan sát chi tiết (Observation con).
  - `ont:hasAiEvaluation`: Tham chiếu đến đánh giá của AI (`ont:AiEvaluation`).

#### Các chỉ số đo lường (Measurements) - `sosa:hasMember`

Mỗi chỉ số là một `sosa:Observation` con với `sosa:observedProperty` tương ứng:

| Chỉ số              | Mã (Predicate)         | Đơn vị (Unit)     |
| ------------------- | ---------------------- | ----------------- |
| BMI                 | `loinc:39156-5`        | `KiloGM-M2`       |
| Body Fat %          | `loinc:41982-0`        | `Percent`         |
| Cân nặng            | `loinc:29463-7`        | `KiloGM`          |
| Chiều cao           | `loinc:8302-2`         | `CentiM`          |
| Vòng eo             | `loinc:8280-0`         | `CentiM`          |
| Vòng hông           | `loinc:8281-8`         | `CentiM`          |
| Vòng cổ             | `loinc:33748-5`        | `CentiM`          |
| Nhịp tim nghỉ       | `snomed:364075005`     | `BeatsPerMinute`  |
| Huyết áp tâm thu    | `snomed:271649006`     | `MilliMHG`        |
| Huyết áp tâm trương | `snomed:271650006`     | `MilliMHG`        |
| Cholesterol TP      | `loinc:2093-3`         | `MilliMOL-PER-L`  |
| Cholesterol LDL     | `loinc:2089-1`         | `MilliMOL-PER-L`  |
| Cholesterol HDL     | `loinc:2085-9`         | `MilliMOL-PER-L`  |
| Đường huyết         | `loinc:2345-7`         | `MilliMOL-PER-L`  |
| BMR                 | `loinc:39156-7`        | `KiloCAL-PER-DAY` |
| Khối lượng cơ       | `ont:muscleMass`       | `KiloGM`          |
| Hít đất tối đa      | `ont:maxPushUps`       | `Count`           |
| Mức tạ tối đa       | `ont:maxWeightLifted`  | `KiloGM`          |
| Mức độ hoạt động    | `ont:activityLevel`    | `Scale` (1-10)    |
| Kinh nghiệm tập     | `ont:experienceLevel`  | `Code`            |
| Tần suất tập        | `ont:workoutFrequency` | `Times-PER-WEEK`  |

#### Tình trạng sức khỏe (Health Status)

Các vấn đề sức khỏe cũng được lưu dưới dạng `sosa:Observation` con:

| Loại        | Predicate          | Giá trị          |
| ----------- | ------------------ | ---------------- |
| Bệnh lý     | `snomed:404684003` | Tên bệnh lý      |
| Vị trí đau  | `snomed:22253000`  | Vị trí cơ thể    |
| Vấn đề khớp | `snomed:302869004` | Vấn đề khớp      |
| Chấn thương | `snomed:281647001` | Loại chấn thương |

#### Đánh giá AI (AI Evaluation)

- **Class**: `ont:AiEvaluation`
- **Thuộc tính**:
  - `ont:aiSummary`: Tóm tắt đánh giá (`xsd:string`).
  - `ont:healthScore`: Điểm sức khỏe (`xsd:integer`).
  - `ont:riskLevel`: Mức độ rủi ro.
  - `ont:modelVersion`: Phiên bản model AI.
  - `sosa:resultTime`: Thời gian đánh giá.

### 2.3. Nhật ký Đồng hồ (Watch Log)

Dữ liệu tổng hợp hàng ngày từ thiết bị đeo (smartwatch).

- **Class**: `sosa:ObservationCollection`
- **URI**: `:wl_{log_id}`
- **Thuộc tính chính**:
  - `sosa:hasFeatureOfInterest`: Tham chiếu đến User.
  - `sosa:resultTime`: Ngày ghi nhận (`xsd:date`).
  - `prov:wasGeneratedBy`: Thông tin thiết bị (`sosa:Sensor`).

#### Thông tin thiết bị (`sosa:Sensor`)

- `rdfs:label`: Loại thiết bị.
- `ont:deviceCategory`: Phân loại thiết bị.
- `ont:deviceName`: Tên thiết bị.
- `ont:platform`: Nền tảng (OS).

#### Các chỉ số hoạt động (Activity Metrics)

Được lưu trong `sosa:hasMember`:

| Chỉ số        | Mã (Predicate)       | Đơn vị           |
| ------------- | -------------------- | ---------------- |
| Số bước chân  | `loinc:55423-8`      | -                |
| Calo tổng     | `loinc:41981-2`      | `KiloCalorie`    |
| Calo active   | `ont:activeCalories` | `KiloCalorie`    |
| Thời gian ngủ | `snomed:248263006`   | `Minute`         |
| Nhịp tim TB   | `snomed:364075005`   | `BeatsPerMinute` |
| Nhịp tim Min  | `loinc:8867-4`       | `BeatsPerMinute` |
| Nhịp tim Max  | `loinc:8893-0`       | `BeatsPerMinute` |
| Quãng đường   | `loinc:55430-3`      | `KiloM`          |
| Tốc độ TB     | `loinc:55411-3`      | `KiloM-PER-HR`   |

### 2.4. Buổi tập (Workout)

Dữ liệu về các buổi tập luyện thể dục.

- **Class**: `schema:ExerciseAction`
- **URI**: `:wk_{workout_id}`
- **Thuộc tính**:
  - `schema:agent`: Tham chiếu đến User.
  - `schema:startTime`: Thời gian bắt đầu (`xsd:dateTime`).
  - `schema:endTime`: Thời gian kết thúc (`xsd:dateTime`).
  - `ont:totalCalories`: Tổng calo (`xsd:integer`).
  - `ont:avgHeartRate`: Nhịp tim TB (`xsd:integer`).
  - `ont:steps`: Số bước trong buổi tập.
  - `ont:distance`: Quãng đường (nếu có).
  - `ont:waterIntake`: Lượng nước uống (ml).
  - `schema:instrument`: Chi tiết bài tập (`ont:ExerciseSession`).

#### Chi tiết bài tập (`ont:ExerciseSession`)

- `ont:exerciseId`: ID bài tập.
- `ont:sets`: Danh sách các hiệp tập (`ont:Set`).
  - `ont:reps`: Số lần lặp.
  - `ont:weight`: Mức tạ (kg).
  - `ont:duration`: Thời gian (giây).
  - `ont:restTime`: Thời gian nghỉ (giây).

### 2.5. Mục tiêu (Goal)

Mục tiêu sức khỏe người dùng đặt ra.

- **Class**: `fhir:Goal`
- **URI**: `:gl_{goal_id}`
- **Thuộc tính**:
  - `fhir:Goal.subject`: Tham chiếu đến User.
  - `fhir:Goal.description`: Loại mục tiêu.
  - `fhir:Goal.startDate`: Ngày bắt đầu.
  - `fhir:Goal.target`: Đối tượng mục tiêu.
    - `fhir:Goal.target.measure`: Mã chỉ số (LOINC/SNOMED).
    - `fhir:Goal.target.detailQuantity`: Giá trị mục tiêu.
      - `fhir:Quantity.value`: Giá trị số.
      - `fhir:Quantity.unit`: Đơn vị.

### 2.6. Bài tập (Exercise)

Danh mục các bài tập có trong hệ thống.

- **Class**: `ont:Exercise`
- **URI**: `:ex_{exercise_id}`
- **Thuộc tính**:
  - `rdfs:label`: Tên bài tập.
  - `ont:bodyPart`: Nhóm cơ/bộ phận cơ thể.
  - `ont:targetMuscle`: Cơ mục tiêu.
  - `ont:equipment`: Dụng cụ tập luyện.
  - `ont:difficulty`: Độ khó.
  - `ont:instructions`: Hướng dẫn tập luyện.

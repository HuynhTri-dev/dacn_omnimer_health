# Hướng dẫn Truy vấn Dữ liệu Sức khỏe OmniMer (SPARQL Guide)

Tài liệu này mô tả cấu trúc dữ liệu Linked Open Data (LOD) của hệ thống OmniMer Health và cung cấp các mẫu câu truy vấn SPARQL để khai thác dữ liệu.

## 1. Namespaces & Prefixes

Các prefix sau được sử dụng trong toàn bộ hệ thống dữ liệu:

```sparql
PREFIX : <http://omnimer.health/data/>
PREFIX ont: <http://omnimer.health/ontology/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX sosa: <http://www.w3.org/ns/sosa/>
PREFIX ssn: <http://www.w3.org/ns/ssn/>
PREFIX snomed: <http://snomed.info/id/>
PREFIX loinc: <http://loinc.org/rdf/>
PREFIX fhir: <http://hl7.org/fhir/>
PREFIX schema: <http://schema.org/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX unit: <http://qudt.org/vocab/unit/>
PREFIX prov: <http://www.w3.org/ns/prov#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
```

## 2. Mô hình Dữ liệu (Data Models)

### 2.1. Người dùng (User)

- **Type**: `schema:Person`
- **Properties**:
  - `schema:gender`: Giới tính (ví dụ: "Male", "Female").
  - `schema:birthDate`: Năm sinh (`xsd:gYear`).
  - `ont:hasConsent`: Trạng thái đồng ý chia sẻ dữ liệu (`xsd:boolean`).

### 2.2. Hồ sơ Sức khỏe (Health Profile)

- **Type**: `sosa:Observation`
- **Properties**:
  - `sosa:hasFeatureOfInterest`: URI của User.
  - `sosa:resultTime`: Ngày đo (`xsd:date`).
  - `sosa:hasMember`: Các chỉ số chi tiết (cũng là `sosa:Observation`).
- **Các chỉ số (Observed Properties)**:
  - **BMI**: `loinc:39156-5` (Unit: `unit:KiloGM-M2`)
  - **Body Fat**: `loinc:41982-0` (Unit: `unit:Percent`)
  - **Resting Heart Rate**: `snomed:364075005` (Unit: `unit:BeatsPerMinute`)
  - **Weight**: `loinc:29463-7` (Unit: `unit:KiloGM`)
  - **Height**: `loinc:8302-2` (Unit: `unit:CentiM`)

### 2.3. Nhật ký Đồng hồ (Watch Log)

- **Type**: `sosa:ObservationCollection`
- **Properties**:
  - `sosa:hasFeatureOfInterest`: URI của User.
  - `sosa:resultTime`: Ngày ghi nhận (`xsd:date`).
  - `prov:wasGeneratedBy`: Thông tin thiết bị (`sosa:Sensor`).
- **Các chỉ số (Observed Properties)**:
  - **Steps**: `loinc:55423-8`
  - **Calories Burned**: `loinc:41981-2` (Unit: `unit:KiloCalorie`)
  - **Sleep Duration**: `snomed:248263006` (Unit: `unit:Minute`)
  - **Heart Rate Avg**: `snomed:364075005` (Unit: `unit:BeatsPerMinute`)

### 2.4. Tập luyện (Workout)

- **Type**: `schema:ExerciseAction`
- **Properties**:
  - `schema:agent`: URI của User.
  - `schema:startTime`: Thời gian bắt đầu (`xsd:dateTime`).
  - `schema:endTime`: Thời gian kết thúc (`xsd:dateTime`).
  - `ont:totalCalories`: Tổng calo tiêu thụ (`xsd:integer`).
  - `ont:avgHeartRate`: Nhịp tim trung bình (`xsd:integer`).
  - `schema:instrument`: Chi tiết bài tập (`ont:ExerciseSession`).
    - `ont:exerciseId`: ID bài tập.
    - `ont:sets`: Các hiệp tập (`ont:Set`).

### 2.5. Mục tiêu (Goal)

- **Type**: `fhir:Goal`
- **Properties**:
  - `fhir:Goal.subject`: Tham chiếu đến User.
  - `fhir:Goal.description`: Loại mục tiêu (Goal Type).
  - `fhir:Goal.startDate`: Ngày bắt đầu (`xsd:date`).
  - `fhir:Goal.target`: Các chỉ số mục tiêu.
    - `fhir:Goal.target.measure`: Mã LOINC của chỉ số.
    - `fhir:Goal.target.detailQuantity`: Giá trị và đơn vị.

---

## 3. Mẫu Truy vấn SPARQL (Example Queries)

Dưới đây là các câu truy vấn mẫu để bạn có thể thử nghiệm trên GraphDB.

### 3.1. Lấy danh sách người dùng và thông tin cơ bản

Lấy URI, giới tính và năm sinh của tất cả người dùng đã đồng ý chia sẻ dữ liệu.

```sparql
PREFIX schema: <http://schema.org/>
PREFIX ont: <http://omnimer.health/ontology/>

SELECT ?user ?gender ?birthYear
WHERE {
    ?user a schema:Person ;
          ont:hasConsent "true"^^xsd:boolean .
    OPTIONAL { ?user schema:gender ?gender . }
    OPTIONAL { ?user schema:birthDate ?birthYear . }
}
```

### 3.2. Lấy lịch sử chỉ số BMI của một người dùng

Thay `user_ID` bằng ID thực tế hoặc dùng biến.

```sparql
PREFIX sosa: <http://www.w3.org/ns/sosa/>
PREFIX loinc: <http://loinc.org/rdf/>
PREFIX unit: <http://qudt.org/vocab/unit/>

SELECT ?date ?bmiValue
WHERE {
    ?observation a sosa:Observation ;
                 sosa:hasFeatureOfInterest ?user ;
                 sosa:resultTime ?date ;
                 sosa:hasMember ?member .

    ?member sosa:observedProperty loinc:39156-5 ;
            sosa:hasSimpleResult ?bmiValue .

    # Filter cho một user cụ thể nếu cần
    # FILTER(REGEX(STR(?user), "user_ID"))
}
ORDER BY DESC(?date)
```

### 3.3. Thống kê tổng bước chân theo ngày

Lấy dữ liệu bước chân từ các log của đồng hồ thông minh.

```sparql
PREFIX sosa: <http://www.w3.org/ns/sosa/>
PREFIX loinc: <http://loinc.org/rdf/>

SELECT ?date ?steps
WHERE {
    ?log a sosa:ObservationCollection ;
         sosa:resultTime ?date ;
         sosa:hasMember ?member .

    ?member sosa:observedProperty loinc:55423-8 ;
            sosa:hasSimpleResult ?steps .
}
ORDER BY DESC(?date)
```

### 3.4. Truy vấn lịch sử tập luyện (Workout)

Lấy thông tin về các buổi tập: thời gian, calo tiêu thụ và nhịp tim trung bình.

```sparql
PREFIX schema: <http://schema.org/>
PREFIX ont: <http://omnimer.health/ontology/>

SELECT ?workout ?startTime ?calories ?avgHeartRate
WHERE {
    ?workout a schema:ExerciseAction ;
             schema:startTime ?startTime ;
             ont:totalCalories ?calories .

    OPTIONAL { ?workout ont:avgHeartRate ?avgHeartRate . }
}
ORDER BY DESC(?startTime)
```

### 3.5. Tìm các mục tiêu sức khỏe (Goals) của người dùng

Lấy thông tin về các mục tiêu mà người dùng đã đặt ra.

```sparql
PREFIX fhir: <http://hl7.org/fhir/>

SELECT ?goal ?description ?startDate ?targetValue ?targetUnit
WHERE {
    ?goal a fhir:Goal ;
          fhir:Goal.description ?descNode ;
          fhir:Goal.startDate ?startDateNode .

    ?descNode fhir:value ?description .
    ?startDateNode fhir:value ?startDate .

    OPTIONAL {
        ?goal fhir:Goal.target ?target .
        ?target fhir:Goal.target.detailQuantity ?qty .
        ?qty fhir:Quantity.value ?targetValue .
        OPTIONAL { ?qty fhir:Quantity.unit ?targetUnit . }
    }
}
```

### 3.6. Truy vấn phức tạp: Tương quan giữa Bước chân và Calo tiêu thụ

Kết hợp dữ liệu từ WatchLog để xem mối liên hệ giữa số bước chân và calo tiêu thụ trong ngày.

```sparql
PREFIX sosa: <http://www.w3.org/ns/sosa/>
PREFIX loinc: <http://loinc.org/rdf/>

SELECT ?date ?steps ?calories
WHERE {
    ?log a sosa:ObservationCollection ;
         sosa:resultTime ?date .

    ?log sosa:hasMember ?stepMember .
    ?stepMember sosa:observedProperty loinc:55423-8 ;
                sosa:hasSimpleResult ?steps .

    ?log sosa:hasMember ?calMember .
    ?calMember sosa:observedProperty loinc:41981-2 ;
               sosa:hasSimpleResult ?calories .
}
ORDER BY DESC(?date)
```

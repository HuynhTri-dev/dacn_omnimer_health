# Hướng dẫn Triển khai và Sử dụng SPARQL (Deployment & Usage Guide)

Tài liệu này hướng dẫn cách triển khai, cấu hình kết nối đến GraphDB và cách sử dụng SPARQL để truy vấn dữ liệu trong hệ thống OmniMer Health.

## 1. Triển khai và Cấu hình (Deployment & Configuration)

Hệ thống OmniMer Health sử dụng **GraphDB** làm cơ sở dữ liệu tri thức (Knowledge Graph) để lưu trữ dữ liệu dưới dạng Linked Open Data (LOD).

### 1.1. Yêu cầu (Prerequisites)

- **GraphDB**: Cần có một instance GraphDB đang chạy (local hoặc server).
- **Repository**: Cần tạo một repository trong GraphDB (ví dụ: `omnimer-health`).

### 1.2. Cấu hình Kết nối

Cấu hình kết nối GraphDB được lưu trong file cấu hình của dự án (thường là biến môi trường hoặc file config).

Trong mã nguồn (`omnimer_health_server`), cấu hình nằm tại `src/common/configs/graphdb.config.ts`:

```typescript
export const graphdbConfig = {
  baseUrl: process.env.GRAPHDB_URL || "http://localhost:7200",
  repository: process.env.GRAPHDB_REPOSITORY || "omnimer-health",
  // ... các cấu hình khác
};
```

Đảm bảo các biến môi trường `GRAPHDB_URL` và `GRAPHDB_REPOSITORY` được thiết lập chính xác.

### 1.3. Đồng bộ Dữ liệu (Data Synchronization)

Hệ thống tự động đồng bộ dữ liệu từ cơ sở dữ liệu chính (MongoDB) sang GraphDB thông qua `GraphDBService`.

- **Cơ chế**: Khi dữ liệu người dùng (Profile, Workout, WatchLog...) thay đổi, hệ thống sẽ:

  1. Chuyển đổi dữ liệu sang định dạng RDF (Turtle) sử dụng `LODMapper`.
  2. Gửi lệnh SPARQL UPDATE để xóa dữ liệu cũ và chèn dữ liệu mới vào GraphDB.

- **Service**: `src/domain/services/LOD/GraphDB.service.ts`
  - `insertData(turtleData)`: Chèn dữ liệu mới.
  - `deleteUserData(userId)`: Xóa toàn bộ dữ liệu liên quan đến một User.
  - `updateUserData(userId, turtleData)`: Cập nhật dữ liệu (Xóa cũ + Thêm mới).

## 2. Sử dụng SPARQL để Truy vấn

Bạn có thể truy vấn dữ liệu trực tiếp thông qua giao diện GraphDB Workbench hoặc qua API.

### 2.1. Namespaces thường dùng

```sparql
PREFIX : <http://omnimer.health/data/>
PREFIX ont: <http://omnimer.health/ontology/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX sosa: <http://www.w3.org/ns/sosa/>
PREFIX loinc: <http://loinc.org/rdf/>
PREFIX snomed: <http://snomed.info/id/>
PREFIX fhir: <http://hl7.org/fhir/>
PREFIX schema: <http://schema.org/>
```

### 2.2. Các Mẫu Truy vấn (Example Queries)

Dưới đây là các câu truy vấn mẫu để khai thác dữ liệu.

#### 1. Lấy danh sách người dùng

Lấy URI, giới tính và năm sinh của tất cả người dùng đã đồng ý chia sẻ dữ liệu.

```sparql
SELECT ?user ?gender ?birthYear
WHERE {
    ?user a schema:Person ;
          ont:hasConsent "true"^^xsd:boolean .
    OPTIONAL { ?user schema:gender ?gender . }
    OPTIONAL { ?user schema:birthYear ?birthYear . }
}
```

#### 2. Lấy lịch sử chỉ số BMI

Lấy lịch sử chỉ số BMI của một người dùng cụ thể (hoặc tất cả nếu không lọc).

```sparql
SELECT ?date ?bmiValue
WHERE {
    ?observation a sosa:Observation ;
                 sosa:hasFeatureOfInterest ?user ;
                 sosa:resultTime ?date ;
                 sosa:hasMember ?member .

    ?member sosa:observedProperty loinc:39156-5 ;
            sosa:hasSimpleResult ?bmiValue .

    # FILTER(REGEX(STR(?user), "user_ID_hash"))
}
ORDER BY DESC(?date)
```

#### 3. Thống kê bước chân hàng ngày

Lấy dữ liệu tổng số bước chân từ Watch Log.

```sparql
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

#### 4. Lịch sử tập luyện (Workout)

Lấy thông tin thời gian, calo tiêu thụ và nhịp tim trung bình của các buổi tập.

```sparql
SELECT ?workout ?startTime ?calories ?avgHeartRate
WHERE {
    ?workout a schema:ExerciseAction ;
             schema:startTime ?startTime ;
             ont:totalCalories ?calories .

    OPTIONAL { ?workout ont:avgHeartRate ?avgHeartRate . }
}
ORDER BY DESC(?startTime)
```

#### 5. Tìm mục tiêu sức khỏe (Goals)

Lấy danh sách các mục tiêu người dùng đang theo đuổi.

```sparql
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

#### 6. Truy vấn phức tạp: Tương quan Bước chân và Calo

Kết hợp dữ liệu để xem mối liên hệ giữa vận động (bước chân) và năng lượng tiêu thụ.

```sparql
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

#### 7. Lấy toàn bộ dữ liệu (Dump All)

Dùng để kiểm tra toàn bộ dữ liệu trong graph (giới hạn 1000 kết quả).

```sparql
SELECT ?s ?p ?o
WHERE {
    ?s ?p ?o .
}
LIMIT 1000
```

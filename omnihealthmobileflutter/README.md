# OmniHealth Mobile Flutter App

Dự án ứng dụng di động OmniHealth được xây dựng bằng Flutter, áp dụng kiến trúc **Clean Architecture** để đảm bảo tính mở rộng, dễ bảo trì và kiểm thử.

## 📂 Cấu trúc Dự án

Source code được tổ chức trong thư mục `lib` với cấu trúc phân tầng rõ ràng:

```text
lib/
├── core/           # Các thành phần cốt lõi dùng chung
├── data/           # Lớp dữ liệu (Data Layer)
├── domain/         # Lớp nghiệp vụ (Domain Layer)
├── presentation/   # Lớp giao diện (Presentation Layer)
├── services/       # Các dịch vụ hệ thống/bên ngoài
├── utils/          # Các tiện ích hỗ trợ
├── main.dart       # Điểm khởi chạy ứng dụng
└── injection_container.dart # Cấu hình Dependency Injection
```

## 🏗 Chi tiết Kiến trúc

### 1. Domain Layer (`lib/domain`)

Đây là lớp trong cùng, chứa logic nghiệp vụ thuần túy và không phụ thuộc vào bất kỳ lớp nào khác (kể cả Flutter UI hay Data sources).

- **abstracts/**: Chứa các interfaces (contracts) cho Repositories. Các lớp ở `data` sẽ implement các interface này.
- **entities/**: Các đối tượng nghiệp vụ cốt lõi (Business Objects).
- **usecases/**: Chứa các logic nghiệp vụ cụ thể (Business Logic), mỗi use case đại diện cho một hành động của người dùng hoặc hệ thống.

### 2. Data Layer (`lib/data`)

Lớp này chịu trách nhiệm quản lý dữ liệu, bao gồm việc lấy dữ liệu từ API hoặc lưu trữ cục bộ.

- **datasources/**: Các nguồn dữ liệu (Remote API, Local Database).
- **models/**: Các mô hình dữ liệu (Data Models), là định nghĩa của dữ liệu đầu vào và ra của API với các phương thức chuyển đổi JSON (fromJson, toJson), chuyển đổi Entity (toEntity, fromEntity).
- **repositories/**: Triển khai (Implement) các interfaces được định nghĩa trong `domain/abstracts`. Chịu trách nhiệm điều phối dữ liệu giữa Datasources và Domain, Là nơi chuyển đổi dữ liệu từ data/models sang data/entities và ngược lại.

### 3. Presentation Layer (`lib/presentation`)

Lớp này chịu trách nhiệm hiển thị giao diện người dùng và xử lý tương tác.

- **screen/**: Chứa các màn hình của ứng dụng.
- **common/**: Chứa các Widget dùng chung, tái sử dụng được.
- **app.dart & app_view.dart**: Cấu hình gốc của ứng dụng (MaterialApp, Theme, Routing setup).

### 4. Core Layer (`lib/core`)

Chứa các thành phần nền tảng được sử dụng xuyên suốt ứng dụng.

- **api/**: Cấu hình API Client (Dio/Http), xử lý request/response chung.
- **constants/**: Các hằng số (màu sắc, strings, assets path).
- **routing/**: Cấu hình điều hướng (Navigation).
- **theme/**: Cấu hình giao diện (ThemeData, Styles).
- **validation/**: Các logic kiểm tra dữ liệu đầu vào.

### 5. Services & Utils

- **services/** (`lib/services`): Các dịch vụ độc lập như `SecureStorageService`, `SharedPreferencesService`.
- **utils/** (`lib/utils`): Các hàm tiện ích hỗ trợ như `Logger`, `FilterUtil`, `SortUtil`, `QueryBuilder`.

---

## 🔄 Luồng dữ liệu (Data Flow)

1.  **UI (Presentation)** gọi **UseCase** (Domain).
2.  **UseCase** gọi **Repository Interface** (Domain).
3.  **Repository Implementation** (Data) thực thi logic, gọi **DataSource** (Data).
4.  **DataSource** lấy dữ liệu từ **API** hoặc **Local DB**, trả về **Model**.
5.  **Repository** chuyển đổi **Model** thành **Entity** và trả về cho **UseCase**.
6.  **UseCase** trả **Entity** về cho **UI** để hiển thị.

---

## 🚀 Cài đặt & Chạy ứng dụng

1.  **Clone repository**:

    ```bash
    git clone <repository-url>
    ```

2.  **Cài đặt dependencies**:

    ```bash
    flutter pub get
    ```

3.  **Chạy ứng dụng**:
    ```bash
    flutter run
    ```

## 🤝 Hướng dẫn đóng góp (Contributing)

1.  Tuân thủ cấu trúc thư mục đã định nghĩa.
2.  Đặt tên file theo `snake_case`, tên class theo `PascalCase`.
3.  Luôn viết Unit Test cho các UseCase và Repository mới.
4.  Đảm bảo code không có lỗi lint trước khi commit.

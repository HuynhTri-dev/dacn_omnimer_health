# OmniHealth Mobile Flutter App

Dự án ứng dụng di động OmniHealth được xây dựng bằng Flutter, áp dụng triệt để kiến trúc **Clean Architecture** để đảm bảo tính mở rộng, dễ bảo trì, kiểm thử và tách biệt rõ ràng giữa các lớp logic.

## 📂 Cấu trúc Dự án (Project Structure)

Source code được tổ chức chính trong thư mục `lib` với cấu trúc phân tầng chi tiết như sau:

```text
lib/
├── core/                   # Các thành phần cốt lõi và triển khai cơ sở (Core functionality)
│   ├── api/               # Các triển khai liên quan đến API
│   │   ├── api_client.dart        # HTTP client (sử dụng Dio)
│   │   ├── api_exception.dart     # Các ngoại lệ tùy chỉnh cho API
│   │   ├── api_response.dart      # Wrapper chuẩn cho phản hồi API
│   │   ├── app_config.dart        # Cấu hình môi trường
│   │   └── endpoints.dart         # Định nghĩa các API endpoints
│   ├── constants/         # Các hằng số toàn ứng dụng (Colors, Strings,...)
│   └── theme/             # Cấu hình giao diện và theme
├── data/                  # Lớp dữ liệu (Data Layer) - Xử lý nguồn dữ liệu
│   ├── datasources/       # Triển khai các nguồn dữ liệu (Remote/Local)
│   │   └── auth_datasource.dart   # Ví dụ: Gọi API xác thực
│   ├── models/            # Các mô hình dữ liệu (Data Models) cho API
│   │   └── user_model.dart        # Ví dụ: Model User từ API (có fromJson/toJson)
│   └── repositories/      # Triển khai các Repository của Domain
│       └── auth_repository_impl.dart  # Ví dụ: Triển khai AuthRepository
├── domain/                # Lớp nghiệp vụ (Business Logic Layer) - Chứa logic cốt lõi
│   ├── abstracts/         # Các định nghĩa trừu tượng (Interfaces)
│   │   └── auth_repository.dart   # Ví dụ: Interface cho Auth Repository
│   ├── entities/          # Các thực thể nghiệp vụ (Business Entities)
│   │   └── user_entity.dart       # Ví dụ: Entity User dùng trong app
│   └── usecase/           # Các trường hợp sử dụng (Use Cases)
│       └── login_usecase.dart     # Ví dụ: Logic đăng nhập
├── presentation/          # Lớp giao diện (UI Layer)
│   ├── screens/           # Các màn hình của ứng dụng (Pages)
│   └── widgets/           # Các widget tái sử dụng
├── services/              # Các dịch vụ bên ngoài (External Services)
│   ├── firebase_auth_service.dart  # Dịch vụ Firebase Auth
│   └── firebase_auth_failure.dart  # Xử lý lỗi Firebase
└── utils/                 # Các tiện ích hỗ trợ (Utilities)
    ├── filter_util.dart    # Tiện ích lọc dữ liệu
    ├── logger.dart         # Tiện ích ghi log
    ├── query_builder.dart  # Hỗ trợ xây dựng query
    └── sort_util.dart      # Tiện ích sắp xếp
```

## 🏗 Chi tiết Kiến trúc (Architecture Details)

### 1. Core Layer (`/core`)

Chứa các chức năng nền tảng được sử dụng xuyên suốt ứng dụng.

- **api/**: Quản lý giao tiếp mạng. `api_client.dart` là client HTTP trung tâm. `api_response.dart` định dạng chuẩn cho mọi phản hồi.
- **constants/** & **theme/**: Quản lý tài nguyên tĩnh và giao diện.

### 2. Data Layer (`/data`)

Chịu trách nhiệm quản lý dữ liệu và chuyển đổi dữ liệu.

- **datasources/**: Thực hiện các cuộc gọi API trực tiếp hoặc truy vấn DB local.
- **models/**: Định nghĩa cấu trúc dữ liệu từ API. Chứa logic serialize/deserialize (`fromJson`, `toJson`) và chuyển đổi sang Entity (`toEntity`).
- **repositories/**: Triển khai các interface từ Domain layer. Đây là nơi quyết định lấy dữ liệu từ đâu (Cache hay API) và chuyển đổi Model thành Entity.

### 3. Domain Layer (`/domain`)

Lớp quan trọng nhất, chứa logic nghiệp vụ và không phụ thuộc vào UI hay Data layer.

- **abstracts/**: Định nghĩa các "hợp đồng" (interfaces) mà Data layer phải tuân thủ.
- **entities/**: Các object thuần túy chứa dữ liệu nghiệp vụ, không phụ thuộc vào JSON hay API.
- **usecase/**: Đóng gói logic cho từng hành động cụ thể của người dùng (VD: Login, GetProducts).

### 4. Presentation Layer (`/presentation`)

Nơi hiển thị dữ liệu và nhận tương tác người dùng.

- **screens/**: Mỗi màn hình là một file/thư mục riêng.
- **widgets/**: Các thành phần UI nhỏ, có thể tái sử dụng.

### 5. Services & Utils

- **services/**: Tích hợp các dịch vụ bên thứ 3 như Firebase, Notification.
- **utils/**: Các hàm helper thuần túy (pure functions) để xử lý logic phụ trợ.

## 🔄 Luồng dữ liệu (Data Flow)

Lấy ví dụ với chức năng **Đăng nhập (Authentication)**:

1.  **UI Layer** (`presentation/`) gọi `LoginUseCase`.
2.  **UseCase** (`domain/usecase/login_usecase.dart`) gọi `AuthRepository.login()`.
3.  **Repository** (`data/repositories/auth_repository_impl.dart`):
    - Chuyển đổi dữ liệu đầu vào thành `LoginRequestModel`.
    - Gọi `AuthDataSource.login()`.
    - Nhận về `UserModel` từ DataSource.
    - Chuyển đổi `UserModel` thành `UserEntity` và trả về.
4.  **DataSource** (`data/datasources/auth_datasource.dart`):
    - Thực hiện gọi API qua `ApiClient`.
    - Trả về `UserModel` từ JSON response.

## 📏 Quy tắc Viết Code (Coding Conventions)

### 1. Định danh (Naming)

- **File & Folder**: `snake_case` (ví dụ: `auth_repository.dart`, `user_model.dart`).
- **Class & Enum**: `PascalCase` (ví dụ: `AuthRepository`, `UserModel`).
- **Variable & Function**: `camelCase` (ví dụ: `getUser`, `isLoading`).
- **Constants**: `SCREAMING_SNAKE_CASE` (ví dụ: `API_BASE_URL`).

### 2. Nguyên tắc Clean Architecture

- **Độc lập**: Domain layer không được import bất cứ thứ gì từ Data hoặc Presentation layer.
- **Dependency Rule**: Sự phụ thuộc chỉ được trỏ từ lớp ngoài vào lớp trong (UI -> Domain <- Data).
- **Entities**: Phải là các class thuần (POJO/POGO), không chứa logic JSON parsing.

### 3. Error Handling

- Sử dụng `Either<Failure, Success>` (nếu dùng dartz) hoặc cơ chế try-catch tại Repository để bắt lỗi và trả về Custom Exception/Failure defined trong Domain.
- Không để lọt Exception thô từ API ra UI.

## 📝 Hướng dẫn Phát triển Tính năng Mới (How to Write)

Để thêm một tính năng mới (ví dụ: "Lấy danh sách sản phẩm"), hãy tuân thủ quy trình sau:

1.  **Bước 1: Domain Layer**

    - Tạo `ProductEntity` trong `domain/entities/`.
    - Định nghĩa `ProductRepository` interface trong `domain/abstracts/`.
    - Tạo `GetProductsUseCase` trong `domain/usecase/`.

2.  **Bước 2: Data Layer**

    - Tạo `ProductModel` trong `data/models/` (extends Entity, thêm fromJson/toJson).
    - Thêm phương thức gọi API vào `ProductDataSource` trong `data/datasources/`.
    - Implement `ProductRepository` trong `data/repositories/` (gọi DataSource, map Model -> Entity).

3.  **Bước 3: Dependency Injection**

    - Đăng ký các class mới (DataSource, Repository, UseCase) vào container (ví dụ: `injection_container.dart` hoặc `di.dart`).

4.  **Bước 4: Presentation Layer**
    - Tạo UI trong `presentation/screens/`.
    - Sử dụng State Management (Bloc/Provider) để gọi UseCase và lắng nghe kết quả.

## 🚀 Cài đặt & Chạy ứng dụng (Setup & Run)

### Yêu cầu

- Flutter SDK (phiên bản mới nhất stable).
- Android Studio hoặc VS Code.
- Máy ảo Android/iOS hoặc thiết bị thật.

### Các lệnh thường dùng

1.  **Cài đặt thư viện**:

    ```bash
    flutter pub get
    ```

2.  **Chạy ứng dụng (Debug)**:

    ```bash
    flutter run
    ```

3.  **Build file APK (Release)**:

    ```bash
    flutter build apk --release
    ```

4.  **Chạy Code Generation** (nếu dùng build_runner cho json_serializable, freeze, v.v.):
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

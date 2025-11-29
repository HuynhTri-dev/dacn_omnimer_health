# Kiến Trúc Admin Page Frontend (React Web App)

Dự án `adminpage` được xây dựng dựa trên kiến trúc **Clean Architecture**, tương đồng với kiến trúc của Mobile App, giúp đảm bảo tính nhất quán, dễ bảo trì và mở rộng.

## 1. Tổng Quan Kiến Trúc

Hệ thống được chia thành 3 tầng chính (Layers), tách biệt rõ ràng giữa giao diện, logic nghiệp vụ và dữ liệu:

1.  **Presentation Layer (UI & Logic View)**
2.  **Domain Layer (Business Logic)**
3.  **Data Layer (Data Access)**

![Admin Architecture](../assets/admin_architect.png)
_(Lưu ý: Sơ đồ minh họa tương tự như Mobile App)_

---

## 2. Công Nghệ Sử Dụng

| Hạng mục       | Công nghệ        | Phiên bản |
| :------------- | :--------------- | :-------- |
| **Framework**  | React            | 19.x      |
| **Build Tool** | Vite             | 6.x       |
| **Language**   | TypeScript       | 5.x       |
| **Styling**    | Tailwind CSS     | 4.x       |
| **Routing**    | React Router DOM | 7.x       |
| **Linting**    | ESLint           | 9.x       |

---

## 3. Chi Tiết Các Tầng (Layers)

### 3.1. Presentation Layer (`src/presentation`)

Chịu trách nhiệm hiển thị giao diện và xử lý tương tác người dùng.

- **Pages (`/pages`)**: Các trang chính của ứng dụng (Dashboard, UsersManagement, ExerciseManagement...).
- **Components (`/components`)**: Các thành phần UI tái sử dụng (Button, Input, Table...).
- **Layout (`/layout`)**: Các khung giao diện chung (MainLayout, Sidebar, Header).
- **Hooks (`/hooks`)**: Custom hooks để tách biệt logic khỏi UI (VD: `useAuth`, `useUsers`).

### 3.2. Domain Layer (`src/domain`)

Đây là tầng trung tâm, chứa logic nghiệp vụ và các định nghĩa interface, không phụ thuộc vào framework UI hay nguồn dữ liệu cụ thể.

- **Use Cases (`/usecases`)**: Chứa các class thực thi logic nghiệp vụ cụ thể.
  - Ví dụ: `AuthUseCase`, `UserUseCase`, `ExerciseUseCase`.
  - Mỗi UseCase gọi đến Repository Interface để tương tác dữ liệu.
- **Repository Interfaces (`/repositories`)**: Định nghĩa các hợp đồng (interface) cho việc truy xuất dữ liệu.
  - Ví dụ: `IAuthRepository`, `IUserRepository`.
  - Giúp tách biệt Domain khỏi Data layer.

### 3.3. Data Layer (`src/data`)

Chịu trách nhiệm thực thi việc lấy và lưu trữ dữ liệu.

- **Services (`/services`)**: Các service xử lý giao tiếp với bên ngoài.
  - `ApiService`: Wrapper cho `fetch` API, xử lý base URL, headers, token và error handling.
- **Repository Implementations (`/models`)**: Triển khai các interface từ Domain Layer.
  - Ví dụ: `AuthRepositoryImpl`, `UserRepositoryImpl`.
  - Sử dụng `ApiService` để gọi API backend và map dữ liệu trả về thành các type/entity của ứng dụng.

### 3.4. Shared Layer (`src/shared`)

Chứa các thành phần dùng chung cho toàn bộ ứng dụng.

- **Types (`/types`)**: Định nghĩa các TypeScript types/interfaces (User, Exercise, ApiResponse...).
- **Utils (`/utils`)**: Các hàm tiện ích (format date, validate...).

---

## 4. Luồng Dữ Liệu (Data Flow)

Ví dụ: Quy trình **Lấy danh sách người dùng**

1.  **UI (Page/Component)**:
    - Component `UsersManagement` sử dụng hook hoặc gọi trực tiếp UseCase.
    - Gọi `userUseCase.getUsers()`.
2.  **Domain (UseCase)**:
    - `UserUseCase` nhận yêu cầu, có thể thực hiện thêm logic nghiệp vụ (nếu có).
    - Gọi `userRepository.getUsers()`.
3.  **Data (Repository Impl)**:
    - `UserRepositoryImpl` sử dụng `apiService`.
    - Gọi `apiService.get('/users')`.
4.  **Data (Service)**:
    - `ApiService` thực hiện HTTP GET request đến Backend API.
    - Nhận JSON response, xử lý lỗi (nếu có).
5.  **Return Path**:
    - Dữ liệu được trả về ngược lại qua các tầng: Service -> Repository -> UseCase -> UI.
    - UI cập nhật state và hiển thị danh sách.

---

## 5. Cấu Trúc Thư Mục

```
src/
├── data/                   # Data Layer
│   ├── models/             # Repository Implementations (AuthRepositoryImpl...)
│   └── services/           # API Services (ApiService...)
├── domain/                 # Domain Layer
│   ├── repositories/       # Repository Interfaces (IAuthRepository...)
│   └── usecases/           # Business Logic (AuthUseCase...)
├── presentation/           # Presentation Layer
│   ├── components/         # Reusable UI Components
│   ├── hooks/              # Custom React Hooks
│   ├── layout/             # Layout Components (Sidebar, Header...)
│   └── pages/              # Application Pages
├── shared/                 # Shared Resources
│   ├── types/              # TypeScript Definitions
│   └── utils/              # Utility Functions
├── App.tsx                 # App Entry Point & Routing
└── main.tsx                # React Root
```

## 6. Quy Tắc Phát Triển

1.  **Tuân thủ Clean Architecture**: Không gọi trực tiếp API từ Component. Phải thông qua UseCase -> Repository.
2.  **Dependency Rule**: Domain Layer không được phụ thuộc vào Data hay Presentation Layer.
3.  **Types**: Luôn định nghĩa rõ ràng TypeScript types cho props, state, và API responses.
4.  **Components**: Chia nhỏ UI thành các components tái sử dụng. Sử dụng Tailwind CSS cho styling.

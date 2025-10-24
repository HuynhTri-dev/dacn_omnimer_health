# 🧩 Project Structure Overview

## 1. Mục tiêu kiến trúc

Cấu trúc dự án được thiết kế theo hướng **Clean Architecture**, giúp:

- Dễ mở rộng, bảo trì và tái sử dụng code.
- Phân tách rõ ràng giữa các **tầng (layers)**: `domain`, `data`, `presentation`.
- Tối ưu khả năng **test**, **refactor**, và **scale** khi dự án phát triển.

---

## 2. Sơ đồ thư mục

```bash
src/
┣ app/ # Entry & Core setup
┃ ┣ context/ # Context Providers (Auth, Theme)
┃ ┣ hook/ # App-level custom hooks
┃ ┣ store/ # Redux store & slices
┃ ┗ types/ # Global types & DTOs
┣ config/ # Cấu hình Axios, env, và các config toàn cục
┣ data/
┃ ┣ api/ # API definitions (Axios-based)
┃ ┣ models/ # Data models / entities
┃ ┗ repositories/ # Repository layer (abstracted data access)
┣ domain/
┃ ┣ interfaces/ # Domain-level contracts
┃ ┣ services/ # Business logic (use cases)
┃ ┗ repositories/ # Repository interfaces for data access
┣ presentation/
┃ ┣ components/ # UI reusable components
┃ ┣ navigation/ # Navigators (Stack, Tab, Drawer)
┃ ┣ screens/ # Screens per feature
┃ ┗ theme/ # Colors, typography, spacing
┣ services/ # External services (Firebase, HealthKit, etc.)
┣ utils/ # Helpers, formatters, validators
┗ App.tsx # Root entry point
```

---

## 3. Luồng dữ liệu tổng quát

### 1. Presentation Layer (UI)

- Gồm `screens/` và `components/`.
- Nhiệm vụ: **hiển thị dữ liệu và nhận input từ người dùng**.
- Gọi đến các **domain services (use cases)** để thực thi logic.

**Ví dụ luồng:**

User Action (Button press)
↓
Screen gọi Domain Service (use case)
↓
Domain gọi Repository interface
↓
Data layer thực hiện gọi API hoặc DB
↓
Response trả về Domain → UI hiển thị kết quả

markdown
Sao chép mã

---

### 2. Domain Layer

- Nằm giữa `presentation` và `data`, đảm nhận **logic nghiệp vụ (business logic)**.
- Không phụ thuộc framework (React, Axios, Firebase...).
- Bao gồm:
  - `services/`: Chứa các **use cases**, ví dụ `RegisterUserService`, `FetchExerciseService`.
  - `interfaces/`: Định nghĩa **interface** cho repository hoặc các đối tượng dịch vụ.
  - `repositories/`: Interface trung gian giữa domain và data layer.

**Ví dụ:**

```ts
// domain/repositories/IUserRepository.ts
export interface IUserRepository {
  register(userData: User): Promise<User>;
  getProfile(id: string): Promise<User>;
}
```

### 3. Data Layer

Xử lý giao tiếp dữ liệu từ API, database, hoặc local storage.

Bao gồm:

api/: Gọi Axios hoặc fetch đến server.

models/: Định nghĩa entity tương ứng với dữ liệu trả về.

repositories/: Triển khai interface từ domain/repositories.

Ví dụ:

```ts
Sao chép mã
// data/repositories/UserRepository.ts
import { IUserRepository } from "../../domain/repositories/IUserRepository";
import { api } from "../api/axiosInstance";

export class UserRepository implements IUserRepository {
async register(data) {
const res = await api.post("/user/register", data);
return res.data;
}
}
```

### 4. App Layer

Xử lý entry logic, như context, Redux store, global hooks.

Cung cấp các providers (Auth, Theme, Store) cho toàn app.

App.tsx là entry chính — nơi khởi tạo navigation, context, store, theme.

### 5. Services Layer

Tích hợp các dịch vụ bên ngoài như:

Firebase (auth, push notifications)

Apple HealthKit / Google Fit

Cloudflare / Storage SDKs

### 6. Utils & Config

utils/: Chứa các hàm tiện ích, định dạng dữ liệu, validate, logging.

config/: Cấu hình Axios, base URL, token interceptor, hoặc .env.

## 4. Ví dụ luồng xử lý cụ thể

Tình huống: Người dùng đăng ký tài khoản.

```css
Sao chép mã
[Screen: RegisterScreen]
↓ (gọi)
[Domain: RegisterUserService]
↓ (sử dụng)
[Repository Interface: IUserRepository]
↓ (được implement bởi)
[Data: UserRepository → Axios API]
↓ (response)
Trả về user data → UI cập nhật store & hiển thị thông báo thành công.
```

## 5. Quy tắc coding style (gợi ý)

File đặt tên PascalCase cho component, class (UserRepository.ts, AuthContext.tsx).

camelCase cho function, biến (getUserInfo, handleSubmit).

snake_case chỉ dùng cho file JSON hoặc constant keys.

Mỗi service hoặc repository chỉ làm 1 nhiệm vụ duy nhất.

Không gọi API trực tiếp trong UI (screens).

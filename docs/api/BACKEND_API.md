# API Routes - OmniMer Health Server

Tài liệu tổng hợp tất cả các API endpoints trong hệ thống OmniMer Health Server.

**Base URL**: `/api/v1`

---

## 🔐 Authentication & Authorization

### Auth (`/auth`)

| Method | Endpoint                 | Description                       | Auth Required |
| ------ | ------------------------ | --------------------------------- | ------------- |
| POST   | `/auth/register`         | Đăng ký tài khoản mới             | ❌            |
| POST   | `/auth/login`            | Đăng nhập                         | ❌            |
| POST   | `/auth/new-access-token` | Làm mới access token              | ❌            |
| GET    | `/auth/`                 | Lấy thông tin người dùng hiện tại | ✅            |

### User (`/user`)

| Method | Endpoint    | Description                     | Auth Required |
| ------ | ----------- | ------------------------------- | ------------- |
| GET    | `/user/`    | Lấy danh sách tất cả người dùng | ❌            |
| PUT    | `/user/:id` | Cập nhật thông tin người dùng   | ✅            |

### Permission (`/permission`)

| Method | Endpoint          | Description                 | Auth Required |
| ------ | ----------------- | --------------------------- | ------------- |
| GET    | `/permission/`    | Lấy danh sách tất cả quyền  | ❌            |
| POST   | `/permission/`    | Tạo quyền mới               | ✅            |
| GET    | `/permission/:id` | Lấy thông tin quyền theo ID | ❌            |
| PUT    | `/permission/:id` | Cập nhật quyền              | ✅            |
| DELETE | `/permission/:id` | Xóa quyền                   | ✅            |

### Role (`/role`)

| Method | Endpoint              | Description                                 | Auth Required |
| ------ | --------------------- | ------------------------------------------- | ------------- |
| GET    | `/role/`              | Lấy danh sách tất cả vai trò                | ✅            |
| GET    | `/role/without-admin` | Lấy danh sách vai trò (không bao gồm admin) | ❌            |
| POST   | `/role/`              | Tạo vai trò mới                             | ❌            |
| GET    | `/role/:id`           | Lấy thông tin vai trò theo ID               | ❌            |
| PUT    | `/role/:id`           | Cập nhật vai trò                            | ✅            |
| PATCH  | `/role/:id`           | Cập nhật danh sách quyền của vai trò        | ✅            |
| DELETE | `/role/:id`           | Xóa vai trò                                 | ❌            |

---

## 👤 Health Profile & Goals

### Health Profile (`/health-profile`)

| Method | Endpoint                       | Description                          | Auth Required |
| ------ | ------------------------------ | ------------------------------------ | ------------- |
| GET    | `/health-profile/`             | Lấy tất cả hồ sơ sức khỏe (Admin)    | ❌            |
| POST   | `/health-profile/`             | Tạo hồ sơ sức khỏe mới               | ✅            |
| GET    | `/health-profile/latest`       | Lấy hồ sơ sức khỏe mới nhất của user | ✅            |
| GET    | `/health-profile/user/:userId` | Lấy tất cả hồ sơ theo userId         | ✅            |
| GET    | `/health-profile/:id`          | Lấy hồ sơ sức khỏe theo ID           | ❌            |
| PUT    | `/health-profile/:id`          | Cập nhật hồ sơ sức khỏe              | ✅            |
| DELETE | `/health-profile/:id`          | Xóa hồ sơ sức khỏe                   | ✅            |

### Goal (`/goal`)

| Method | Endpoint    | Description                    | Auth Required |
| ------ | ----------- | ------------------------------ | ------------- |
| GET    | `/goal/`    | Lấy danh sách tất cả mục tiêu  | ❌            |
| POST   | `/goal/`    | Tạo mục tiêu mới               | ✅            |
| GET    | `/goal/:id` | Lấy thông tin mục tiêu theo ID | ❌            |
| PUT    | `/goal/:id` | Cập nhật mục tiêu              | ✅            |
| DELETE | `/goal/:id` | Xóa mục tiêu                   | ✅            |

---

## 💪 Exercise Management

### Body Part (`/body-part`)

| Method | Endpoint         | Description                         | Auth Required |
| ------ | ---------------- | ----------------------------------- | ------------- |
| GET    | `/body-part/`    | Lấy danh sách tất cả bộ phận cơ thể | ❌            |
| POST   | `/body-part/`    | Tạo bộ phận cơ thể mới              | ✅            |
| PUT    | `/body-part/:id` | Cập nhật bộ phận cơ thể             | ✅            |
| DELETE | `/body-part/:id` | Xóa bộ phận cơ thể                  | ✅            |

### Equipment (`/equipment`)

| Method | Endpoint         | Description                   | Auth Required |
| ------ | ---------------- | ----------------------------- | ------------- |
| GET    | `/equipment/`    | Lấy danh sách tất cả thiết bị | ❌            |
| POST   | `/equipment/`    | Tạo thiết bị mới              | ✅            |
| PUT    | `/equipment/:id` | Cập nhật thiết bị             | ✅            |
| DELETE | `/equipment/:id` | Xóa thiết bị                  | ✅            |

### Muscle (`/muscle`)

| Method | Endpoint      | Description                   | Auth Required |
| ------ | ------------- | ----------------------------- | ------------- |
| GET    | `/muscle/`    | Lấy danh sách tất cả nhóm cơ  | ❌            |
| POST   | `/muscle/`    | Tạo nhóm cơ mới               | ✅            |
| GET    | `/muscle/:id` | Lấy thông tin nhóm cơ theo ID | ❌            |
| PUT    | `/muscle/:id` | Cập nhật nhóm cơ              | ✅            |
| DELETE | `/muscle/:id` | Xóa nhóm cơ                   | ✅            |

### Exercise Type (`/exercise-type`)

| Method | Endpoint             | Description                        | Auth Required |
| ------ | -------------------- | ---------------------------------- | ------------- |
| GET    | `/exercise-type/`    | Lấy danh sách tất cả loại bài tập  | ❌            |
| POST   | `/exercise-type/`    | Tạo loại bài tập mới               | ✅            |
| GET    | `/exercise-type/:id` | Lấy thông tin loại bài tập theo ID | ❌            |
| PUT    | `/exercise-type/:id` | Cập nhật loại bài tập              | ✅            |
| DELETE | `/exercise-type/:id` | Xóa loại bài tập                   | ✅            |

**Exercise Types**: Cardio, Strength, HIIT, Flexibility, Balance, Mobility, Endurance, Functional, MindBody, SportSpecific, Custom

### Exercise Category (`/exercise-category`)

| Method | Endpoint                 | Description                           | Auth Required |
| ------ | ------------------------ | ------------------------------------- | ------------- |
| GET    | `/exercise-category/`    | Lấy danh sách tất cả danh mục bài tập | ❌            |
| POST   | `/exercise-category/`    | Tạo danh mục bài tập mới              | ✅            |
| GET    | `/exercise-category/:id` | Lấy thông tin danh mục theo ID        | ❌            |
| PUT    | `/exercise-category/:id` | Cập nhật danh mục bài tập             | ✅            |
| DELETE | `/exercise-category/:id` | Xóa danh mục bài tập                  | ✅            |

### Exercise (`/exercise`)

| Method | Endpoint        | Description                                    | Auth Required |
| ------ | --------------- | ---------------------------------------------- | ------------- |
| GET    | `/exercise/`    | Lấy danh sách tất cả bài tập                   | ❌            |
| POST   | `/exercise/`    | Tạo bài tập mới (có thể upload image & video)  | ✅            |
| GET    | `/exercise/:id` | Lấy thông tin bài tập theo ID                  | ❌            |
| PUT    | `/exercise/:id` | Cập nhật bài tập (có thể upload image & video) | ✅            |
| DELETE | `/exercise/:id` | Xóa bài tập                                    | ✅            |

### Exercise Rating (`/exercise-rating`)

| Method | Endpoint               | Description                           | Auth Required |
| ------ | ---------------------- | ------------------------------------- | ------------- |
| GET    | `/exercise-rating/`    | Lấy danh sách tất cả đánh giá bài tập | ❌            |
| POST   | `/exercise-rating/`    | Tạo đánh giá bài tập mới              | ✅            |
| GET    | `/exercise-rating/:id` | Lấy thông tin đánh giá theo ID        | ❌            |
| PUT    | `/exercise-rating/:id` | Cập nhật đánh giá bài tập             | ✅            |
| DELETE | `/exercise-rating/:id` | Xóa đánh giá bài tập                  | ✅            |

---

## 🏋️ Workout Management

### Workout Template (`/workout-template`)

| Method | Endpoint                 | Description                       | Auth Required |
| ------ | ------------------------ | --------------------------------- | ------------- |
| GET    | `/workout-template/`     | Lấy danh sách tất cả mẫu workout  | ✅            |
| POST   | `/workout-template/`     | Tạo mẫu workout mới               | ✅            |
| GET    | `/workout-template/user` | Lấy mẫu workout của user hiện tại | ✅            |
| GET    | `/workout-template/:id`  | Lấy thông tin mẫu workout theo ID | ✅            |
| PUT    | `/workout-template/:id`  | Cập nhật mẫu workout              | ✅            |
| DELETE | `/workout-template/:id`  | Xóa mẫu workout                   | ✅            |

### Workout (`/workout`)

| Method | Endpoint                         | Description                   | Auth Required |
| ------ | -------------------------------- | ----------------------------- | ------------- |
| GET    | `/workout/`                      | Lấy danh sách tất cả workout  | ✅            |
| POST   | `/workout/`                      | Tạo workout mới               | ✅            |
| GET    | `/workout/user`                  | Lấy workout của user hiện tại | ✅            |
| POST   | `/workout/template/:templateId`  | Tạo workout từ template       | ✅            |
| GET    | `/workout/:id`                   | Lấy thông tin workout theo ID | ✅            |
| PUT    | `/workout/:id`                   | Cập nhật workout              | ✅            |
| PATCH  | `/workout/:id/start`             | Bắt đầu workout               | ✅            |
| PATCH  | `/workout/:id/complete-set`      | Hoàn thành một set            | ✅            |
| PATCH  | `/workout/:id/complete-exercise` | Hoàn thành một bài tập        | ✅            |
| PATCH  | `/workout/:id/finish`            | Kết thúc workout              | ✅            |
| DELETE | `/workout/:id`                   | Xóa workout                   | ✅            |

### Workout Feedback (`/workout-feedback`)

| Method | Endpoint                               | Description                           | Auth Required |
| ------ | -------------------------------------- | ------------------------------------- | ------------- |
| GET    | `/workout-feedback/`                   | Lấy danh sách tất cả phản hồi workout | ✅            |
| POST   | `/workout-feedback/`                   | Tạo phản hồi workout mới              | ✅            |
| GET    | `/workout-feedback/workout/:workoutId` | Lấy phản hồi theo workoutId           | ✅            |
| GET    | `/workout-feedback/:id`                | Lấy thông tin phản hồi theo ID        | ✅            |
| PUT    | `/workout-feedback/:id`                | Cập nhật phản hồi workout             | ✅            |
| DELETE | `/workout-feedback/:id`                | Xóa phản hồi workout                  | ✅            |

---

## ⌚ Device Integration

### Watch Log (`/watch-log`)

| Method | Endpoint          | Description                            | Auth Required |
| ------ | ----------------- | -------------------------------------- | ------------- |
| GET    | `/watch-log/`     | Lấy danh sách tất cả log từ smartwatch | ✅            |
| POST   | `/watch-log/`     | Tạo log mới từ smartwatch              | ✅            |
| POST   | `/watch-log/many` | Tạo nhiều log cùng lúc (bulk insert)   | ✅            |
| PUT    | `/watch-log/:id`  | Cập nhật log                           | ✅            |
| DELETE | `/watch-log/:id`  | Xóa log                                | ✅            |
| DELETE | `/watch-log/`     | Xóa nhiều log cùng lúc (bulk delete)   | ✅            |

---

## 🤖 AI Recommendations

### RAG - AI (`/ai`)

| Method | Endpoint        | Description                         | Auth Required |
| ------ | --------------- | ----------------------------------- | ------------- |
| GET    | `/ai/recommend` | Lấy gợi ý workout cá nhân hóa từ AI | ✅            |

---

## � Charts & Statistics

### Chart (`/chart`)

| Method | Endpoint                     | Description                                      | Auth Required |
| ------ | ---------------------------- | ------------------------------------------------ | ------------- |
| GET    | `/chart/weight-progress`     | Lấy biểu đồ thay đổi cân nặng theo thời gian     | ✅            |
| GET    | `/chart/workout-frequency`   | Lấy biểu đồ tần suất tập luyện (theo tuần/tháng) | ✅            |
| GET    | `/chart/calories-burned`     | Lấy biểu đồ lượng calo tiêu thụ theo thời gian   | ✅            |
| GET    | `/chart/muscle-distribution` | Lấy biểu đồ phân bố nhóm cơ đã tập luyện         | ✅            |
| GET    | `/chart/goal-progress`       | Lấy biểu đồ trạng thái hoàn thành mục tiêu       | ✅            |

### Admin Chart (`/admin-chart`)

| Method | Endpoint                         | Description                                           | Auth Required |
| ------ | -------------------------------- | ----------------------------------------------------- | ------------- |
| GET    | `/admin-chart/user-growth`       | Biểu đồ tăng trưởng người dùng (daily/weekly/monthly) | ✅ (Admin)    |
| GET    | `/admin-chart/workout-activity`  | Biểu đồ hoạt động tập luyện (daily/weekly/monthly)    | ✅ (Admin)    |
| GET    | `/admin-chart/popular-exercises` | Biểu đồ bài tập phổ biến nhất (limit=5)               | ✅ (Admin)    |
| GET    | `/admin-chart/summary`           | Tổng quan hệ thống (Total Users, Workouts, Exercises) | ✅ (Admin)    |

---

## �📝 Notes

### Authentication

- **Bearer Token**: Sử dụng JWT token trong header `Authorization: Bearer <token>`
- **Access Token**: Có thời hạn 1 giờ
- **Refresh Token**: Có thời hạn 7 ngày

### File Upload

- Các endpoint hỗ trợ upload file sử dụng `multipart/form-data`
- **Image Upload**: body-part, equipment, muscle, user, auth (register)
- **Image & Video Upload**: exercise

### Pagination & Filtering

- Hầu hết các GET endpoints hỗ trợ query parameters để filter và phân trang
- Ví dụ: `?page=1&limit=10&sort=createdAt&order=desc`

### Response Format

Tất cả responses đều có format:

```json
{
  "message": "Success message",
  "data": {
    /* response data */
  }
}
```

### Error Format

```json
{
  "error": "Error message",
  "statusCode": 400
}
```

---

## 🔗 API Documentation

Truy cập Swagger UI để xem chi tiết và test API:

- **Development**: `http://localhost:5000/api-docs`
- **Production**: `https://api.omnimer-health.com/api-docs`

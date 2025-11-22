# Báo cáo lỗi và đề xuất cải thiện Codebase

Tài liệu này liệt kê các vấn đề được tìm thấy trong `lib/domain` và `lib/data`, đặc biệt liên quan đến việc gọi API và cấu trúc dữ liệu cho module Exercise.

## 1. Vấn đề về gọi API và Bộ lọc (Filter)

**Vị trí:** `lib/data/datasources/exercise_datasource.dart` và `lib/domain/repositories/exercise_repository_abs.dart`

**Hiện trạng:**

- Hàm `getExercises()` hiện tại đang lấy toàn bộ danh sách bài tập mà không có tham số lọc (filter) hoặc phân trang.
- Việc xử lý lọc đang không được thực hiện ở phía API hoặc không tận dụng được `QueryBuilder`.

**Yêu cầu sửa đổi:**

- **Quy trình đúng:** Cần lấy danh sách các dữ liệu dùng cho bộ lọc (ví dụ: danh sách cơ bắp, loại bài tập, thiết bị...) từ API trước.
- **Sử dụng QueryBuilder:** Sau khi có dữ liệu bộ lọc, sử dụng `lib/utils/query_builder.dart` để xây dựng các tham số query chuẩn (filter, sort, search) và gửi lên API.
- Hàm `getExercises` cần nhận tham số là `QueryBuilder` hoặc các tham số tương đương để truyền vào API.

## 2. Thiếu Phân trang (Pagination)

**Vị trí:** `lib/data/datasources/exercise_datasource.dart`

**Hiện trạng:**

- Các API call hiện tại thiếu tham số `limit` và `page`. Điều này sẽ gây vấn đề về hiệu năng khi dữ liệu lớn.

**Yêu cầu sửa đổi:**

- Bổ sung `limit` và `page` vào `QueryBuilder` và đảm bảo chúng được gửi kèm trong request API.
- Default `limit` và `page` nên được định nghĩa trong `AppConstants` (như đã thấy trong `QueryBuilder`).

## 3. Tách biệt Model và Entity cho `getById` và `getAll`

**Vị trí:** `lib/data/models/exercise` và `lib/domain/entities`

**Hiện trạng & Đề xuất:**

- Cần đảm bảo sự tách biệt rõ ràng giữa dữ liệu lấy danh sách (`getAll`) và dữ liệu chi tiết (`getById`).
- **ExerciseListModel / ExerciseListEntity:** Dùng cho màn hình danh sách. Chỉ chứa các thông tin cơ bản (ID, tên, ảnh thumbnail, rating...). Không nên chứa thông tin quá chi tiết để giảm tải payload.
- **ExerciseDetailModel / ExerciseDetailEntity:** Dùng cho màn hình chi tiết. Chứa đầy đủ thông tin (hướng dẫn, video, các cơ bắp liên quan chi tiết...).
- Việc tách biệt này giúp tối ưu hóa băng thông và hiệu năng ứng dụng.

---

_Tài liệu này được tạo tự động dựa trên yêu cầu review code._

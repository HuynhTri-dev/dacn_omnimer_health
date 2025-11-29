Bước 1: Người dùng Đăng ký/Đăng nhập (Frontend)
Người dùng nhập email và mật khẩu (hoặc chỉ email nếu là luồng đăng nhập không mật khẩu).

Flutter App gửi thông tin này đến endpoint /api/register (hoặc tương tự) trên Backend Server của bạn.

Bước 2: Tạo Token và Lưu Trạng thái (Backend)
Backend Server:

Lưu thông tin người dùng vào cơ sở dữ liệu với trạng thái mặc định là isVerified = false.

Tạo một Token xác minh duy nhất, có thời hạn (ví dụ: một chuỗi JWT hoặc một UUID ngẫu nhiên).

Lưu Token này vào cơ sở dữ liệu, liên kết với ID người dùng.

Bước 3: Gửi Email Xác nhận (Backend + Email Service)
Backend Server sử dụng Email Service để gửi một email đến địa chỉ của người dùng.

Email này chứa một đường link xác nhận có cấu trúc như sau:

https://<Tên*miền*ứng_dụng>/verify?token=<Token_xác_minh>
Bước 4: Người dùng Nhấp vào Link (Frontend/Web)
Người dùng mở email và nhấp vào đường link xác nhận.

Trình duyệt của người dùng được chuyển hướng đến URL đã tạo ở Bước 3.

Bước 5: Xác minh Token (Backend)
Backend Server nhận yêu cầu truy cập đường link /verify?token=....

Máy chủ:

Kiểm tra tính hợp lệ: Tìm Token trong cơ sở dữ liệu.

Kiểm tra thời hạn: Đảm bảo Token chưa hết hạn.

Cập nhật trạng thái: Nếu Token hợp lệ, máy chủ cập nhật trạng thái người dùng trong cơ sở dữ liệu thành isVerified = true.

Bước 6: Hoàn tất Xác thực (Backend & Frontend)
Backend Server hiển thị một trang xác nhận thành công cho người dùng (ví dụ: "Tài khoản của bạn đã được xác minh thành công!").

Thông báo cho Backend: Vì việc cập nhật trạng thái đã xảy ra ở Bước 5, nên Backend đã biết người dùng đã xác thực.

Flutter App: Khi người dùng quay lại ứng dụng để đăng nhập, ứng dụng sẽ gọi API và Backend sẽ kiểm tra trạng thái isVerified trước khi cho phép người dùng truy cập các tính năng cốt lõi.

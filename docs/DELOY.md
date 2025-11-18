Hướng Dẫn Triển Khai Ứng Dụng Đa Dịch Vụ Lên VPS Bằng Docker ComposeHướng dẫn này áp dụng cho dự án của bạn (OmniMer Health Backend và AI Service) sử dụng các Dockerfile đã có và file docker-compose.yml (đã bỏ DB/Redis local).Pha 1: Chuẩn bị Môi trường VPSBạn cần đăng nhập vào VPS (thường qua SSH) và cài đặt Docker cùng Docker Compose.1.1. Cài đặt Docker Engine(Áp dụng cho hệ điều hành Ubuntu/Debian phổ biến. Nếu bạn dùng OS khác, hãy tham khảo tài liệu Docker.)# 1. Cập nhật gói hệ thống
sudo apt update
sudo apt upgrade -y

# 2. Cài đặt các gói cần thiết

sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

# 3. Thêm GPG key chính thức của Docker

curl -fsSL [https://download.docker.com/linux/ubuntu/gpg](https://download.docker.com/linux/ubuntu/gpg) | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 4. Thêm kho lưu trữ Docker

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] [https://download.docker.com/linux/ubuntu](https://download.docker.com/linux/ubuntu) $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Cài đặt Docker Engine

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y

# 6. Thêm user vào nhóm docker để chạy lệnh không cần sudo

sudo usermod -aG docker $USER

# Khởi động lại phiên SSH hoặc chạy lệnh "newgrp docker" để áp dụng ngay lập tức

1.2. Cài đặt Docker Compose# Tải về phiên bản Docker Compose ổn định (ví dụ: v2.20.2)

# Bạn nên kiểm tra phiên bản mới nhất trên trang GitHub của Docker Compose

sudo curl -L "[https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname](https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname) -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Cấp quyền thực thi

sudo chmod +x /usr/local/bin/docker-compose

# Tạo symlink (tùy chọn)

sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Kiểm tra phiên bản

docker-compose --version
Pha 2: Chuyển giao Mã nguồn lên VPSCó hai phương pháp chính:Phương pháp 2.1: Dùng Git (Được khuyến nghị)Trên máy tính cục bộ (Local): Đẩy toàn bộ mã nguồn lên kho Git (GitHub, GitLab, v.v.).Trên VPS:# Cài đặt Git nếu chưa có
sudo apt install git -y

# Clone repository

git clone <URL_repository_của_bạn>
cd <ten_thu_muc_du_an>
Tạo file môi trường: Tạo và điền nội dung vào các file môi trường cần thiết (ví dụ: .env trong thư mục omnimer_health_server/) trên VPS, vì các file này thường không được commit lên Git.# Ví dụ:
nano omnimer_health_server/.env

# Điền các biến môi trường cho Cloud DB/Redis, v.v.

Phương pháp 2.2: Dùng SCP/SFTPSử dụng các công cụ như WinSCP (Windows) hoặc lệnh scp (Linux/macOS) để copy toàn bộ thư mục dự án lên VPS.Pha 3: Triển khai và Chạy ứng dụngĐây là bước cuối cùng, nơi Docker sẽ đọc docker-compose.yml để xây dựng image và khởi chạy các container.Di chuyển đến thư mục gốc của dự án (chứa file docker-compose.yml).cd /path/to/DACN_OMNIMER_HEALTH
Build và Khởi chạy ứng dụng:Sử dụng lệnh sau để xây dựng các Docker image từ Dockerfile tương ứng, và sau đó khởi động tất cả các dịch vụ (backend, ai_service, db, redis - nếu bạn chưa xóa).# Lệnh build và chạy:
docker-compose up -d --build
up: Khởi động các services.-d: Chạy services ở chế độ nền (detached mode).--build: Bắt buộc build lại các image từ đầu (rất quan trọng khi triển khai lần đầu hoặc cập nhật code).Kiểm tra Trạng thái:docker-compose ps
Kiểm tra cột State, tất cả các dịch vụ nên ở trạng thái Up.Xem Logs (Kiểm tra lỗi):docker-compose logs -f
Sử dụng lệnh này để xem nhật ký của tất cả các container trong thời gian thực, giúp bạn gỡ lỗi nếu có vấn đề.Cập nhật code và triển khai lại:Khi bạn cập nhật code (ví dụ: git pull trên VPS), bạn chỉ cần chạy lại lệnh:docker-compose up -d --build
Docker Compose sẽ chỉ build lại image của dịch vụ có code thay đổi.🛠️ Bước bổ sung: Cấu hình Reverse Proxy (Quan trọng)Mặc dù các service của bạn chạy trên các cổng như 8000 (Backend) và 8888 (AI), bạn không nên mở trực tiếp các cổng này ra Internet. Thay vào đó, bạn nên sử dụng Nginx (hoặc Caddy) làm Reverse Proxy để:Bảo mật: Chạy các service sau một lớp bảo vệ.SSL/TLS: Dễ dàng cấp phát và quản lý chứng chỉ HTTPS (Let's Encrypt).Cổng mặc định: Cho phép người dùng truy cập qua cổng 80/443 tiêu chuẩn.

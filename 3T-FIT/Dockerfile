# Giai đoạn Build Image cho AI Service (FastAPI)

FROM python:3.10-slim

# Đặt thư mục làm việc chính là thư mục gốc của dự án AI
# Giả định thư mục build context là ./3T-FIT (như trong docker-compose)
WORKDIR /app

# 1. Cài đặt Dependencies
# Di chuyển vào thư mục code chính nếu requirements.txt nằm ở đó,
# nhưng ta giữ nó ở gốc /app để dễ quản lý.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2. Sao chép Mã nguồn
# Sao chép toàn bộ mã nguồn vào thư mục làm việc /app
COPY . .

# 3. Cổng và Lệnh khởi chạy
# FastAPI sẽ chạy trên cổng 8888
EXPOSE 8888

# Sử dụng Uvicorn để chạy ứng dụng FastAPI.
# Cấu trúc lệnh: uvicorn [đường_dẫn_module]:[tên_biến_FastAPI_app] --host 0.0.0.0 --port 8888
# Đường dẫn module là: ai_server.app.main
# Tên biến FastAPI app là: app
CMD ["uvicorn", "ai_server.app.main:app", "--host", "0.0.0.0", "--port", "8888"]
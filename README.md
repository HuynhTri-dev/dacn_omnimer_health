# OmniMer Health

A Personal Health Management & AI-driven Fitness Recommendation System
(Built with Flutter, Node.js TypeScript, Python DNN Model, and React Admin Dashboard)

---

## 1. Overview

**OmniMer Health** là nền tảng quản lý sức khỏe cá nhân và gợi ý bài tập thông minh. Hệ thống kết hợp dữ liệu từ thiết bị đeo, nhật ký người dùng và mô hình AI để đưa ra các khuyến nghị tập luyện cá nhân hóa.

**Mục tiêu:**

- Thu thập và phân tích dữ liệu sức khỏe (bước chân, nhịp tim, giấc ngủ, calories).
- Gợi ý bài tập và lộ trình luyện tập phù hợp với thể trạng và mục tiêu.
- Cung cấp công cụ quản lý cho quản trị viên.

---

## 2. System Architecture

```mermaid
graph TD
    User[Mobile App User] -->|Flutter App| API_Gateway
    Admin[Admin User] -->|React Admin Dashboard| API_Gateway

    subgraph "Backend Services"
        API_Gateway[Node.js Server (Port 8000)]
        AI_Service[AI Server (Port 8888)]
        DB[(MongoDB/PostgreSQL)]
        Cache[(Redis)]
    end

    API_Gateway -->|REST API| DB
    API_Gateway -->|REST API| Cache
    API_Gateway -->|HTTP Request| AI_Service

    AI_Service -->|Inference| API_Gateway
```

---

## 3. Tech Stack

### Mobile App (`omnihealthmobileflutter`)

- **Framework:** Flutter (Dart)
- **State Management:** Bloc / Cubit
- **Storage:** Flutter Secure Storage, Shared Preferences
- **Integration:** HealthKit, Google Fit

### Backend Server (`omnimer_health_server`)

- **Runtime:** Node.js
- **Language:** TypeScript
- **Framework:** Express.js
- **Database:** MongoDB / PostgreSQL
- **Caching:** Redis
- **Docs:** Swagger OpenAPI

### AI Service (`3T-FIT`)

- **Language:** Python
- **Framework:** FastAPI
- **Libraries:** PyTorch, Pandas, Scikit-learn, NumPy
- **Model:** DNN (Deep Neural Network) for recommendation

### Admin Dashboard (`adminpage`)

- **Framework:** React (Vite)
- **Language:** TypeScript/JavaScript
- **Styling:** CSS/Tailwind (if applicable)

---

## 4. Folder Structure

```
dacn_omnimer_health/
│
├── omnihealthmobileflutter/    # Flutter Mobile Application
│   ├── lib/
│   └── pubspec.yaml
│
├── omnimer_health_server/      # Node.js Backend API
│   ├── src/
│   ├── Dockerfile
│   └── package.json
│
├── 3T-FIT/                     # Python AI Server
│   ├── ai_server/
│   ├── Dockerfile
│   └── requirements.txt
│
├── adminpage/                  # Admin Dashboard (React/Vite)
│   ├── src/
│   └── package.json
│
├── exercises/                  # Exercise Database (JSON)
│
├── docker-compose.yml          # Docker Composition
└── README.md                   # Project Documentation
```

---

## 5. Getting Started

### Option 1: Run with Docker Compose (Recommended for Backend & AI)

Yêu cầu: Đã cài đặt Docker và Docker Compose.

1. **Cấu hình môi trường:**

   - Tạo file `.env` trong `omnimer_health_server/` (copy từ `.env.example`).
   - Cập nhật các biến môi trường cần thiết (DB URI, Redis Host, v.v.).

2. **Khởi chạy services:**
   Tại thư mục gốc của dự án:

   ```bash
   docker-compose up --build
   ```

   - **Backend Server:** http://localhost:8000
   - **AI Server:** http://localhost:8888
   - **Swagger Docs:** http://localhost:8000/api-docs

### Option 2: Run Manually

#### 1. Backend Server (Node.js)

```bash
cd omnimer_health_server
npm install
# Development mode
npm run dev
# Production build
# npx tsc && node dist/server.js
```

Server chạy tại: `http://localhost:5000` (hoặc port trong .env)

#### 2. AI Server (Python)

```bash
cd 3T-FIT
# Tạo virtualenv (khuyến nghị)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

pip install -r requirements.txt
# Chạy server
uvicorn ai_server.app.main:app --host 0.0.0.0 --port 8888 --reload
```

Server chạy tại: `http://localhost:8888`

#### 3. Admin Dashboard (React)

```bash
cd adminpage
npm install
npm run dev
```

Truy cập tại đường dẫn hiển thị trên terminal (thường là `http://localhost:5173`).

#### 4. Mobile App (Flutter)

```bash
cd omnihealthmobileflutter
flutter pub get
flutter run
```

---

## 6. API Documentation

Hệ thống cung cấp tài liệu API qua Swagger UI.
Sau khi khởi chạy Backend Server, truy cập:

```
http://localhost:8000/api-docs
```

## 7. AI Model Features

Mô hình AI (`3T-FIT`) cung cấp các chức năng:

- **Dự đoán Calories:** Dựa trên thông tin cá nhân và cường độ tập luyện.
- **Gợi ý bài tập:** Đề xuất bài tập dựa trên nhóm cơ và mục tiêu.
- **Phân vùng nhịp tim (HR Zone):** Tính toán vùng nhịp tim tối ưu.

---

## 8. License

This project is licensed under a **Commercial Proprietary License**.
All rights reserved.

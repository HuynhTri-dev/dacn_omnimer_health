# OmniMer Health – Mobile User Architecture Guide

## 1. Mục tiêu kiến trúc

Tài liệu này mô tả **nguyên lý và cấu trúc phát triển chuẩn** cho ứng dụng `mobile_user` của dự án **OmniMer Health**.  
Mục tiêu: đảm bảo code **dễ mở rộng, dễ bảo trì, dễ test** và rõ ràng trong phân chia trách nhiệm giữa các dev.

---

## 2. Tổng quan kiến trúc

Kiến trúc được xây theo hướng **Feature-based + Clean Architecture**.  
Mỗi module (feature) là **một khối độc lập** gồm:

- Giao diện (screens, components)
- Logic (hooks, store)
- Giao tiếp backend (api)

Không có dependency vòng tròn giữa các module.

---

## 3. Cấu trúc thư mục

```
src/
├── app/                  # Entry point, navigation, provider
│   ├── navigation/       # Stack, Tab, Drawer Navigators
│   └── providers/        # Theme, Auth, AI Context
│
├── features/             # Các module chức năng độc lập
│   ├── auth/             # Đăng nhập, đăng ký, quên mật khẩu
│   ├── health/           # Dữ liệu sức khỏe, biểu đồ
│   ├── ai/               # Chatbot, gợi ý AI
│   └── profile/          # Hồ sơ cá nhân
│
├── services/             # Kết nối API và hệ thống bên ngoài
│   ├── apiClient.ts      # axios config chung
│   ├── firebase.ts
│   ├── storage.ts
│   └── notification.ts
│
├── store/                # State management (Zustand / Redux)
│   ├── useAuthStore.ts
│   ├── useHealthStore.ts
│   └── useThemeStore.ts
│
├── hooks/                # Hooks dùng chung (custom logic)
│   ├── useFetch.ts
│   ├── useDebounce.ts
│   └── useNetwork.ts
│
├── utils/                # Hàm tiện ích, constant, validate
│   ├── constants.ts
│   ├── formatter.ts
│   ├── validator.ts
│   └── date.ts
│
├── assets/               # Ảnh, icon, font
│
└── types/                # Kiểu dữ liệu (TypeScript)
```

---

## 4. Nguyên lý tổ chức

### 4.1. Mỗi feature độc lập

- Mọi phần liên quan đến chức năng (auth, health, profile...) **phải nằm gọn trong folder riêng**.
- Không được import chéo giữa các feature.
- Nếu cần chia sẻ logic hoặc UI → đưa vào `hooks/` hoặc `components/common/`.

### 4.2. Layer logic rõ ràng

```
UI (screens/components)
↓
Hook (useXxx.ts)
↓
Service/API
↓
Store (Zustand/Redux)
```

### 4.3. Nguyên tắc import

- Dùng alias trong `tsconfig.json`:
  ```json
  {
    "compilerOptions": {
      "paths": {
        "@/*": ["src/*"],
        "@features/*": ["src/features/*"]
      }
    }
  }
  ```
- Import luôn từ alias, không dùng đường dẫn tương đối `../../`.

### 4.4. Quy tắc đặt tên

| Loại file | Quy tắc đặt tên       | Ví dụ                      |
| --------- | --------------------- | -------------------------- |
| Screen    | PascalCase + “Screen” | `HealthOverviewScreen.tsx` |
| Component | PascalCase            | `HealthCard.tsx`           |
| Hook      | camelCase + “use”     | `useHealthData.ts`         |
| API       | lowercase + `.api.ts` | `health.api.ts`            |
| Store     | `use<Name>Store.ts`   | `useAuthStore.ts`          |

---

## 5. Quản lý API

Tất cả API phải qua `services/apiClient.ts`:

```ts
import axios from 'axios';

const apiClient = axios.create({
  baseURL: process.env.API_URL,
  timeout: 10000,
});

apiClient.interceptors.request.use(config => {
  // Gắn token Firebase hoặc Bearer token
  const token = useAuthStore.getState().token;
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export default apiClient;
```

Mỗi feature có file riêng:

```ts
// src/features/health/api/health.api.ts
import apiClient from '@/services/apiClient';

export const healthApi = {
  getOverview: (userId: string) => apiClient.get(`/health/${userId}`),
  updateRecord: (data: any) => apiClient.post('/health/update', data),
};
```

---

## 6. State management (Zustand)

Zustand được chọn vì:

- Dễ viết, không boilerplate.
- Hiệu năng tốt hơn Redux cho mobile.

Ví dụ:

```ts
// src/store/useHealthStore.ts
import { create } from 'zustand';

export const useHealthStore = create(set => ({
  data: [],
  setData: (data: any[]) => set({ data }),
}));
```

---

## 7. Coding convention

- **Ngôn ngữ:** TypeScript
- **Format:** Prettier + ESLint (setup sẵn)
- **Component nhỏ:** luôn dùng `React.memo`
- **Async:** luôn dùng `try/catch`
- **Không console.log trong production**

---

## 8. Quy trình phát triển feature

1. Tạo folder mới trong `src/features/<feature_name>`
2. Thêm API file nếu cần giao tiếp backend
3. Tạo `hook` xử lý logic
4. Viết `screen` render giao diện
5. Kết nối với `store` (nếu cần state global)
6. Thêm route vào `MainNavigator`

---

## 9. Tài liệu tham khảo

- [React Native Architecture Best Practices](https://reactnative.dev/docs/architecture-overview)
- [Zustand Docs](https://docs.pmnd.rs/zustand/getting-started/introduction)

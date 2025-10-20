// Mẫu
/**
 * Kiểu dữ liệu đăng nhập
 */
export interface LoginRequest {
  email: string;
  password: string;
}

/**
 * Thông tin phản hồi sau khi đăng nhập / đăng ký
 */
export interface AuthResponse {
  user: AuthUser;
  token: string; // JWT hoặc Firebase ID token
  refreshToken?: string;
}

/**
 * Kiểu người dùng sau khi xác thực
 */
export interface AuthUser {
  id: string;
  email: string;
  fullName: string;
  avatarUrl?: string;
  gender?: 'male' | 'female' | 'other';
  dateOfBirth?: string;
  createdAt: string;
  updatedAt?: string;
}

// import { LoginRequest, AuthResponse } from '@/types/api/auth.types';

// export async function login(req: LoginRequest): Promise<AuthResponse> {
//   const res = await fetch(`${process.env.API_URL}/auth/login`, {
//     method: 'POST',
//     headers: { 'Content-Type': 'application/json' },
//     body: JSON.stringify(req),
//   });
//   return res.json();
// }

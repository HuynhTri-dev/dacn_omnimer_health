//! Đây chỉ là example thôi

export interface User {
  id: string;
  email: string;
  name: string;
  avatarUrl?: string;
  role: 'user' | 'admin';
  createdAt: string;
}

// services/userService.ts
// import { User } from '@/types/entities/user.types';

// export async function getUserProfile(): Promise<User> {
//   const res = await fetch('/api/user');
//   return res.json();
// }

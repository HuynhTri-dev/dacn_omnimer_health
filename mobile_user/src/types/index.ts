// types/index.ts
export * from './common.types';
export * from './api';
export * from './entities';

// services/userService.ts
// import { User } from '@/types';

// export async function getUserProfile(): Promise<User> {
//   const res = await fetch('/api/user');
//   return res.json();
// }

// import { LoginRequest, AuthResponse } from '@/types;

// export async function login(req: LoginRequest): Promise<AuthResponse> {
//   const res = await fetch(`${process.env.API_URL}/auth/login`, {
//     method: 'POST',
//     headers: { 'Content-Type': 'application/json' },
//     body: JSON.stringify(req),
//   });
//   return res.json();
// }

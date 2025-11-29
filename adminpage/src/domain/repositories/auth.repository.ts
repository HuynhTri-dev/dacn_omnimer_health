import type { User } from "../../shared/types";

export interface IAuthRepository {
  login(
    email: string,
    password: string
  ): Promise<{ user: User; accessToken: string; refreshToken: string }>;
  register(
    userData: any
  ): Promise<{ user: User; accessToken: string; refreshToken: string }>;
  getCurrentUser(): Promise<User>;
  refreshToken(): Promise<{ accessToken: string; refreshToken: string }>;
  logout(): Promise<void>;
}

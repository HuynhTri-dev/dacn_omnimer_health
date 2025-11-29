import type { IAuthRepository } from "../repositories/auth.repository";
import type { User } from "../../shared/types";
import { apiClient } from "../../data/services/authApi";

export class AuthUseCase {
  constructor(private authRepository: IAuthRepository) {}

  async login(email: string, password: string) {
    try {
      const response = await this.authRepository.login(email, password);
      return response;
    } catch (error: any) {
      throw error;
    }
  }

  async register(userData: any) {
    try {
      const response = await this.authRepository.register(userData);
      return response;
    } catch (error: any) {
      throw error;
    }
  }

  async getCurrentUser(): Promise<User> {
    try {
      const user = await this.authRepository.getCurrentUser();
      return user;
    } catch (error: any) {
      throw error;
    }
  }

  async refreshToken() {
    try {
      const response = await this.authRepository.refreshToken();
      return response;
    } catch (error: any) {
      throw error;
    }
  }

  async logout(): Promise<void> {
    try {
      await this.authRepository.logout();
    } catch (error) {
      console.error("Logout error:", error);
      throw error;
    }
  }

  isAuthenticated(): boolean {
    const token = apiClient.getAccessToken();
    return !!token;
  }

  getStoredToken(): string | null {
    return apiClient.getAccessToken();
  }

  hasValidTokens(): boolean {
    const accessToken = apiClient.getAccessToken();
    const refreshToken = apiClient.getRefreshToken();
    return !!(accessToken && refreshToken);
  }
}

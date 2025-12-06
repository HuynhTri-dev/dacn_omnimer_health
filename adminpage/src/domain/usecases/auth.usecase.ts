import type { IAuthRepository } from "../repositories/auth.repository";
import type { User } from "../../shared/types";
import { apiClient } from "../../data/services/authApi";

export class AuthUseCase {
  private authRepository: IAuthRepository;

  constructor(authRepository: IAuthRepository) {
    this.authRepository = authRepository;
  }

  async login(email: string, password: string) {
    return this.authRepository.login(email, password);
  }

  async register(userData: any) {
    return this.authRepository.register(userData);
  }

  async getCurrentUser(): Promise<User> {
    return this.authRepository.getCurrentUser();
  }

  async refreshToken() {
    return this.authRepository.refreshToken();
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

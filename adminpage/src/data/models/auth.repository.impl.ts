import type { IAuthRepository } from "../../domain/repositories/auth.repository";
import type { User } from "../../shared/types";
import {
  apiClient,
  type LoginResponse,
  type GetAuthResponse,
} from "../services/authApi";
import type { UserFormValues } from "../../shared/types";
import { AxiosError } from "axios";

export class AuthRepositoryImpl implements IAuthRepository {
  async login(email: string, password: string) {
    try {
      const response = await apiClient.login(email, password);

      // Tokens are automatically stored in apiClient
      return {
        user: this.mapUserFromLoginResponse(response.data.data.user),
        accessToken: response.data.data.accessToken,
        refreshToken: response.data.data.refreshToken,
      };
    } catch (error: unknown) {
      if (error instanceof AxiosError && error.response?.data) {
        throw error.response.data;
      }
      throw error;
    }
  }

  async register(userData: UserFormValues) {
    try {
      const response = await apiClient.post<LoginResponse>(
        "/register",
        userData
      );

      if (response.data.data?.accessToken && response.data.data?.refreshToken) {
        apiClient.setTokens({
          accessToken: response.data.data.accessToken,
          refreshToken: response.data.data.refreshToken,
        });
      }

      return {
        user: this.mapUserFromLoginResponse(response.data.data.user),
        accessToken: response.data.data.accessToken,
        refreshToken: response.data.data.refreshToken,
      };
    } catch (error: unknown) {
      if (error instanceof AxiosError && error.response?.data) {
        throw error.response.data;
      }
      throw error;
    }
  }

  async getCurrentUser(): Promise<User> {
    try {
      const response = await apiClient.getAuth();
      return this.mapUserFromGetAuthResponse(response.data.data.user);
    } catch (error: unknown) {
      if (error instanceof AxiosError && error.response?.data) {
        throw error.response.data;
      }
      throw error;
    }
  }

  async refreshToken() {
    try {
      const refreshToken = localStorage.getItem("refreshToken");
      if (!refreshToken) {
        throw new Error("No refresh token available");
      }

      const response = await apiClient.createNewAccessToken(refreshToken);

      // The new access token is automatically set in the apiClient interceptor
      return {
        accessToken: response.data.data.accessToken,
        refreshToken: refreshToken, // Keep the same refresh token
      };
    } catch (error: unknown) {
      if (error instanceof AxiosError && error.response?.data) {
        throw error.response.data;
      }
      throw error;
    }
  }

  async logout(): Promise<void> {
    try {
      await apiClient.logout();
    } catch (error) {
      console.error("Logout error:", error);
    } finally {
      apiClient.clearTokens();
    }
  }

  // Helper methods to map API responses to User entity
  private mapUserFromLoginResponse(apiUser: LoginResponse["user"]): User {
    const fullname = apiUser.fullname || "";
    return {
      _id: apiUser._id,
      username: fullname, // Map fullname to username for compatibility
      email: apiUser.email,
      firstName: fullname.split(" ")[0] || "",
      lastName: fullname.split(" ").slice(1).join(" ") || "",
      avatar: apiUser.imageUrl,
      roles: [], // Will be populated from backend in future
      permissions: [], // Will be populated from backend in future
      createdAt: new Date(), // Not provided in response
      updatedAt: new Date(), // Not provided in response
    };
  }

  private mapUserFromGetAuthResponse(apiUser: GetAuthResponse["user"]): User {
    const fullname = apiUser.fullname || "";
    return {
      _id: apiUser._id,
      username: fullname, // Map fullname to username for compatibility
      email: apiUser.email,
      firstName: fullname.split(" ")[0] || "",
      lastName: fullname.split(" ").slice(1).join(" ") || "",
      avatar: apiUser.imageUrl,
      roles: [], // Will be populated from backend in future
      permissions: [], // Will be populated from backend in future
      createdAt: new Date(), // Not provided in response
      updatedAt: new Date(), // Not provided in response
    };
  }
}

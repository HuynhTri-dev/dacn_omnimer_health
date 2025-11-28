import type { AxiosResponse } from "axios";
import type { ApiResponse, ErrorResponse } from "../../shared/types";
import {
  BaseApi,
  type AuthTokens,
  type NewAccessTokenResponse,
} from "./baseApi";

// Login request type
export interface LoginRequest {
  email: string;
  password: string;
}

// Login response type
export interface LoginResponse {
  user: {
    _id: string;
    fullname: string;
    email: string;
    imageUrl?: string;
    roleName?: string[];
    roleIds?: string[];
    gender?: string;
    birthday?: string;
  };
  accessToken: string;
  refreshToken: string;
}

// GetAuth response type

export interface GetAuthResponse {
  user: {
    _id: string;
    fullname: string;
    email: string;
    imageUrl?: string;
    roleName?: string[];
    roleIds?: string[];
    gender?: string;
    birthday?: string;
  };
}

export class ApiClient extends BaseApi {
  constructor() {
    super();
  }

  // Authentication methods
  public async login(
    email: string,
    password: string
  ): Promise<AxiosResponse<ApiResponse<LoginResponse>>> {
    const response = await this.axiosInstance.post<ApiResponse<LoginResponse>>(
      "/login",
      {
        email,
        password,
      }
    );

    if (response.data.data?.accessToken && response.data.data?.refreshToken) {
      this.setTokens({
        accessToken: response.data.data.accessToken,
        refreshToken: response.data.data.refreshToken,
      });
    }

    return response;
  }

  public async getAuth(): Promise<AxiosResponse<ApiResponse<GetAuthResponse>>> {
    return this.axiosInstance.get<ApiResponse<GetAuthResponse>>("/");
  }

  public async logout(): Promise<void> {
    this.clearTokens();
  }
}

// Create singleton instance
export const apiClient = new ApiClient();

// Export types
export type { ApiResponse, ErrorResponse, AuthTokens, NewAccessTokenResponse };

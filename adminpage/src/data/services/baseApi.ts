import axios from "axios";
import type {
  AxiosInstance,
  AxiosRequestConfig,
  AxiosResponse,
  AxiosError,
} from "axios";
import type { ApiResponse } from "../../shared/types";
import { API_CONFIG } from "./configApi";

// Token types
export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

// New access token response type
export interface NewAccessTokenResponse {
  message: string;
  accessToken: string;
}

export class BaseApi {
  protected axiosInstance: AxiosInstance;
  protected baseURL: string;
  private isRefreshing: boolean = false;
  private failedQueue: Array<{
    resolve: (token: string) => void;
    reject: (error: unknown) => void;
  }> = [];

  constructor() {
    this.baseURL = API_CONFIG.baseURL;
    this.axiosInstance = axios.create({
      baseURL: this.baseURL,
      timeout: API_CONFIG.timeout,
      headers: {
        "Content-Type": "application/json",
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors(): void {
    // Request interceptor to add auth token
    this.axiosInstance.interceptors.request.use(
      (config) => {
        const token = this.getAccessToken();
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => {
        return Promise.reject(error);
      }
    );

    // Response interceptor to handle token refresh
    this.axiosInstance.interceptors.response.use(
      (response: AxiosResponse) => {
        return response;
      },
      async (error: AxiosError) => {
        const originalRequest = error.config as AxiosRequestConfig & {
          _retry?: boolean;
        };

        if (
          error.response?.status === 401 &&
          originalRequest &&
          !originalRequest._retry
        ) {
          if (this.isRefreshing) {
            // If token refresh is already in progress, add this request to the queue
            return new Promise((resolve, reject) => {
              this.failedQueue.push({ resolve, reject });
            })
              .then((token) => {
                if (originalRequest.headers) {
                  originalRequest.headers.Authorization = `Bearer ${token}`;
                }
                return this.axiosInstance(originalRequest);
              })
              .catch((err) => {
                return Promise.reject(err);
              });
          }

          originalRequest._retry = true;
          this.isRefreshing = true;

          try {
            const refreshToken = this.getRefreshToken();
            if (!refreshToken) {
              throw new Error("No refresh token available");
            }

            const response = await this.createNewAccessToken(refreshToken);
            const { accessToken } = response.data.data;

            this.setAccessToken(accessToken);

            // Process the queue
            this.failedQueue.forEach(({ resolve }) => {
              resolve(accessToken);
            });
            this.failedQueue = [];

            // Retry the original request
            if (originalRequest.headers) {
              originalRequest.headers.Authorization = `Bearer ${accessToken}`;
            }
            return this.axiosInstance(originalRequest);
          } catch (refreshError) {
            // Refresh token failed, clear tokens and redirect to login
            this.clearTokens();
            this.failedQueue.forEach(({ reject }) => {
              reject(refreshError);
            });
            this.failedQueue = [];

            // Redirect to login page
            window.location.href = "/login";

            return Promise.reject(refreshError);
          } finally {
            this.isRefreshing = false;
          }
        }

        return Promise.reject(error);
      }
    );
  }

  // Token management methods
  public getAccessToken(): string | null {
    return localStorage.getItem("accessToken");
  }

  public getRefreshToken(): string | null {
    return localStorage.getItem("refreshToken");
  }

  public setAccessToken(token: string): void {
    localStorage.setItem("accessToken", token);
  }

  public setRefreshToken(token: string): void {
    localStorage.setItem("refreshToken", token);
  }

  public setTokens(tokens: AuthTokens): void {
    this.setAccessToken(tokens.accessToken);
    this.setRefreshToken(tokens.refreshToken);
  }

  public clearTokens(): void {
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
  }

  public async createNewAccessToken(
    refreshToken: string
  ): Promise<AxiosResponse<ApiResponse<NewAccessTokenResponse>>> {
    const response = await axios.post<ApiResponse<NewAccessTokenResponse>>(
      `${this.baseURL}/new-access-token`,
      { refreshToken }
    );
    return response;
  }

  // Generic HTTP methods
  public async get<T>(
    endpoint: string,
    params?: unknown
  ): Promise<AxiosResponse<ApiResponse<T>>> {
    return this.axiosInstance.get<ApiResponse<T>>(endpoint, { params });
  }

  public async post<T>(
    endpoint: string,
    data?: unknown
  ): Promise<AxiosResponse<ApiResponse<T>>> {
    return this.axiosInstance.post<ApiResponse<T>>(endpoint, data);
  }

  public async put<T>(
    endpoint: string,
    data?: unknown
  ): Promise<AxiosResponse<ApiResponse<T>>> {
    return this.axiosInstance.put<ApiResponse<T>>(endpoint, data);
  }

  public async patch<T>(
    endpoint: string,
    data?: unknown
  ): Promise<AxiosResponse<ApiResponse<T>>> {
    return this.axiosInstance.patch<ApiResponse<T>>(endpoint, data);
  }

  public async delete<T>(
    endpoint: string
  ): Promise<AxiosResponse<ApiResponse<T>>> {
    return this.axiosInstance.delete<ApiResponse<T>>(endpoint);
  }

  // File upload method
  public async uploadFile<T>(
    endpoint: string,
    formData: FormData
  ): Promise<AxiosResponse<ApiResponse<T>>> {
    return this.axiosInstance.post<ApiResponse<T>>(endpoint, formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });
  }
}

import type { IUserRepository } from "../../domain/repositories/user.repository";
import type {
  User,
  PaginationParams,
  PaginationResponse,
} from "../../shared/types";
import { apiClient } from "../services/authApi";

export class UserRepositoryImpl implements IUserRepository {
  async getUsers(params?: PaginationParams): Promise<PaginationResponse<User>> {
    const response = await apiClient.get<User[]>("/user/", params);

    // Convert array response to pagination response
    return {
      data: response.data.data,
      total: response.data.data.length,
      page: params?.page || 1,
      limit: params?.limit || 10,
      totalPages: Math.ceil(response.data.data.length / (params?.limit || 10)),
    };
  }

  async getUserById(id: string): Promise<User> {
    const response = await apiClient.get<User>(`/user/${id}`);
    return response.data.data;
  }

  async updateUser(id: string, userData: Partial<User>): Promise<User> {
    const response = await apiClient.put<User>(`/user/${id}`, userData);
    return response.data.data;
  }

  async deleteUser(id: string): Promise<void> {
    await apiClient.delete(`/user/${id}`);
  }

  async updateRole(userId: string, roles: string[]): Promise<User> {
    const response = await apiClient.patch<User>(`/user/${userId}/roles`, {
      roles,
    });
    return response.data.data;
  }
}

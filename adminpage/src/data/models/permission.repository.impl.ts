import type { IPermissionRepository } from "../../domain/repositories/permission.repository";
import type {
  Permission,
  PaginationParams,
  PaginationResponse,
} from "../../shared/types";
import { apiClient } from "../services/authApi";

export class PermissionRepositoryImpl implements IPermissionRepository {
  async getPermissions(
    params?: PaginationParams
  ): Promise<PaginationResponse<Permission>> {
    const response = await apiClient.get<Permission[]>("/permission/", params);

    return {
      data: response.data.data,
      total: response.data.data.length,
      page: params?.page || 1,
      limit: params?.limit || 10,
      totalPages: Math.ceil(response.data.data.length / (params?.limit || 10)),
    };
  }

  async getPermissionById(id: string): Promise<Permission> {
    const response = await apiClient.get<Permission>(`/permission/${id}`);
    return response.data.data;
  }

  async createPermission(permissionData: any): Promise<Permission> {
    const response = await apiClient.post<Permission>(
      "/permission/",
      permissionData
    );
    return response.data.data;
  }

  async updatePermission(
    id: string,
    permissionData: Partial<Permission>
  ): Promise<Permission> {
    const response = await apiClient.put<Permission>(
      `/permission/${id}`,
      permissionData
    );
    return response.data.data;
  }

  async deletePermission(id: string): Promise<void> {
    await apiClient.delete(`/permission/${id}`);
  }
}

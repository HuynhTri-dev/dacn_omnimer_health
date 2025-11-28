import type { IRoleRepository } from "../../domain/repositories/role.repository";
import type {
  Role,
  PaginationParams,
  PaginationResponse,
} from "../../shared/types";
import { apiClient } from "../services/authApi";

export class RoleRepositoryImpl implements IRoleRepository {
  async getRoles(params?: PaginationParams): Promise<PaginationResponse<Role>> {
    const response = await apiClient.get<Role[]>("/role/", params);

    return {
      data: response.data.data,
      total: response.data.data.length,
      page: params?.page || 1,
      limit: params?.limit || 10,
      totalPages: Math.ceil(response.data.data.length / (params?.limit || 10)),
    };
  }

  async getRoleById(id: string): Promise<Role> {
    const response = await apiClient.get<Role>(`/role/${id}`);
    return response.data.data;
  }

  async getRolesWithoutAdmin(): Promise<Role[]> {
    const response = await apiClient.get<Role[]>("/role/without-admin");
    return response.data.data;
  }

  async createRole(roleData: any): Promise<Role> {
    const response = await apiClient.post<Role>("/role/", roleData);
    return response.data.data;
  }

  async updateRole(id: string, roleData: Partial<Role>): Promise<Role> {
    const response = await apiClient.put<Role>(`/role/${id}`, roleData);
    return response.data.data;
  }

  async updateRolePermissions(
    id: string,
    permissions: string[]
  ): Promise<Role> {
    const response = await apiClient.patch<Role>(`/role/${id}`, {
      permissions,
    });
    return response.data.data;
  }

  async deleteRole(id: string): Promise<void> {
    await apiClient.delete(`/role/${id}`);
  }
}

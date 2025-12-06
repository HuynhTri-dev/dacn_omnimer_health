import type { IPermissionRepository } from "../repositories/permission.repository";
import type {
  Permission,
  PaginationParams,
  PaginationResponse,
} from "../../shared/types";

export class PermissionUseCase {
  private permissionRepository: IPermissionRepository;

  constructor(permissionRepository: IPermissionRepository) {
    this.permissionRepository = permissionRepository;
  }

  async getPermissions(
    params?: PaginationParams
  ): Promise<PaginationResponse<Permission>> {
    return await this.permissionRepository.getPermissions(params);
  }

  async getPermissionById(id: string): Promise<Permission> {
    return await this.permissionRepository.getPermissionById(id);
  }

  async createPermission(permissionData: Permission): Promise<Permission> {
    return await this.permissionRepository.createPermission(permissionData);
  }

  async updatePermission(
    id: string,
    permissionData: Partial<Permission>
  ): Promise<Permission> {
    return await this.permissionRepository.updatePermission(id, permissionData);
  }

  async deletePermission(id: string): Promise<void> {
    await this.permissionRepository.deletePermission(id);
  }
}

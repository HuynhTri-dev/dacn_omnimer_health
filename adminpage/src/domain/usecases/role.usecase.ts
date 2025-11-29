import type { IRoleRepository } from "../repositories/role.repository";
import type {
  Role,
  Permission,
  PaginationParams,
  PaginationResponse,
} from "../../shared/types";

export class RoleUseCase {
  constructor(private roleRepository: IRoleRepository) {}

  async getRoles(params?: PaginationParams): Promise<PaginationResponse<Role>> {
    return await this.roleRepository.getRoles(params);
  }

  async getRoleById(id: string): Promise<Role> {
    return await this.roleRepository.getRoleById(id);
  }

  async getRolesWithoutAdmin(): Promise<Role[]> {
    return await this.roleRepository.getRolesWithoutAdmin();
  }

  async createRole(roleData: any): Promise<Role> {
    return await this.roleRepository.createRole(roleData);
  }

  async updateRole(id: string, roleData: Partial<Role>): Promise<Role> {
    return await this.roleRepository.updateRole(id, roleData);
  }

  async updateRolePermissions(
    id: string,
    permissions: string[]
  ): Promise<Role> {
    return await this.roleRepository.updateRolePermissions(id, permissions);
  }

  async deleteRole(id: string): Promise<void> {
    await this.roleRepository.deleteRole(id);
  }
}

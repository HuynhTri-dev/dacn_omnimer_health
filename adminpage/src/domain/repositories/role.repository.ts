import type {
  Role,
  PaginationParams,
  PaginationResponse,
} from "../../shared/types";

export interface IRoleRepository {
  getRoles(params?: PaginationParams): Promise<PaginationResponse<Role>>;
  getRoleById(id: string): Promise<Role>;
  getRolesWithoutAdmin(): Promise<Role[]>;
  createRole(roleData: any): Promise<Role>;
  updateRole(id: string, roleData: Partial<Role>): Promise<Role>;
  updateRolePermissions(id: string, permissions: string[]): Promise<Role>;
  deleteRole(id: string): Promise<void>;
}

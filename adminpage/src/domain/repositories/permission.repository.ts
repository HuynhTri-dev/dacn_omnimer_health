import type {
  Permission,
  PaginationParams,
  PaginationResponse,
} from "../../shared/types";

export interface IPermissionRepository {
  getPermissions(
    params?: PaginationParams
  ): Promise<PaginationResponse<Permission>>;
  getPermissionById(id: string): Promise<Permission>;
  createPermission(permissionData: any): Promise<Permission>;
  updatePermission(
    id: string,
    permissionData: Partial<Permission>
  ): Promise<Permission>;
  deletePermission(id: string): Promise<void>;
}

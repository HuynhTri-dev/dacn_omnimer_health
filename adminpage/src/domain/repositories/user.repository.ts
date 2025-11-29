import type {
  User,
  PaginationParams,
  PaginationResponse,
} from "../../shared/types";

export interface IUserRepository {
  getUsers(params?: PaginationParams): Promise<PaginationResponse<User>>;
  getUserById(id: string): Promise<User>;
  updateUser(id: string, userData: Partial<User>): Promise<User>;
  deleteUser(id: string): Promise<void>;
  updateRole(userId: string, roles: string[]): Promise<User>;
}

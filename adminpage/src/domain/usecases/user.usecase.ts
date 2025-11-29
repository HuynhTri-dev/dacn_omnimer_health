import type { IUserRepository } from "../repositories/user.repository";
import type {
  User,
  PaginationParams,
  PaginationResponse,
} from "../../shared/types";

export class UserUseCase {
  constructor(private userRepository: IUserRepository) {}

  async getUsers(params?: PaginationParams): Promise<PaginationResponse<User>> {
    return await this.userRepository.getUsers(params);
  }

  async getUserById(id: string): Promise<User> {
    return await this.userRepository.getUserById(id);
  }

  async updateUser(id: string, userData: Partial<User>): Promise<User> {
    return await this.userRepository.updateUser(id, userData);
  }

  async deleteUser(id: string): Promise<void> {
    await this.userRepository.deleteUser(id);
  }

  async updateRole(userId: string, roles: string[]): Promise<User> {
    return await this.userRepository.updateRole(userId, roles);
  }
}

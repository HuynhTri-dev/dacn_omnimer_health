import { IUser } from '@/data/models/User.model';
import { ApiResponse } from '@/app/types/ApiResponse';

export interface IUserRepository {
  register(
    user: Partial<IUser>,
    password: string,
    avatarFile?: any,
  ): Promise<ApiResponse<IUser>>;
}

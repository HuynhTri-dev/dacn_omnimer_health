import { IUser } from '@/data/models/User.model';
import { ApiResponse } from '@/app/types/ApiResponse';
import { IAuthResponse } from '@/data/entities/AuthResponse';

export interface IUserRepository {
  register(
    user: Partial<IUser>,
    password: string,
    avatarFile?: any,
  ): Promise<ApiResponse<IAuthResponse>>;
}

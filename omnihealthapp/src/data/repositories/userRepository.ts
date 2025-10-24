// data/repositories/userRepository.ts
import { ApiResponse } from '@/app/types/ApiResponse';
import { IUser } from '@/data/models/User.model';
import {
  asyncStorage,
  encryptedStorage,
  STORAGE_KEYS,
} from '@/config/storageManager';
import { post } from '../api/callAPI';
import { IAuthResponse } from '../entities/AuthReponse';
import { API_ENDPOINTS } from '../api/endPoint';

export class UserRepository {
  async register(
    userData: Partial<IUser>,
    avatarFile?: any,
  ): Promise<ApiResponse<IAuthResponse>> {
    const formData = new FormData();
    Object.keys(userData).forEach(key => {
      const value = (userData as any)[key];
      if (value !== undefined && value !== null) formData.append(key, value);
    });
    if (avatarFile) formData.append('image', avatarFile);

    const res = await post<IAuthResponse>(API_ENDPOINTS.AUTH.LOGIN, {
      body: formData,
      isFormData: true,
    });

    // Xử lý accessToken luôn ở đây
    if (res.success) {
      await encryptedStorage.set(
        STORAGE_KEYS.ACCESS_TOKEN,
        res.data.accessToken,
      );

      await encryptedStorage.set(
        STORAGE_KEYS.REFRESH_TOKEN,
        res.data.refreshToken,
      );

      await asyncStorage.set(STORAGE_KEYS.USER_PROFILE, res.data.user);
    }

    return res;
  }
}

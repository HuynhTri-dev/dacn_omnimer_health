import { FirebaseAuthService } from '@/services/firebaseAuthService';
import { IUserRepository } from '@/domain/interfaces/IUserRepository';
import { ApiResponse } from '@/app/types/ApiResponse';
import { IUser } from '@/data/models/User.model';

export class RegisterUserService {
  constructor(private userRepo: IUserRepository) {}

  /**
   * Đăng ký user:
   * 1. Tạo user trên Firebase Auth -> lấy uid
   * 2. Gửi thông tin user + uid + avatar lên backend
   */
  async execute(
    userData: Partial<IUser>,
    password: string,
    avatarFile?: any,
  ): Promise<ApiResponse<IUser>> {
    if (!userData.email || !password) {
      return Promise.reject({
        success: false,
        message: 'Email và password bắt buộc',
        data: null,
      });
    }

    // 1️⃣ Firebase Auth
    const uid = await FirebaseAuthService.register(userData.email, password);
    userData.uid = uid;

    // 2️⃣ Gửi lên backend
    return this.userRepo.register(userData, avatarFile);
  }
}

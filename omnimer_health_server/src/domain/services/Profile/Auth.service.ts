import { UserRepository } from "../../repositories";
import { IUser } from "../../models";
import { JwtUtils } from "../../../utils/JwtUtils";
import { logAudit, logError } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import admin from "../../../common/configs/firebaseAdminConfig";
import { HttpError } from "../../../utils/HttpError";
import { DecodePayload } from "../../entities/DecodePayload";
import { uploadUserAvatar } from "../../../utils/CloudflareUpload";
import mongoose from "mongoose";
import { IAuthResponse, IUserResponse } from "../../entities";

export class AuthService {
  private readonly userRepo: UserRepository;

  constructor(userRepo: UserRepository) {
    this.userRepo = userRepo;
  }

  private buildUserResponse(user: IUser): IUserResponse {
    return {
      fullname: user.fullname,
      email: user.email,
      imageUrl: user.imageUrl,
      gender: user.gender,
      birthday: user.birthday,
    };
  }

  private generateTokens(user: IUser) {
    const payload: DecodePayload = {
      uid: user.uid,
      id: user._id,
      roleIds: user.roleIds,
    };
    return {
      accessToken: JwtUtils.generateAccessToken(payload),
      refreshToken: JwtUtils.generateRefreshToken(payload),
    };
  }

  /**
   * Đăng ký người dùng mới
   */
  async register(
    data: Partial<IUser>,
    avatarImage?: Express.Multer.File
  ): Promise<IAuthResponse> {
    const session = await mongoose.startSession();
    session.startTransaction();

    try {
      // 1. Kiểm tra trùng UID
      if (await this.userRepo.findByUid(data.uid!))
        throw new HttpError(409, "Người dùng đã có tài khoản tồn tại");

      // 2. Tạo user
      const created = await this.userRepo.createWithSession(data, session);

      // 3. Upload avatar nếu có
      if (avatarImage) {
        created.imageUrl = await uploadUserAvatar(avatarImage, created.id);
        await created.save({ session });
      }

      // 4. Commit transaction
      await session.commitTransaction();
      session.endSession();

      // 5. Sinh token
      const tokens = this.generateTokens(created);

      // 6. Ghi log
      await logAudit({
        userId: created._id.toString(),
        action: "registerUser",
        message: `User "${created.fullname}" đăng ký thành công`,
        status: StatusLogEnum.Success,
        targetId: created._id.toString(),
        metadata: { uid: created.uid, email: created.email },
      });

      return {
        user: this.buildUserResponse(created),
        ...tokens,
      };
    } catch (err: any) {
      await session.abortTransaction();
      session.endSession();

      await logError({
        action: "registerUser",
        message: err.message || err,
        errorMessage: err.stack || err,
      });

      throw err;
    }
  }

  /**
   * Đăng nhập người dùng bằng Firebase ID Token
   */
  async login(idToken: string): Promise<IAuthResponse> {
    try {
      const decoded = await admin.auth().verifyIdToken(idToken);
      const { uid } = decoded;

      const user = await this.userRepo.findByUid(uid);
      if (!user) throw new HttpError(401, "Không có người dùng này");

      return {
        user: this.buildUserResponse(user),
        ...this.generateTokens(user),
      };
    } catch (err) {
      throw err;
    }
  }
  async createNewAccessToken(refreshToken: string) {
    try {
      const decoded: any = JwtUtils.verifyRefreshToken(refreshToken);

      const user = await this.userRepo.findById(decoded.id);
      if (!user) {
        throw new HttpError(404, "User not found");
      }

      const accessToken = JwtUtils.generateAccessToken({
        id: user.id,
        role: user.roleIds,
      });

      return accessToken;
    } catch (e) {
      throw new HttpError(401, "Invalid or expired refresh token");
    }
  }
}

import { UserRepository } from "../repositories";
import { IUser } from "../models";
import { JwtUtils } from "../../utils/JwtUtils";
import { logAudit, logError } from "../../utils/LoggerUtil";
import { StatusLogEnum } from "../../common/constants/AppConstants";
import admin from "../../common/configs/firebaseAdminConfig";
import { HttpError } from "../../utils/HttpError";
import { DecodePayload } from "../entities/DecodePayload";

export class AuthService {
  private readonly userRepo: UserRepository;

  constructor(userRepo: UserRepository) {
    this.userRepo = userRepo;
  }

  /**
   * Đăng ký tài khoản + auto login
   */
  async register(data: Partial<IUser>): Promise<{
    user: IUser;
    accessToken: string;
    refreshToken: string;
  }> {
    try {
      // Check trùng UID
      const existingByUid = await this.userRepo.findByUid(data.uid!);
      if (existingByUid)
        throw new HttpError(409, "Người dùng đã có tài khoản tồn tại");

      const created = await this.userRepo.create(data);

      // Sinh token
      const payload: DecodePayload = {
        uid: created.uid,
        id: created._id,
        roleIds: created.roleIds,
      };
      const accessToken = JwtUtils.generateAccessToken(payload);
      const refreshToken = JwtUtils.generateRefreshToken(payload);

      // Log audit
      await logAudit({
        userId: created._id.toString(),
        action: "registerUser",
        message: `User "${created.fullname}" đăng ký thành công`,
        status: StatusLogEnum.Success,
        targetId: created._id.toString(),
        metadata: { uid: created.uid, email: created.email },
      });

      return {
        user: created,
        accessToken,
        refreshToken,
      };
    } catch (err: any) {
      // Log lỗi
      await logError({
        // userId: data?.uid || null,
        action: "registerUser",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  async login(idToken: string): Promise<{
    user: IUser;
    accessToken: string;
    refreshToken: string;
  }> {
    try {
      const decoded = await admin.auth().verifyIdToken(idToken);
      const { uid } = decoded;

      let user = await this.userRepo.findByUid(uid);

      if (!user) {
        throw new HttpError(401, "Không có người dùng này");
      }

      // Sinh token
      const payload: DecodePayload = {
        uid: user.uid,
        id: user._id,
        roleIds: user.roleIds,
      };
      const accessToken = JwtUtils.generateAccessToken(payload);
      const refreshToken = JwtUtils.generateRefreshToken(payload);

      return { user, accessToken, refreshToken };
    } catch (e) {
      throw e;
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

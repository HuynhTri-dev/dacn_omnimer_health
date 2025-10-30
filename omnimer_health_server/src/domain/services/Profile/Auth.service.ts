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
  /**
   * Xây dựng đối tượng phản hồi người dùng trả về cho client.
   * (Ẩn các trường nhạy cảm, chỉ giữ lại thông tin hiển thị cơ bản).
   *
   * @param {IUser} user - Đối tượng người dùng trong cơ sở dữ liệu.
   * @returns {IUserResponse} Thông tin người dùng được định dạng để phản hồi cho client.
   */
  private buildUserResponse(user: IUser): IUserResponse {
    return {
      fullname: user.fullname,
      email: user.email,
      imageUrl: user.imageUrl,
      gender: user.gender,
      birthday: user.birthday,
    };
  }
  /**
   * Sinh cặp accessToken và refreshToken cho người dùng.
   * (Payload bao gồm uid, id, và danh sách roleIds).
   *
   * @param {IUser} user - Đối tượng người dùng được xác thực.
   * @returns {{ accessToken: string; refreshToken: string }} Access và refresh token.
   */
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
   * Đăng ký người dùng mới.
   * - Kiểm tra UID trùng lặp trong hệ thống.
   * - Tạo người dùng mới trong transaction an toàn.
   * - Upload ảnh đại diện nếu có.
   * - Sinh accessToken và refreshToken cho tài khoản mới.
   * - Ghi log audit và trả về thông tin người dùng cùng token.
   *
   * @param {Partial<IUser>} data - Thông tin người dùng cần đăng ký (uid, email, fullname, ...).
   * @param {Express.Multer.File} [avatarImage] - File ảnh đại diện người dùng (tùy chọn).
   * @returns {Promise<IAuthResponse>} Thông tin người dùng và token sau khi đăng ký.
   * @throws {HttpError} Nếu UID đã tồn tại hoặc có lỗi khi ghi dữ liệu.
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
   * Đăng nhập người dùng bằng Firebase ID Token.
   * - Xác minh ID Token thông qua Firebase Admin SDK.
   * - Kiểm tra người dùng có tồn tại trong cơ sở dữ liệu.
   * - Sinh và trả về accessToken và refreshToken.
   *
   * @param {string} idToken - Firebase ID Token được gửi từ client.
   * @returns {Promise<IAuthResponse>} Thông tin người dùng và cặp token sau khi đăng nhập.
   * @throws {HttpError} Nếu token không hợp lệ hoặc người dùng không tồn tại.
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

  /**
   * Tạo mới accessToken từ refreshToken hợp lệ.
   * - Xác minh refreshToken.
   * - Kiểm tra người dùng có tồn tại.
   * - Phát hành accessToken mới cho phiên hiện tại.
   *
   * @param {string} refreshToken - Refresh token do hệ thống phát hành trước đó.
   * @returns {Promise<string>} Access token mới hợp lệ.
   * @throws {HttpError} Nếu refreshToken không hợp lệ hoặc đã hết hạn.
   */
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

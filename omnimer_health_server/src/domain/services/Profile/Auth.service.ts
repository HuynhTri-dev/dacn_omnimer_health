import { RoleRepository, UserRepository } from "../../repositories";
import { IRole, IUser } from "../../models";
import { JwtUtils } from "../../../utils/JwtUtils";
import { logAudit, logError } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import admin from "../../../common/configs/firebaseAdminConfig";
import { HttpError } from "../../../utils/HttpError";
import { DecodePayload } from "../../entities/DecodePayload.entity";
import { uploadUserAvatar } from "../../../utils/CloudflareUpload";
import mongoose, { Types } from "mongoose";
import { IAuthResponse, IUserResponse } from "../../entities";
import { comparePassword, hashPassword } from "../../../utils/PasswordUtil";

export class AuthService {
  private readonly userRepo: UserRepository;
  private readonly roleRepo: RoleRepository;

  constructor(userRepo: UserRepository, roleRepo: RoleRepository) {
    this.userRepo = userRepo;
    this.roleRepo = roleRepo;
  }

  /**
   * Xây dựng đối tượng phản hồi người dùng trả về cho client.
   * (Ẩn các trường nhạy cảm, chỉ giữ lại thông tin hiển thị cơ bản).
   */
  private buildUserResponse(user: IUserResponse): IUserResponse {
    return {
      fullname: user.fullname,
      email: user.email,
      imageUrl: user.imageUrl,
      gender: user.gender,
      birthday: user.birthday,
      roleName: user.roleName, // Danh sách tên vai trò
    };
  }

  /**
   * Sinh cặp accessToken và refreshToken cho người dùng.
   */
  private generateTokens(user: IUserResponse) {
    // Đảm bảo user có _id và roleIds để tạo payload
    const payload: DecodePayload = {
      id: user._id as Types.ObjectId,
      roleIds: user.roleIds as Types.ObjectId[], // Giả định roleIds là Types.ObjectId[] sau khi tạo
    };
    return {
      accessToken: JwtUtils.generateAccessToken(payload),
      refreshToken: JwtUtils.generateRefreshToken(payload),
    };
  }

  /**
   * Đăng ký người dùng mới.
   * @param {IUser} data - Thông tin người dùng cần đăng ký (email, fullname, password...).
   * @param {Express.Multer.File} [avatarImage] - File ảnh đại diện người dùng (tùy chọn).
   * @returns {Promise<IAuthResponse>} Thông tin người dùng và token sau khi đăng ký.
   * @throws {HttpError} Nếu Email đã tồn tại hoặc có lỗi khi ghi dữ liệu.
   */
  async register(
    data: Omit<IUser, "passwordHashed" | "_id"> & { password: string },
    avatarImage?: Express.Multer.File
  ): Promise<IAuthResponse> {
    const session = await mongoose.startSession();
    session.startTransaction();

    try {
      //! Kiểm tra thông tin email đã có và role có trong dữ liệu
      if (await this.userRepo.findByEmail(data.email))
        throw new HttpError(409, "Người dùng đã có tài khoản tồn tại.");

      const defaultRole = await this.roleRepo.findRoleNamesAndIdsByRoleIds(
        data.roleIds
      );

      if (!defaultRole) {
        throw new HttpError(
          500,
          "Lỗi hệ thống: Không tìm thấy vai trò mặc định 'User'."
        );
      }

      const defaultRoleIds = defaultRole
        .filter((role): role is IRole => !!role)
        .map((role) => role._id);

      const defaultRoleNames = defaultRole
        .filter((role): role is IRole => !!role)
        .map((role) => role.name);

      //! Mã hóa mật khẩu
      const passwordHashed = await hashPassword(data.password);

      const newUserData = {
        ...data,
        passwordHashed: passwordHashed,
        roleIds: defaultRoleIds,
      };

      const created = await this.userRepo.createWithSession(
        newUserData,
        session
      );

      // Upload avatar
      if (avatarImage) {
        created.imageUrl = await uploadUserAvatar(
          avatarImage,
          created._id.toString()
        );
        await created.save({ session });
      }

      await session.commitTransaction();
      session.endSession();

      const userResponse: IUserResponse = {
        fullname: created.fullname,
        email: created.email,
        imageUrl: created.imageUrl,
        gender: created.gender,
        birthday: created.birthday,
        roleName: defaultRoleNames,
      };

      await logAudit({
        userId: created._id.toString(),
        action: "registerUser",
        message: `User "${created.fullname}" đăng ký thành công`,
        status: StatusLogEnum.Success,
        targetId: created._id.toString(),
        metadata: { email: created.email, roleNames: defaultRoleNames },
      });

      // 10. Trả về
      return {
        user: this.buildUserResponse(userResponse),
        ...this.generateTokens(created),
      };
    } catch (err: any) {
      //! Hủy session khi có lỗi
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
   * Đăng nhập người dùng bằng Email và Password.
   * - Tìm kiếm người dùng trong cơ sở dữ liệu dựa trên email.
   * - So sánh mật khẩu được gửi lên với hash đã lưu trong DB.
   * - Sinh và trả về accessToken và refreshToken.
   *
   * @param {string} email - Email của người dùng.
   * @param {string} password - Mật khẩu của người dùng (dạng chuỗi chưa được hash).
   * @returns {Promise<IAuthResponse>} Thông tin người dùng và cặp token sau khi đăng nhập.
   * @throws {HttpError} Nếu email hoặc password không đúng.
   */
  async login(email: string, password: string): Promise<IAuthResponse> {
    try {
      const userWithHash = await this.userRepo.userByEmailWithPassword(email);
      console.log("User With Hash", userWithHash);
      if (!userWithHash) {
        throw new HttpError(401, "Email hoặc password không đúng");
      }

      const isPasswordValid = await comparePassword(
        password,
        userWithHash.passwordHashed
      );

      if (!isPasswordValid) {
        throw new HttpError(401, "Email hoặc password không đúng");
      }

      return {
        user: this.buildUserResponse(userWithHash.userResponse),
        ...this.generateTokens(userWithHash.userResponse),
      };
    } catch (err: any) {
      await logError({
        action: "loginUser",
        message: err.message || err,
        errorMessage: err.stack || err,
      });

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

  async getAuth(id: string) {
    try {
      const user = await this.userRepo.getUserById(id);
      if (!user) {
        throw new HttpError(404, "User not found");
      }

      return user;
    } catch (e) {
      throw new HttpError(401, "Invalid or expired refresh token");
    }
  }
}

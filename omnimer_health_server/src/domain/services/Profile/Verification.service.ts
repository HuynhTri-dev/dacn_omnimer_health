import { UserRepository } from "../../repositories";
import { JwtUtils } from "../../../utils/JwtUtils";
import { EmailService } from "../../../utils/EmailService";
import { HttpError } from "../../../utils/HttpError";
import { logAudit, logError } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";

/**
 * Verification Service - Xử lý logic xác thực email/phone
 */
export class VerificationService {
  private readonly userRepo: UserRepository;

  constructor(userRepo: UserRepository) {
    this.userRepo = userRepo;
  }

  /**
   * Gửi email xác thực cho user
   * @param userId - ID của user cần gửi email
   */
  async sendVerificationEmail(userId: string): Promise<{ message: string }> {
    try {
      const user = await this.userRepo.findById(userId);

      if (!user) {
        throw new HttpError(404, "Người dùng không tồn tại");
      }

      if (user.isEmailVerified) {
        throw new HttpError(400, "Email đã được xác thực trước đó");
      }

      // Tạo verification token (hết hạn sau 24h)
      const tokenPayload = {
        userId: user._id.toString(),
        email: user.email,
        type: "email_verification",
      };
      const verificationToken = JwtUtils.generateVerificationToken(
        tokenPayload,
        "24h"
      );

      // Tính thời gian hết hạn
      const expiresAt = new Date();
      expiresAt.setHours(expiresAt.getHours() + 24);

      // Lưu token vào database
      user.emailVerificationToken = verificationToken;
      user.emailVerificationExpires = expiresAt;
      await user.save();

      // Gửi email
      await EmailService.sendVerificationEmail(
        user.email,
        user.fullname,
        verificationToken
      );

      await logAudit({
        userId: user._id.toString(),
        action: "sendVerificationEmail",
        message: `Verification email sent to ${user.email}`,
        status: StatusLogEnum.Success,
        targetId: user._id.toString(),
        metadata: { email: user.email },
      });

      return {
        message: "Email xác thực đã được gửi. Vui lòng kiểm tra hộp thư của bạn.",
      };
    } catch (error: any) {
      await logError({
        action: "sendVerificationEmail",
        message: error.message || "Failed to send verification email",
        errorMessage: error.stack || error,
      });
      throw error;
    }
  }

  /**
   * Xác thực email bằng token
   * @param token - Verification token từ email
   */
  async verifyEmail(token: string): Promise<{ message: string; verified: boolean }> {
    try {
      // Decode và verify token
      let decoded: any;
      try {
        decoded = JwtUtils.verifyVerificationToken(token);
      } catch (err) {
        throw new HttpError(400, "Token không hợp lệ hoặc đã hết hạn");
      }

      if (decoded.type !== "email_verification") {
        throw new HttpError(400, "Token không hợp lệ");
      }

      // Tìm user bằng userId từ token
      const user = await this.userRepo.findById(decoded.userId);

      if (!user) {
        throw new HttpError(404, "Người dùng không tồn tại");
      }

      if (user.isEmailVerified) {
        return {
          message: "Email đã được xác thực trước đó",
          verified: true,
        };
      }

      // Kiểm tra token có khớp với token trong DB không
      if (user.emailVerificationToken !== token) {
        throw new HttpError(400, "Token không hợp lệ");
      }

      // Kiểm tra token còn hạn không
      if (
        user.emailVerificationExpires &&
        new Date() > user.emailVerificationExpires
      ) {
        throw new HttpError(400, "Token đã hết hạn. Vui lòng yêu cầu gửi lại email xác thực.");
      }

      // Cập nhật trạng thái xác thực
      user.isEmailVerified = true;
      user.emailVerificationToken = null;
      user.emailVerificationExpires = null;
      await user.save();

      // Gửi email thông báo xác thực thành công
      await EmailService.sendVerificationSuccessEmail(user.email, user.fullname);

      await logAudit({
        userId: user._id.toString(),
        action: "verifyEmail",
        message: `Email verified successfully for ${user.email}`,
        status: StatusLogEnum.Success,
        targetId: user._id.toString(),
        metadata: { email: user.email },
      });

      return {
        message: "Email đã được xác thực thành công!",
        verified: true,
      };
    } catch (error: any) {
      await logError({
        action: "verifyEmail",
        message: error.message || "Failed to verify email",
        errorMessage: error.stack || error,
      });
      throw error;
    }
  }

  /**
   * Gửi lại email xác thực
   * @param userId - ID của user
   */
  async resendVerificationEmail(userId: string): Promise<{ message: string }> {
    try {
      const user = await this.userRepo.findById(userId);

      if (!user) {
        throw new HttpError(404, "Người dùng không tồn tại");
      }

      if (user.isEmailVerified) {
        throw new HttpError(400, "Email đã được xác thực trước đó");
      }

      // Kiểm tra rate limiting (không cho gửi lại trong 1 phút)
      if (
        user.emailVerificationExpires &&
        new Date() < new Date(user.emailVerificationExpires.getTime() - 23 * 60 * 60 * 1000)
      ) {
        throw new HttpError(429, "Vui lòng đợi ít nhất 1 phút trước khi yêu cầu gửi lại email");
      }

      // Gửi email mới
      return this.sendVerificationEmail(userId);
    } catch (error: any) {
      await logError({
        action: "resendVerificationEmail",
        message: error.message || "Failed to resend verification email",
        errorMessage: error.stack || error,
      });
      throw error;
    }
  }

  /**
   * Kiểm tra trạng thái xác thực của user
   * @param userId - ID của user
   */
  async getVerificationStatus(userId: string): Promise<{
    isEmailVerified: boolean;
    isPhoneVerified: boolean;
    email: string;
    phoneNumber: string | null;
  }> {
    try {
      const user = await this.userRepo.findById(userId);

      if (!user) {
        throw new HttpError(404, "Người dùng không tồn tại");
      }

      return {
        isEmailVerified: user.isEmailVerified || false,
        isPhoneVerified: user.isPhoneVerified || false,
        email: user.email,
        phoneNumber: user.phoneNumber || null,
      };
    } catch (error: any) {
      await logError({
        action: "getVerificationStatus",
        message: error.message || "Failed to get verification status",
        errorMessage: error.stack || error,
      });
      throw error;
    }
  }

  /**
   * Yêu cầu đổi email
   * @param userId - ID của user
   * @param newEmail - Email mới
   */
  async requestChangeEmail(
    userId: string,
    newEmail: string
  ): Promise<{ message: string }> {
    try {
      const user = await this.userRepo.findById(userId);

      if (!user) {
        throw new HttpError(404, "Người dùng không tồn tại");
      }

      // Kiểm tra email mới có trùng không
      const existingUser = await this.userRepo.findByEmail(newEmail);
      if (existingUser && existingUser._id.toString() !== userId) {
        throw new HttpError(409, "Email này đã được sử dụng bởi tài khoản khác");
      }

      if (user.email === newEmail) {
        throw new HttpError(400, "Email mới phải khác email hiện tại");
      }

      // Tạo token đổi email
      const tokenPayload = {
        userId: user._id.toString(),
        oldEmail: user.email,
        newEmail: newEmail,
        type: "email_change",
      };
      const changeEmailToken = JwtUtils.generateVerificationToken(
        tokenPayload,
        "1h"
      );

      // Lưu token vào database (tạm dùng emailVerificationToken)
      user.emailVerificationToken = changeEmailToken;
      user.emailVerificationExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 giờ
      await user.save();

      // TODO: Gửi email xác nhận đến email mới
      // await EmailService.sendChangeEmailConfirmation(newEmail, user.fullname, changeEmailToken);

      await logAudit({
        userId: user._id.toString(),
        action: "requestChangeEmail",
        message: `Email change requested from ${user.email} to ${newEmail}`,
        status: StatusLogEnum.Success,
        targetId: user._id.toString(),
        metadata: { oldEmail: user.email, newEmail },
      });

      return {
        message: "Yêu cầu đổi email đã được gửi. Vui lòng kiểm tra email mới để xác nhận.",
      };
    } catch (error: any) {
      await logError({
        action: "requestChangeEmail",
        message: error.message || "Failed to request email change",
        errorMessage: error.stack || error,
      });
      throw error;
    }
  }

  /**
   * Xác nhận đổi email
   * @param token - Token xác nhận đổi email
   */
  async confirmChangeEmail(token: string): Promise<{ message: string }> {
    try {
      let decoded: any;
      try {
        decoded = JwtUtils.verifyVerificationToken(token);
      } catch (err) {
        throw new HttpError(400, "Token không hợp lệ hoặc đã hết hạn");
      }

      if (decoded.type !== "email_change") {
        throw new HttpError(400, "Token không hợp lệ");
      }

      const user = await this.userRepo.findById(decoded.userId);

      if (!user) {
        throw new HttpError(404, "Người dùng không tồn tại");
      }

      // Kiểm tra token có khớp không
      if (user.emailVerificationToken !== token) {
        throw new HttpError(400, "Token không hợp lệ");
      }

      // Kiểm tra email mới có bị chiếm chưa
      const existingUser = await this.userRepo.findByEmail(decoded.newEmail);
      if (existingUser && existingUser._id.toString() !== decoded.userId) {
        throw new HttpError(409, "Email này đã được sử dụng bởi tài khoản khác");
      }

      // Cập nhật email
      const oldEmail = user.email;
      user.email = decoded.newEmail;
      user.isEmailVerified = true; // Email mới đã được xác thực qua link
      user.emailVerificationToken = null;
      user.emailVerificationExpires = null;
      await user.save();

      await logAudit({
        userId: user._id.toString(),
        action: "confirmChangeEmail",
        message: `Email changed from ${oldEmail} to ${decoded.newEmail}`,
        status: StatusLogEnum.Success,
        targetId: user._id.toString(),
        metadata: { oldEmail, newEmail: decoded.newEmail },
      });

      return {
        message: "Email đã được đổi thành công!",
      };
    } catch (error: any) {
      await logError({
        action: "confirmChangeEmail",
        message: error.message || "Failed to confirm email change",
        errorMessage: error.stack || error,
      });
      throw error;
    }
  }
}


import { UserRepository } from "../../repositories";
import { JwtUtils } from "../../../utils/JwtUtils";
import { EmailService } from "../../../utils/EmailService";
import { HttpError } from "../../../utils/HttpError";
import { logAudit, logError } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { hashPassword } from "../../../utils/PasswordUtil";

/**
 * ForgotPassword Service - Xử lý logic quên mật khẩu
 */
export class ForgotPasswordService {
  private readonly userRepo: UserRepository;

  constructor(userRepo: UserRepository) {
    this.userRepo = userRepo;
  }

  /**
   * Tạo mã reset code 6 số ngẫu nhiên
   */
  private generateResetCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  /**
   * Bước 1: Yêu cầu khôi phục mật khẩu
   * - Kiểm tra email tồn tại
   * - Kiểm tra email đã verified chưa
   * - Tạo và gửi mã code 6 số
   * @param email - Email của user
   */
  async requestPasswordReset(email: string): Promise<{
    success: boolean;
    message: string;
    requireEmailVerification?: boolean;
  }> {
    try {
      // Tìm user bằng email
      const user = await this.userRepo.findByEmail(email);

      // Nếu không tìm thấy user, vẫn trả về message chung để bảo mật
      // (không tiết lộ email có tồn tại hay không)
      if (!user) {
        return {
          success: true,
          message:
            "Nếu email tồn tại trong hệ thống, bạn sẽ nhận được mã khôi phục.",
        };
      }

      // Kiểm tra email đã được xác thực chưa
      if (!user.isEmailVerified) {
        // Tự động gửi email xác thực
        try {
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
          const verifyExpiresAt = new Date();
          verifyExpiresAt.setHours(verifyExpiresAt.getHours() + 24);

          // Lưu token vào database
          user.emailVerificationToken = verificationToken;
          user.emailVerificationExpires = verifyExpiresAt;
          await user.save();

          // Gửi email xác thực
          await EmailService.sendVerificationEmail(
            user.email,
            user.fullname,
            verificationToken
          );

          await logAudit({
            userId: user._id.toString(),
            action: "requestPasswordReset",
            message: `Password reset requested but email not verified. Verification email sent to ${user.email}`,
            status: StatusLogEnum.Failure,
            targetId: user._id.toString(),
            metadata: { email: user.email, reason: "email_not_verified", verificationEmailSent: true },
          });
        } catch (emailError: any) {
          await logError({
            action: "sendVerificationEmailOnPasswordReset",
            message: `Failed to send verification email to ${user.email}`,
            errorMessage: emailError.stack || emailError,
          });
        }

        return {
          success: false,
          requireEmailVerification: true,
          message:
            "Email chưa được xác thực. Chúng tôi đã gửi email xác thực đến hộp thư của bạn. Vui lòng xác thực email trước khi khôi phục mật khẩu.",
        };
      }

      // Kiểm tra rate limiting (không cho request trong 1 phút)
      if (
        user.passwordResetExpires &&
        new Date() < new Date(user.passwordResetExpires.getTime() - 9 * 60 * 1000)
      ) {
        throw new HttpError(
          429,
          "Vui lòng đợi ít nhất 1 phút trước khi yêu cầu mã khôi phục mới."
        );
      }

      // Tạo mã reset code 6 số
      const resetCode = this.generateResetCode();

      // Tính thời gian hết hạn (10 phút)
      const expiresAt = new Date();
      expiresAt.setMinutes(expiresAt.getMinutes() + 10);

      // Lưu code vào database
      user.passwordResetCode = resetCode;
      user.passwordResetExpires = expiresAt;
      user.passwordResetToken = null; // Clear any existing token
      await user.save();

      // Gửi email
      await EmailService.sendPasswordResetEmail(
        user.email,
        user.fullname,
        resetCode
      );

      await logAudit({
        userId: user._id.toString(),
        action: "requestPasswordReset",
        message: `Password reset code sent to ${user.email}`,
        status: StatusLogEnum.Success,
        targetId: user._id.toString(),
        metadata: { email: user.email },
      });

      return {
        success: true,
        message: "Mã khôi phục đã được gửi đến email của bạn.",
      };
    } catch (error: any) {
      await logError({
        action: "requestPasswordReset",
        message: error.message || "Failed to request password reset",
        errorMessage: error.stack || error,
      });
      throw error;
    }
  }

  /**
   * Bước 2: Xác thực mã reset code
   * - Kiểm tra code có đúng không
   * - Kiểm tra code còn hạn không
   * - Trả về reset token
   * @param email - Email của user
   * @param code - Mã 6 số từ email
   */
  async verifyResetCode(
    email: string,
    code: string
  ): Promise<{
    success: boolean;
    resetToken?: string;
    message?: string;
  }> {
    try {
      const user = await this.userRepo.findByEmail(email);

      if (!user) {
        throw new HttpError(400, "Mã khôi phục không hợp lệ.");
      }

      // Kiểm tra code có tồn tại không
      if (!user.passwordResetCode) {
        throw new HttpError(
          400,
          "Không tìm thấy yêu cầu khôi phục mật khẩu. Vui lòng yêu cầu mã mới."
        );
      }

      // Kiểm tra code có khớp không
      if (user.passwordResetCode !== code) {
        await logAudit({
          userId: user._id.toString(),
          action: "verifyResetCode",
          message: `Invalid reset code attempt for ${user.email}`,
          status: StatusLogEnum.Failure,
          targetId: user._id.toString(),
          metadata: { email: user.email },
        });

        throw new HttpError(400, "Mã khôi phục không đúng.");
      }

      // Kiểm tra code còn hạn không
      if (
        user.passwordResetExpires &&
        new Date() > user.passwordResetExpires
      ) {
        // Clear expired code
        user.passwordResetCode = null;
        user.passwordResetExpires = null;
        await user.save();

        throw new HttpError(
          400,
          "Mã khôi phục đã hết hạn. Vui lòng yêu cầu mã mới."
        );
      }

      // Tạo reset token (JWT - hết hạn 15 phút)
      const tokenPayload = {
        userId: user._id.toString(),
        email: user.email,
        type: "password_reset",
      };
      const resetToken = JwtUtils.generateVerificationToken(tokenPayload, "15m");

      // Tính thời gian hết hạn token (15 phút)
      const tokenExpiresAt = new Date();
      tokenExpiresAt.setMinutes(tokenExpiresAt.getMinutes() + 15);

      // Lưu token vào database và xóa code
      user.passwordResetToken = resetToken;
      user.passwordResetCode = null;
      user.passwordResetExpires = tokenExpiresAt;
      await user.save();

      await logAudit({
        userId: user._id.toString(),
        action: "verifyResetCode",
        message: `Reset code verified successfully for ${user.email}`,
        status: StatusLogEnum.Success,
        targetId: user._id.toString(),
        metadata: { email: user.email },
      });

      return {
        success: true,
        resetToken: resetToken,
      };
    } catch (error: any) {
      await logError({
        action: "verifyResetCode",
        message: error.message || "Failed to verify reset code",
        errorMessage: error.stack || error,
      });
      throw error;
    }
  }

  /**
   * Bước 3: Đặt lại mật khẩu
   * - Verify reset token
   * - Cập nhật mật khẩu mới
   * - Xóa các token/code cũ
   * @param resetToken - Token từ bước verify code
   * @param newPassword - Mật khẩu mới
   */
  async resetPassword(
    resetToken: string,
    newPassword: string
  ): Promise<{
    success: boolean;
    message: string;
  }> {
    try {
      // Verify token
      let decoded: any;
      try {
        decoded = JwtUtils.verifyVerificationToken(resetToken);
      } catch (err) {
        throw new HttpError(400, "Token không hợp lệ hoặc đã hết hạn.");
      }

      // Kiểm tra token type
      if (decoded.type !== "password_reset") {
        throw new HttpError(400, "Token không hợp lệ.");
      }

      // Tìm user
      const user = await this.userRepo.findById(decoded.userId);

      if (!user) {
        throw new HttpError(404, "Người dùng không tồn tại.");
      }

      // Kiểm tra token có khớp với token trong DB không
      if (user.passwordResetToken !== resetToken) {
        throw new HttpError(400, "Token không hợp lệ hoặc đã được sử dụng.");
      }

      // Kiểm tra token còn hạn không
      if (
        user.passwordResetExpires &&
        new Date() > user.passwordResetExpires
      ) {
        // Clear expired token
        user.passwordResetToken = null;
        user.passwordResetExpires = null;
        await user.save();

        throw new HttpError(
          400,
          "Token đã hết hạn. Vui lòng yêu cầu khôi phục mật khẩu mới."
        );
      }

      // Validate mật khẩu mới
      if (!newPassword || newPassword.length < 6) {
        throw new HttpError(400, "Mật khẩu mới phải có ít nhất 6 ký tự.");
      }

      // Mã hóa mật khẩu mới
      const newPasswordHash = await hashPassword(newPassword);

      // Cập nhật mật khẩu và xóa reset token/code
      user.passwordHashed = newPasswordHash;
      user.passwordResetCode = null;
      user.passwordResetToken = null;
      user.passwordResetExpires = null;
      await user.save();

      // Gửi email thông báo
      await EmailService.sendPasswordResetSuccessEmail(
        user.email,
        user.fullname
      );

      await logAudit({
        userId: user._id.toString(),
        action: "resetPassword",
        message: `Password reset successfully for ${user.email}`,
        status: StatusLogEnum.Success,
        targetId: user._id.toString(),
        metadata: { email: user.email },
      });

      return {
        success: true,
        message: "Mật khẩu đã được đặt lại thành công.",
      };
    } catch (error: any) {
      await logError({
        action: "resetPassword",
        message: error.message || "Failed to reset password",
        errorMessage: error.stack || error,
      });
      throw error;
    }
  }

  /**
   * Gửi lại mã reset code
   * @param email - Email của user
   */
  async resendResetCode(email: string): Promise<{
    success: boolean;
    message: string;
    requireEmailVerification?: boolean;
  }> {
    // Reuse requestPasswordReset logic
    return this.requestPasswordReset(email);
  }
}


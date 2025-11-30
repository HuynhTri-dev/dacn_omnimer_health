import { Request, Response, NextFunction } from "express";
import { ForgotPasswordService } from "../../services/Profile/ForgotPassword.service";
import { sendSuccess, sendBadRequest } from "../../../utils/ResponseHelper";

export class ForgotPasswordController {
  private readonly forgotPasswordService: ForgotPasswordService;

  constructor(forgotPasswordService: ForgotPasswordService) {
    this.forgotPasswordService = forgotPasswordService;
  }

  /**
   * Yêu cầu khôi phục mật khẩu
   * POST /api/v1/forgot-password/request
   * Body: { email: string }
   * Public endpoint
   */
  requestPasswordReset = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { email } = req.body;

      if (!email) {
        return sendBadRequest(res, "Vui lòng cung cấp email.");
      }

      // Validate email format
      const emailRegex = /^\S+@\S+\.\S+$/;
      if (!emailRegex.test(email)) {
        return sendBadRequest(res, "Email không hợp lệ.");
      }

      const result = await this.forgotPasswordService.requestPasswordReset(
        email.toLowerCase().trim()
      );

      // Nếu email chưa verified, trả về status khác để frontend xử lý
      if (result.requireEmailVerification) {
        return res.status(403).json({
          success: false,
          requireEmailVerification: true,
          message: result.message,
        });
      }

      return sendSuccess(res, { success: result.success }, result.message);
    } catch (err) {
      next(err);
    }
  };

  /**
   * Xác thực mã reset code
   * POST /api/v1/forgot-password/verify-code
   * Body: { email: string, code: string }
   * Public endpoint
   */
  verifyResetCode = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { email, code } = req.body;

      if (!email) {
        return sendBadRequest(res, "Vui lòng cung cấp email.");
      }

      if (!code) {
        return sendBadRequest(res, "Vui lòng nhập mã khôi phục.");
      }

      // Validate code format (6 digits)
      if (!/^\d{6}$/.test(code)) {
        return sendBadRequest(res, "Mã khôi phục phải là 6 chữ số.");
      }

      const result = await this.forgotPasswordService.verifyResetCode(
        email.toLowerCase().trim(),
        code
      );

      return sendSuccess(
        res,
        { resetToken: result.resetToken },
        "Mã xác thực hợp lệ."
      );
    } catch (err) {
      next(err);
    }
  };

  /**
   * Đặt lại mật khẩu
   * POST /api/v1/forgot-password/reset
   * Body: { resetToken: string, newPassword: string }
   * Public endpoint
   */
  resetPassword = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { resetToken, newPassword } = req.body;

      if (!resetToken) {
        return sendBadRequest(res, "Token không hợp lệ.");
      }

      if (!newPassword) {
        return sendBadRequest(res, "Vui lòng nhập mật khẩu mới.");
      }

      if (newPassword.length < 6) {
        return sendBadRequest(res, "Mật khẩu mới phải có ít nhất 6 ký tự.");
      }

      const result = await this.forgotPasswordService.resetPassword(
        resetToken,
        newPassword
      );

      return sendSuccess(res, { success: result.success }, result.message);
    } catch (err) {
      next(err);
    }
  };

  /**
   * Gửi lại mã reset code
   * POST /api/v1/forgot-password/resend-code
   * Body: { email: string }
   * Public endpoint
   */
  resendResetCode = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { email } = req.body;

      if (!email) {
        return sendBadRequest(res, "Vui lòng cung cấp email.");
      }

      // Validate email format
      const emailRegex = /^\S+@\S+\.\S+$/;
      if (!emailRegex.test(email)) {
        return sendBadRequest(res, "Email không hợp lệ.");
      }

      const result = await this.forgotPasswordService.resendResetCode(
        email.toLowerCase().trim()
      );

      // Nếu email chưa verified, trả về status khác để frontend xử lý
      if (result.requireEmailVerification) {
        return res.status(403).json({
          success: false,
          requireEmailVerification: true,
          message: result.message,
        });
      }

      return sendSuccess(res, { success: result.success }, result.message);
    } catch (err) {
      next(err);
    }
  };
}


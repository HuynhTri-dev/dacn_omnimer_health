import { Request, Response, NextFunction } from "express";
import { VerificationService } from "../../services/Profile/Verification.service";
import {
  sendSuccess,
  sendBadRequest,
} from "../../../utils/ResponseHelper";
import { HttpError } from "../../../utils/HttpError";

export class VerificationController {
  private readonly verificationService: VerificationService;

  constructor(verificationService: VerificationService) {
    this.verificationService = verificationService;
  }

  /**
   * Gửi email xác thực
   * POST /api/v1/verification/send-verification-email
   * Requires: Authentication
   */
  sendVerificationEmail = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const userId = req.user?.id;

      if (!userId) {
        return sendBadRequest(res, "Không tìm thấy thông tin người dùng");
      }

      const result = await this.verificationService.sendVerificationEmail(
        userId
      );

      return sendSuccess(res, result, "Email xác thực đã được gửi");
    } catch (err) {
      next(err);
    }
  };

  /**
   * Xác thực email bằng token
   * GET /api/v1/verification/verify-email?token=xxx
   * Public endpoint (không cần authentication)
   */
  verifyEmail = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { token } = req.query;

      if (!token || typeof token !== "string") {
        // Trả về trang HTML lỗi
        return res.status(400).send(this.renderErrorPage("Token không hợp lệ"));
      }

      const result = await this.verificationService.verifyEmail(token);

      // Trả về trang HTML thành công với deep link về app
      return res.status(200).send(this.renderSuccessPage());
    } catch (err: any) {
      // Trả về trang HTML lỗi
      const message = err instanceof HttpError ? err.message : "Có lỗi xảy ra";
      return res.status(err.statusCode || 400).send(this.renderErrorPage(message));
    }
  };

  /**
   * Gửi lại email xác thực
   * POST /api/v1/verification/resend-verification-email
   * Requires: Authentication
   */
  resendVerificationEmail = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const userId = req.user?.id;

      if (!userId) {
        return sendBadRequest(res, "Không tìm thấy thông tin người dùng");
      }

      const result = await this.verificationService.resendVerificationEmail(
        userId
      );

      return sendSuccess(res, result, "Email xác thực đã được gửi lại");
    } catch (err) {
      next(err);
    }
  };

  /**
   * Lấy trạng thái xác thực
   * GET /api/v1/verification/status
   * Requires: Authentication
   */
  getVerificationStatus = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const userId = req.user?.id;

      if (!userId) {
        return sendBadRequest(res, "Không tìm thấy thông tin người dùng");
      }

      const result = await this.verificationService.getVerificationStatus(
        userId
      );

      return sendSuccess(res, result, "Lấy trạng thái xác thực thành công");
    } catch (err) {
      next(err);
    }
  };

  /**
   * Yêu cầu đổi email
   * POST /api/v1/verification/request-change-email
   * Requires: Authentication
   * Body: { newEmail: string }
   */
  requestChangeEmail = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const userId = req.user?.id;
      const { newEmail } = req.body;

      if (!userId) {
        return sendBadRequest(res, "Không tìm thấy thông tin người dùng");
      }

      if (!newEmail) {
        return sendBadRequest(res, "Vui lòng cung cấp email mới");
      }

      // Validate email format
      const emailRegex = /^\S+@\S+\.\S+$/;
      if (!emailRegex.test(newEmail)) {
        return sendBadRequest(res, "Email không hợp lệ");
      }

      const result = await this.verificationService.requestChangeEmail(
        userId,
        newEmail
      );

      return sendSuccess(res, result, "Yêu cầu đổi email đã được gửi");
    } catch (err) {
      next(err);
    }
  };

  /**
   * Xác nhận đổi email
   * GET /api/v1/verification/confirm-change-email?token=xxx
   * Public endpoint
   */
  confirmChangeEmail = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { token } = req.query;

      if (!token || typeof token !== "string") {
        return res.status(400).send(this.renderErrorPage("Token không hợp lệ"));
      }

      const result = await this.verificationService.confirmChangeEmail(token);

      return res.status(200).send(this.renderSuccessPage("Email đã được đổi thành công!"));
    } catch (err: any) {
      const message = err instanceof HttpError ? err.message : "Có lỗi xảy ra";
      return res.status(err.statusCode || 400).send(this.renderErrorPage(message));
    }
  };

  /**
   * Render trang HTML thành công
   */
  private renderSuccessPage(message: string = "Email đã được xác thực thành công!"): string {
    const clientUrl = process.env.CLIENT_URL || "omnihealthapp://verified";
    
    return `
      <!DOCTYPE html>
      <html lang="vi">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Xác thực thành công - OmniMer Health</title>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
          }
          .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            text-align: center;
            max-width: 400px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
          }
          .icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 40px;
            color: white;
          }
          h1 { color: #1a1a2e; margin-bottom: 15px; font-size: 24px; }
          p { color: #4a5568; margin-bottom: 30px; line-height: 1.6; }
          .btn {
            display: inline-block;
            padding: 15px 40px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 50px;
            font-weight: 600;
            transition: transform 0.2s;
          }
          .btn:hover { transform: scale(1.05); }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="icon">✓</div>
          <h1>Thành công!</h1>
          <p>${message}</p>
          <a href="${clientUrl}" class="btn">Mở Ứng dụng</a>
        </div>
        <script>
          // Auto redirect after 3 seconds
          setTimeout(() => {
            window.location.href = "${clientUrl}";
          }, 3000);
        </script>
      </body>
      </html>
    `;
  }

  /**
   * Render trang HTML lỗi
   */
  private renderErrorPage(message: string): string {
    return `
      <!DOCTYPE html>
      <html lang="vi">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Lỗi - OmniMer Health</title>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
          }
          .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            text-align: center;
            max-width: 400px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
          }
          .icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 40px;
            color: white;
          }
          h1 { color: #1a1a2e; margin-bottom: 15px; font-size: 24px; }
          p { color: #4a5568; margin-bottom: 30px; line-height: 1.6; }
          .error-box {
            background: #fef2f2;
            border: 1px solid #fecaca;
            border-radius: 10px;
            padding: 15px;
            color: #991b1b;
            margin-bottom: 20px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="icon">✕</div>
          <h1>Có lỗi xảy ra</h1>
          <div class="error-box">${message}</div>
          <p>Vui lòng thử lại hoặc liên hệ hỗ trợ nếu vấn đề vẫn tiếp tục.</p>
        </div>
      </body>
      </html>
    `;
  }
}


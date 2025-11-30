import { Request, Response, NextFunction } from "express";
import { AuthService } from "../../services";
import { HttpError } from "../../../utils/HttpError";
import {
  sendBadRequest,
  sendCreated,
  sendSuccess,
} from "../../../utils/ResponseHelper";

export class AuthController {
  private readonly authService: AuthService;

  constructor(authService: AuthService) {
    this.authService = authService;
  }

  /**
   * Đăng ký tài khoản mới + tự động đăng nhập
   */
  register = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const avatarImage = req.file;

      const result = await this.authService.register(req.body, avatarImage);

      sendCreated(res, result, "Đăng ký thành công");
    } catch (err) {
      next(err);
    }
  };

  login = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        throw new HttpError(400, "Thiếu email hoặc password");
      }

      const result = await this.authService.login(email, password);

      sendSuccess(res, result, "Đăng nhập thành công");
    } catch (err: any) {
      next(err);
    }
  };

  createNewAccessToken = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        sendBadRequest(res, "Thiếu refresh token");
        return;
      }

      const newTokens = await this.authService.createNewAccessToken(
        refreshToken
      );

      return sendSuccess(res, newTokens, "Tokens refreshed successfully");
    } catch (err: any) {
      next(err);
    }
  };

  getAuth = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const id = req.user?.id;

      if (!id) {
        sendBadRequest(res, "Thiếu dữ liệu");
        return;
      }

      const user = await this.authService.getAuth(id);

      return sendSuccess(res, user, "Get Auth Success");
    } catch (err: any) {
      next(err);
    }
  };

  /**
   * Thay đổi mật khẩu người dùng
   */
  changePassword = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.id;
      const { currentPassword, newPassword } = req.body;

      if (!userId) {
        sendBadRequest(res, "Không tìm thấy thông tin người dùng");
        return;
      }

      if (!currentPassword || !newPassword) {
        sendBadRequest(res, "Thiếu mật khẩu hiện tại hoặc mật khẩu mới");
        return;
      }

      if (newPassword.length < 8) {
        sendBadRequest(res, "Mật khẩu mới phải có ít nhất 8 ký tự");
        return;
      }

      await this.authService.changePassword(userId, currentPassword, newPassword);

      return sendSuccess(res, null, "Thay đổi mật khẩu thành công");
    } catch (err: any) {
      next(err);
    }
  };
}

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
}

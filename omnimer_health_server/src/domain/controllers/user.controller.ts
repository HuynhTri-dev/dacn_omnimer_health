import { Request, Response, NextFunction } from "express";
import { UserService } from "../services/user.service";
import { UserRepository } from "../repositories/user.repository";
import { HttpError } from "../../utils/HttpError";
import { sendCreated, sendSuccess } from "../../utils/ResponseHelper";

export class UserController {
  private readonly userService: UserService;

  constructor(userService: UserService) {
    this.userService = userService;
  }

  /**
   * Đăng ký tài khoản mới + tự động đăng nhập
   */
  register = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await this.userService.register(req.body);

      sendCreated(res, result, "Đăng ký thành công");
    } catch (err: any) {
      return next(new HttpError(500, err.message || "Đăng ký thất bại"));
    }
  };

  login = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { idToken } = req.body;
      if (!idToken) throw new HttpError(400, "Thiếu idToken");

      const result = await this.userService.login(idToken);
      sendSuccess(res, result, "Đăng nhập thành công");
    } catch (err: any) {
      return next(
        new HttpError(401, err.message || "Xác thực Firebase thất bại")
      );
    }
  };
}

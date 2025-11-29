import { Request, Response, NextFunction } from "express";
import { UserService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class UserController {
  private readonly userService: UserService;

  constructor(userService: UserService) {
    this.userService = userService;
  }

  // =================== UPDATE ===================
  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);

      const { id } = req.params;

      const imageFile = req.file;

      const updated = await this.userService.updateUser(
        userId,
        id,
        imageFile,
        req.body
      );

      // Filter out unnecessary fields
      let responseData: any = updated;
      if (updated && typeof (updated as any).toObject === "function") {
        responseData = (updated as any).toObject();
      } else if (updated) {
        responseData = { ...updated };
      }

      if (responseData) {
        delete (responseData as any).passwordHashed;
        delete (responseData as any).email;
        delete (responseData as any).roleIds;
      }

      return sendSuccess(
        res,
        responseData,
        "Cập nhật thông tin cá nhân thành công"
      );
    } catch (err) {
      next(err);
    }
  };

  // =================== GET ALL ===================
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const options = buildQueryOptions(req.query as any);

      const list = await this.userService.getAllUsers(options);

      return sendSuccess(res, list, "Lấy danh sách người dùng thành công");
    } catch (err) {
      next(err);
    }
  };
}

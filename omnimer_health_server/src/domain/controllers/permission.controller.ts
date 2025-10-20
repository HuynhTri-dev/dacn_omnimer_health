import { Request, Response, NextFunction } from "express";
import { PermissionService } from "../services";
import { sendSuccess, sendCreated } from "../../utils/ResponseHelper";
import { HttpError } from "../../utils/HttpError";

export class PermissionController {
  private readonly service: PermissionService;

  // Constructor cho phép inject service (dễ test hoặc mock)
  constructor(service: PermissionService) {
    this.service = service;
  }

  // =================== CREATE ===================
  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user?.id?.toString();
      if (!userId) throw new HttpError(401, "Người dùng chưa đăng nhập");

      const permission = await this.service.createPermission(userId, req.body);
      return sendCreated(res, permission, "Tạo permission thành công");
    } catch (err) {
      next(err);
    }
  }

  // =================== GET ALL ===================
  async getAll(req: Request, res: Response, next: NextFunction) {
    try {
      const permissions = await this.service.getPermissions();
      return sendSuccess(res, permissions, "Danh sách permissions");
    } catch (err) {
      next(err);
    }
  }

  // =================== DELETE ===================
  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user?.id?.toString();
      if (!userId) throw new HttpError(401, "Người dùng chưa đăng nhập");

      const permission = await this.service.deletePermission(
        req.params.id,
        userId
      );
      return sendSuccess(res, permission, "Xóa permission thành công");
    } catch (err) {
      next(err);
    }
  }
}

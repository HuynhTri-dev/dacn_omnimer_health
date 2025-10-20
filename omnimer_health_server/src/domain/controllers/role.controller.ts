import { Request, Response, NextFunction } from "express";
import { RoleService } from "../services";
import { sendSuccess, sendCreated } from "../../utils/ResponseHelper";
import { HttpError } from "../../utils/HttpError";
import { DecodePayload } from "../entities/DecodePayload";

export class RoleController {
  private readonly service: RoleService;

  constructor(service: RoleService) {
    this.service = service;
  }

  // =================== CREATE ===================
  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user?.id?.toString();
      if (!userId) throw new HttpError(401, "Người dùng chưa đăng nhập");

      const role = await this.service.createRole(userId, req.body);
      return sendCreated(res, role, "Tạo role thành công");
    } catch (err) {
      next(err);
    }
  }

  // =================== GET ALL ===================
  async getAll(req: Request, res: Response, next: NextFunction) {
    try {
      const roles = await this.service.getRoles();
      return sendSuccess(res, roles, "Danh sách roles");
    } catch (err) {
      next(err);
    }
  }

  // =================== DELETE ===================
  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user?.id?.toString();
      if (!userId) throw new HttpError(401, "Người dùng chưa đăng nhập");

      const deleted = await this.service.deleteRole(req.params.id, userId);
      return sendSuccess(res, deleted, "Xóa role thành công");
    } catch (err) {
      next(err);
    }
  }
}

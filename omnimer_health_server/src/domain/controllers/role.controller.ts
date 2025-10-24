import { Request, Response, NextFunction } from "express";
import { RoleService } from "../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
  sendBadRequest,
} from "../../utils/ResponseHelper";
import { HttpError } from "../../utils/HttpError";
import { DecodePayload } from "../entities/DecodePayload";

export class RoleController {
  private readonly service: RoleService;

  constructor(service: RoleService) {
    this.service = service;
  }

  // =================== CREATE ===================
  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user.id.toString();

      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const role = await this.service.createRole(userId, req.body);
      return sendCreated(res, role, "Tạo role thành công");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET ALL ===================
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const roles = await this.service.getRoles();
      return sendSuccess(res, roles, "Danh sách roles");
    } catch (err) {
      next(err);
    }
  };

  // =================== DELETE ===================
  delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user.id.toString();

      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const deleted = await this.service.deleteRole(req.params.id, userId);
      return sendSuccess(res, deleted, "Xóa vai trò thành công");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET BY ID ===================
  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const role = await this.service.getRoleById(req.params.id);
      return sendSuccess(res, role, "Chi tiết vai trò");
    } catch (err) {
      next(err);
    }
  };

  // =================== UPDATE ROLE ===================
  updateRole = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user.id.toString();

      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const updatedRole = await this.service.updateRole(
        req.params.id,
        req.body,
        userId
      );

      return sendSuccess(res, updatedRole, "Cập nhật vai trò thành công");
    } catch (err) {
      next(err);
    }
  };

  // =================== UPDATE PERMISSION IDS ===================
  updatePermissionIds = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user.id.toString();

      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const updatedRole = await this.service.updatePermissionIds(
        req.params.id,
        req.body.permissionIds,
        userId
      );

      return sendSuccess(
        res,
        updatedRole,
        "Cập nhật quyền cho vai trò thành công"
      );
    } catch (err) {
      next(err);
    }
  };
}

import { Request, Response, NextFunction } from "express";
import { PermissionService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities/DecodePayload.entity";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class PermissionController {
  private readonly PermissionService: PermissionService;

  // Constructor cho phép inject PermissionService (dễ test hoặc mock)
  constructor(PermissionService: PermissionService) {
    this.PermissionService = PermissionService;
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

      const permission = await this.PermissionService.createPermission(
        userId,
        req.body
      );
      return sendCreated(res, permission, "Tạo quyền thành công");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET ALL ===================
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const options = buildQueryOptions(req.params as any);
      const permissions = await this.PermissionService.getPermissions(options);
      return sendSuccess(res, permissions, "Danh sách quyền hạn");
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

      const permission = await this.PermissionService.deletePermission(
        req.params.id,
        userId
      );
      return sendSuccess(res, permission, "Xóa quyền hạn thành công");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET BY ID ===================
  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const permission = await this.PermissionService.getPermissionById(
        req.params.id
      );
      return sendSuccess(res, permission, "Chi tiết quyền hạn");
    } catch (err) {
      next(err);
    }
  };

  // =================== UPDATE ===================
  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user.id.toString();

      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const permission = await this.PermissionService.updatePermission(
        req.params.id,
        req.body,
        userId
      );
      return sendSuccess(res, permission, "Cập nhật quyền hạn thành công");
    } catch (err) {
      next(err);
    }
  };
}

import { PermissionRepository } from "../../repositories";
import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { IPermission } from "../../models";
import { HttpError } from "../../../utils/HttpError";
import { PaginationQueryOptions } from "../../entities";

export class PermissionService {
  private readonly permissionRepo: PermissionRepository;

  constructor(permissionRepo: PermissionRepository) {
    this.permissionRepo = permissionRepo;
  }

  // =================== CREATE ===================
  async createPermission(userId: string, data: Partial<IPermission>) {
    try {
      // Kiểm tra trùng key
      const key = data.key;
      const exists = await this.permissionRepo.findOne({ key });

      if (exists) {
        await logAudit({
          userId,
          action: "createPermission",
          message: `Permission key "${key}" đã tồn tại`,
          status: StatusLogEnum.Failure,
        });
        throw { status: 400, message: `Permission key "${key}" đã tồn tại` };
      }

      const permission = await this.permissionRepo.create(data);

      await logAudit({
        userId,
        action: "createPermission",
        message: `Tạo permission "${key}" thành công`,
        status: StatusLogEnum.Success,
        targetId: permission._id.toString(),
      });

      return permission;
    } catch (err: any) {
      await logError({
        userId,
        action: "createPermission",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== GET ALL ===================
  async getPermissions(options?: PaginationQueryOptions) {
    try {
      return await this.permissionRepo.findAll({}, options);
    } catch (err: any) {
      await logError({
        action: "getPermissions",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== DELETE ===================
  async deletePermission(permissionId: string, userId?: string) {
    try {
      const deleted = await this.permissionRepo.delete(permissionId);

      if (!deleted) {
        await logAudit({
          userId,
          action: "deletePermission",
          message: `Permission "${permissionId}" không tồn tại`,
          status: StatusLogEnum.Failure,
        });
        throw { status: 404, message: "Permission không tồn tại" };
      }

      await logAudit({
        userId,
        action: "deletePermission",
        message: `Xóa permission "${permissionId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: permissionId,
      });

      return deleted;
    } catch (err: any) {
      await logError({
        userId,
        action: "deletePermission",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== GET BY ID ===================
  async getPermissionById(permissionId: string) {
    try {
      const permission = await this.permissionRepo.findById(permissionId);
      if (!permission) {
        throw new HttpError(404, "Vai trò không tồn tại");
      }
      return permission;
    } catch (err: any) {
      await logError({
        action: "getPermissionById",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== UPDATE ===================
  async updatePermission(
    permissionId: string,
    data: Partial<IPermission>,
    userId?: string
  ) {
    try {
      // Kiểm tra permission tồn tại
      const permission = await this.permissionRepo.findOne({
        _id: permissionId,
      });
      if (!permission) {
        await logAudit({
          userId,
          action: "updatePermission",
          message: `Permission "${permissionId}" không tồn tại`,
          status: StatusLogEnum.Failure,
        });
        throw new HttpError(404, "Quyền hạn này không tồn tại");
      }

      // Nếu cập nhật key mới, kiểm tra trùng
      if (data.key && data.key !== permission.key) {
        const exists = await this.permissionRepo.findOne({ key: data.key });
        if (exists) {
          await logAudit({
            userId,
            action: "updatePermission",
            message: `Permission key "${data.key}" đã tồn tại`,
            status: StatusLogEnum.Failure,
          });
          throw new HttpError(400, "Quyền hạn này đã tồn tại");
        }
      }

      // Cập nhật permission
      const updated = await this.permissionRepo.update(permissionId, data);

      await logAudit({
        userId,
        action: "updatePermission",
        message: `Cập nhật permission "${permissionId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: permissionId,
      });

      return updated;
    } catch (err: any) {
      await logError({
        userId,
        action: "updatePermission",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }
}

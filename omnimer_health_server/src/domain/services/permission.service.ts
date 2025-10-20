import { PermissionRepository } from "../repositories";
import { logError, logAudit } from "../../utils/LoggerUtil";
import { StatusLogEnum } from "../../common/constants/AppConstants";
import { IPermission } from "../models";

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
        metadata: { permissionId: permission._id.toString() },
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
  async getPermissions() {
    try {
      return await this.permissionRepo.findAll({});
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
        metadata: { permissionId },
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
}

import { RoleRepository } from "../../repositories";
import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { IRole } from "../../models";
import { HttpError } from "../../../utils/HttpError";

export class RoleService {
  private readonly roleRepo: RoleRepository;

  constructor(roleRepo: RoleRepository) {
    this.roleRepo = roleRepo;
  }

  // =================== CREATE ===================
  async createRole(userId: string, data: Partial<IRole>) {
    try {
      const role = await this.roleRepo.create(data);

      await logAudit({
        userId,
        action: "createRole",
        message: `Tạo role "${role.name}" thành công`,
        status: StatusLogEnum.Success,
        targetId: role._id.toString(),
      });

      return role;
    } catch (err: any) {
      await logError({
        userId,
        action: "createRole",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== GET ALL ===================
  async getRoles() {
    try {
      return await this.roleRepo.findAll({});
    } catch (err: any) {
      await logError({
        action: "getRoles",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== DELETE ===================
  async deleteRole(roleId: string, userId?: string) {
    try {
      const deleted = await this.roleRepo.delete(roleId);

      if (!deleted) {
        await logAudit({
          userId,
          action: "deleteRole",
          message: `Role "${roleId}" không tồn tại`,
          status: StatusLogEnum.Failure,
        });
        throw { status: 404, message: "Role không tồn tại" };
      }

      await logAudit({
        userId,
        action: "deleteRole",
        message: `Xóa role "${roleId}" thành công`,
        status: StatusLogEnum.Success,
        metadata: { roleId },
      });

      return deleted;
    } catch (err: any) {
      await logError({
        userId,
        action: "deleteRole",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== GET BY ID ===================
  async getRoleById(roleId: string) {
    try {
      const role = await this.roleRepo.findById(roleId);
      if (!role) {
        throw new HttpError(404, "Vai trò không tồn tại");
      }
      return role;
    } catch (err: any) {
      await logError({
        action: "getRoleById",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== UPDATE ROLE ===================
  async updateRole(roleId: string, data: Partial<IRole>, userId?: string) {
    try {
      const role = await this.roleRepo.findOne({ _id: roleId });
      if (!role) {
        await logAudit({
          userId,
          action: "updateRole",
          message: `Role "${roleId}" không tồn tại`,
          status: StatusLogEnum.Failure,
        });
        throw new HttpError(404, "Vai trò không tồn tại");
      }

      // Optional: kiểm tra trùng name
      if (data.name && data.name !== role.name) {
        const exists = await this.roleRepo.findOne({ name: data.name });
        if (exists) {
          await logAudit({
            userId,
            action: "updateRole",
            message: `Tên role "${data.name}" đã tồn tại`,
            status: StatusLogEnum.Failure,
          });
          throw new HttpError(400, "Tên vai trò đã tồn tại");
        }
      }

      const updated = await this.roleRepo.update(roleId, data);

      await logAudit({
        userId,
        action: "updateRole",
        message: `Cập nhật role "${roleId}" thành công`,
        status: StatusLogEnum.Success,
        metadata: { roleId },
      });

      return updated;
    } catch (err: any) {
      await logError({
        userId,
        action: "updateRole",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== UPDATE PERMISSION IDS ===================
  async updatePermissionIds(
    roleId: string,
    permissionIds: string[],
    userId?: string
  ) {
    try {
      const role = await this.roleRepo.findOne({ _id: roleId });
      if (!role) {
        await logAudit({
          userId,
          action: "updatePermissionIds",
          message: `Role "${roleId}" không tồn tại`,
          status: StatusLogEnum.Failure,
        });
        throw new HttpError(404, "Vai trò không tồn tại");
      }

      // Cập nhật permissionIds
      const updated = await this.roleRepo.update(roleId, { permissionIds });

      await logAudit({
        userId,
        action: "updatePermissionIds",
        message: `Cập nhật quyền cho role "${roleId}" thành công`,
        status: StatusLogEnum.Success,
        metadata: { roleId, permissionIds },
      });

      return updated;
    } catch (err: any) {
      await logError({
        userId,
        action: "updatePermissionIds",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }
}

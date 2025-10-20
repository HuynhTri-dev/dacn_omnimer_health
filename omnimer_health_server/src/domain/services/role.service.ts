import { RoleRepository } from "../repositories";
import { logError, logAudit } from "../../utils/LoggerUtil";
import { StatusLogEnum } from "../../common/constants/AppConstants";
import { IRole } from "../models";

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
}

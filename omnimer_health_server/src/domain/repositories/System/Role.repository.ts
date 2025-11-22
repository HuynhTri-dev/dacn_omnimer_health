import { Model, Types } from "mongoose";
import { IRole, IUser } from "../../models";
import { BaseRepository } from "../base.repository";

export class RoleRepository extends BaseRepository<IRole> {
  constructor(model: Model<IRole>) {
    super(model);
  }

  // Lấy danh sách vai trò (_id, name) loại bỏ các role có name chứa "admin"
  async findRolesWithoutAdminName(): Promise<Partial<IRole>[]> {
    try {
      const roles = await this.model
        .find({
          name: { $not: /admin/i }, // Regex không chứa "admin" (case-insensitive)
        })
        .select("_id name");

      return roles;
    } catch (e) {
      throw e;
    }
  }

  async loadRolePermission() {
    try {
      return await this.model.find().populate("permissionIds").lean();
    } catch (e) {
      throw e;
    }
  }

  /**
   * Tìm kiếm danh sách các vai trò dựa trên mảng IDs, chỉ trả về _id và name.
   * * @param roleIds Mảng các ID của vai trò (Types.ObjectId[]).
   * @returns Promise<RoleNameAndId[]> Mảng chứa _id và name của các vai trò tìm thấy.
   */
  async findRoleNamesAndIdsByRoleIds(
    roleIds: Types.ObjectId[]
  ): Promise<Partial<IRole[]>> {
    try {
      // Sử dụng cú pháp $in của MongoDB để tìm tất cả tài liệu có _id nằm trong mảng roleIds
      const roles = await this.model
        .find({
          _id: { $in: roleIds },
        })
        .select("_id name") // Chỉ chọn trường _id và name
        .exec();
      return roles;
    } catch (e) {
      throw e;
    }
  }
}

import { Model } from "mongoose";
import { IRole } from "../../models";
import { BaseRepository } from "../Base.repository";

export class RoleRepository extends BaseRepository<IRole> {
  constructor(model: Model<IRole>) {
    super(model);
  }

  async loadRolePermission() {
    try {
      return await this.model.find().populate("permissionIds").lean();
    } catch (e) {
      throw e;
    }
  }
}

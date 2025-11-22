import { Mode } from "fs";
import { IPermission, Permission } from "../../models";
import { BaseRepository } from "../base.repository";
import { Model } from "mongoose";

export class PermissionRepository extends BaseRepository<IPermission> {
  constructor(model: Model<IPermission>) {
    super(model);
  }
}

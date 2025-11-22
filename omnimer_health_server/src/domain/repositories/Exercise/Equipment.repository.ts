import { Model } from "mongoose";
import { IEquipment } from "../../models";
import { BaseRepository } from "../base.repository";

export class EquipmentRepository extends BaseRepository<IEquipment> {
  constructor(model: Model<IEquipment>) {
    super(model);
  }
}

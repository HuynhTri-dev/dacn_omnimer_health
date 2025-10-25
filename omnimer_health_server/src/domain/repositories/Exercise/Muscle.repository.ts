import { Model } from "mongoose";
import { IMuscle } from "../../models";
import { BaseRepository } from "../Base.repository";

export class MuscleRepository extends BaseRepository<IMuscle> {
  constructor(model: Model<IMuscle>) {
    super(model);
  }
}

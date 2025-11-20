import { Model, Types } from "mongoose";
import { IMuscle } from "../../models";
import { BaseRepository } from "../Base.repository";

export class MuscleRepository extends BaseRepository<IMuscle> {
  constructor(model: Model<IMuscle>) {
    super(model);
  }

  async getMuscleById(id: string) {
    try {
      if (!Types.ObjectId.isValid(id)) {
        throw new Error("Invalid muscle id");
      }

      const muscle = await this.model
        .findById(id)
        .populate({
          path: "bodyPartIds",
          select: "name", // chỉ lấy trường name
        })
        .lean()
        .exec();

      return muscle;
    } catch (e) {
      throw e;
    }
  }
}

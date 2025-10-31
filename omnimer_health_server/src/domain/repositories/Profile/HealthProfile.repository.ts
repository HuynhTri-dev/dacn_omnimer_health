import { Model, Types } from "mongoose";
import { IHealthProfile } from "../../models";
import { BaseRepository } from "../Base.repository";

export class HealthProfileRepository extends BaseRepository<IHealthProfile> {
  constructor(model: Model<IHealthProfile>) {
    super(model);
  }
  /**
   * 🔹 Lấy _id của hồ sơ sức khỏe có ngày kiểm tra sớm nhất của user
   * @param userId - ID của người dùng
   * @returns ObjectId của hồ sơ sớm nhất (hoặc null nếu không có)
   */
  async findEarliestIdByUserId(userId: string): Promise<Types.ObjectId | null> {
    const result = await this.model
      .findOne({ userId })
      .sort({ checkupDate: 1 }) // sớm nhất
      .select("_id") // chỉ lấy _id
      .lean() // bỏ bớt overhead của Document
      .exec();

    return result ? result._id : null;
  }
}

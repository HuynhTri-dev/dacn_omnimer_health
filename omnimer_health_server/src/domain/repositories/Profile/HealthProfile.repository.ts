import { Model, Types } from "mongoose";
import { IHealthProfile } from "../../models";
import { BaseRepository } from "../base.repository";
import { IRAGHealthProfile } from "../../entities/RecommendAI.entity";
import { GenderEnum } from "../../../common/constants/EnumConstants";

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
      .sort({ checkupDate: 1 })
      .select("_id")
      .lean()
      .exec();

    return result ? result._id : null;
  }

  /**
   * 🔹 Get latest health profile for RAG
   * @param userId - ID of user
   * @returns IRAGHealthProfile or null
   */
  async findProfileForRAG(userId: string): Promise<IRAGHealthProfile | null> {
    const profile = await this.model
      .findOne({ userId })
      .populate({ path: "userId", select: "gender" }) // chỉ lấy gender
      .sort({ checkupDate: -1 })
      .select(
        "userId age height weight bmi bodyFatPercentage activityLevel experienceLevel workoutFrequency restingHeartRate healthStatus maxWeightLifted"
      )
      .lean()
      .exec();

    if (!profile) return null;

    const populatedUser = profile.userId as any as {
      _id: string;
      gender: GenderEnum;
    };

    const result: IRAGHealthProfile = {
      gender: populatedUser.gender,
      age: profile.age,
      height: profile.height ?? null,
      weight: profile.weight ?? null,
      bmi: profile.bmi ?? null,
      bodyFatPercentage: profile.bodyFatPercentage ?? null,
      activityLevel: profile.activityLevel ?? null,
      experienceLevel: profile.experienceLevel ?? null,
      workoutFrequency: profile.workoutFrequency ?? null,
      restingHeartRate: profile.restingHeartRate ?? null,
      maxWeightLifted: profile.maxWeightLifted ?? null,
      healthStatus: profile.healthStatus ?? null,
    };

    return result;
  }

  /**
   * Retrieve the latest health profile of a user based on checkupDate.
   *
   * Features:
   * - Query HealthProfile by userId.
   * - Sort by `checkupDate` in descending order (newest first).
   * - Populate user information (gender, birthday).
   * - Return `null` if the user has no health profile.
   *
   * @param userId - ID of the user whose latest health profile is required
   * @returns The newest health profile document with populated user info
   */
  async getHealthProfileLatestByUserId(userId: string) {
    const profile = await this.model
      .findOne({ userId: new Types.ObjectId(userId) })
      .populate("userId", "gender birthday")
      .sort({ checkupDate: -1 })
      .lean();

    return profile || null;
  }

  /**
   * 🔹 Tìm hồ sơ sức khỏe theo ngày
   * @param userId - ID người dùng
   * @param date - Ngày cần tìm
   * @returns Hồ sơ sức khỏe hoặc null
   */
  async findByDate(userId: string, date: Date): Promise<IHealthProfile | null> {
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    return await this.model.findOne({
      userId,
      checkupDate: {
        $gte: startOfDay,
        $lte: endOfDay,
      },
    });
  }
  /**
   * 🔹 Lấy lịch sử cân nặng của user
   * @param userId - ID người dùng
   * @returns Danh sách { checkupDate, weight }
   */
  async getWeightHistory(
    userId: string
  ): Promise<{ checkupDate: Date; weight: number }[]> {
    const profiles = await this.model
      .find({
        userId: new Types.ObjectId(userId),
        weight: { $exists: true, $ne: null },
      })
      .sort({ checkupDate: 1 })
      .select("checkupDate weight")
      .lean()
      .exec();

    return profiles.map((p) => ({
      checkupDate: p.checkupDate,
      weight: p.weight as number,
    }));
  }
}

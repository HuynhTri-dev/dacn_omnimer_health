import { Model, Types } from "mongoose";
import { IHealthProfile } from "../../models";
import { BaseRepository } from "../base.repository";
import { IRAGHealthProfile } from "../../entities/RAG.entity";
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
        "userId age height weight whr bmi bmr bodyFatPercentage muscleMass maxWeightLifted activityLevel experienceLevel workoutFrequency restingHeartRate healthStatus"
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
      height: profile.height,
      weight: profile.weight,
      whr: profile.whr,
      bmi: profile.bmi,
      bmr: profile.bmr,
      bodyFatPercentage: profile.bodyFatPercentage,
      muscleMass: profile.muscleMass,
      maxWeightLifted: profile.maxWeightLifted,
      activityLevel: profile.activityLevel,
      experienceLevel: profile.experienceLevel,
      workoutFrequency: profile.workoutFrequency,
      restingHeartRate: profile.restingHeartRate,
      healthStatus: profile.healthStatus,
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
}

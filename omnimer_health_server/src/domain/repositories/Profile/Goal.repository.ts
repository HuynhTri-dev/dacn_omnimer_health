import { Model, Types } from "mongoose";
import { IGoal } from "../../models";
import { BaseRepository } from "../base.repository";
import { IRAGGoal } from "../../entities";
import { GoalTypeEnum } from "../../../common/constants/EnumConstants";

export class GoalRepository extends BaseRepository<IGoal> {
  constructor(model: Model<IGoal>) {
    super(model);
  }

  /**
   * Retrieves all active goals of a given user that have not yet expired.
   * A goal is considered active if the current date is less than or equal to its `endDate`.
   *
   * @param {string} userId - The ID of the user whose goals are being retrieved.
   * @returns {Promise<IRAGGoal[]>} A list of active goals including goal type and target metrics.
   *
   * @example
   * const activeGoals = await goalRepository.findActiveGoalsForRAG("66c8f1a...");
   *  [
   *    {
   *      goalType: "weight_loss",
   *      targetMetric: [
   *        { metricName: "Weight", value: 65, unit: "kg" }
   *      ]
   *    },
   *    {
   *      goalType: "endurance",
   *      targetMetric: [
   *        { metricName: "Running", value: 5, unit: "km" }
   *      ]
   *    }
   *  ]
   */
  async findActiveGoalsForRAG(userId: string): Promise<IRAGGoal[]> {
    const now = new Date();

    const goals = await this.model
      .find({
        userId,
        endDate: { $gte: now },
      })
      .select("goalType targetMetric")
      .lean()
      .exec();

    return goals.map((g) => ({
      goalType: g.goalType as GoalTypeEnum,
      targetMetric: g.targetMetric || [],
    }));
  }

  /**
   * 🔹 Lấy tất cả mục tiêu của user để thống kê
   */
  async getAllGoals(userId: string): Promise<IGoal[]> {
    return this.model
      .find({ userId: new Types.ObjectId(userId) })
      .lean()
      .exec() as unknown as IGoal[];
  }
}

import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { IGoal } from "../../models";
import { HttpError } from "../../../utils/HttpError";
import { GoalRepository } from "../../repositories";
import { PaginationQueryOptions } from "../../entities";

export class GoalService {
  private readonly goalRepo: GoalRepository;

  constructor(goalRepo: GoalRepository) {
    this.goalRepo = goalRepo;
  }

  // ======================================================
  // =============== CREATE NEW GOAL =======================
  // ======================================================
  /**
   * Create a new goal for a user.
   * - Saves the goal into the database.
   * - Logs the creation event in the audit log.
   *
   * @param userId - ID of the user performing the action
   * @param data - Partial goal data to create
   * @returns The created goal document
   * @throws HttpError if creation fails
   */
  async createGoal(userId: string, data: Partial<IGoal>) {
    try {
      const goal = await this.goalRepo.create(data);

      await logAudit({
        userId,
        action: "createGoal",
        message: `Tạo Goal "${data.userId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: goal._id.toString(),
      });

      return goal;
    } catch (err: any) {
      await logError({
        userId,
        action: "createGoal",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // ======================================================
  // =============== GET ALL GOALS =========================
  // ======================================================
  /**
   * Retrieve all goals in the system.
   * - Supports pagination and sorting via query options.
   *
   * @param option - Optional pagination and filtering options
   * @returns A paginated list of goals
   * @throws HttpError if retrieval fails
   */
  async getGoals(option?: PaginationQueryOptions) {
    try {
      return await this.goalRepo.findAll({}, option);
    } catch (err: any) {
      await logError({
        action: "getGoals",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // ======================================================
  // =============== GET GOAL BY ID ========================
  // ======================================================
  /**
   * Retrieve a single goal by its ID.
   * - Throws an error if the goal does not exist.
   *
   * @param goalId - The ID of the goal to retrieve
   * @returns The goal document
   * @throws HttpError(404) if the goal is not found
   */
  async getGoalById(goalId: string) {
    try {
      const goal = await this.goalRepo.findById(goalId);
      if (!goal) {
        throw new HttpError(404, "Goal không tồn tại");
      }
      return goal;
    } catch (err: any) {
      await logError({
        action: "getGoalById",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // ======================================================
  // =============== UPDATE GOAL ===========================
  // ======================================================
  /**
   * Update an existing goal by ID.
   * - Applies partial updates to goal data.
   * - Records the operation in the audit log.
   *
   * @param goalId - ID of the goal to update
   * @param data - Partial goal data to update
   * @param userId - Optional ID of the user performing the update
   * @returns The updated goal document
   * @throws HttpError if update fails
   */
  async updateGoal(goalId: string, data: Partial<IGoal>, userId?: string) {
    try {
      const updated = await this.goalRepo.update(goalId, data);

      await logAudit({
        userId,
        action: "updateGoal",
        message: `Cập nhật Goal "${goalId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: goalId,
      });

      return updated;
    } catch (err: any) {
      await logError({
        userId,
        action: "updateGoal",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // ======================================================
  // =============== DELETE GOAL ===========================
  // ======================================================
  /**
   * Delete a goal by its ID.
   * - Removes the goal from the database.
   * - Logs the result (success or failure).
   *
   * @param goalId - ID of the goal to delete
   * @param userId - Optional ID of the user performing the deletion
   * @returns The deleted goal document
   * @throws HttpError(404) if the goal does not exist
   */
  async deleteGoal(goalId: string, userId?: string) {
    try {
      const deleted = await this.goalRepo.delete(goalId);

      if (!deleted) {
        await logAudit({
          userId,
          action: "deleteGoal",
          message: `Goal "${goalId}" không tồn tại`,
          status: StatusLogEnum.Failure,
        });
        throw new HttpError(404, "Goal không tồn tại");
      }

      await logAudit({
        userId,
        action: "deleteGoal",
        message: `Xóa Goal "${goalId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: goalId,
      });

      return deleted;
    } catch (err: any) {
      await logError({
        userId,
        action: "deleteGoal",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // ======================================================
  // =============== GET ALL GOALS =========================
  // ======================================================
  /**
   * Retrieve all goals in the system.
   * - Supports pagination and sorting via query options.
   *
   * @param option - Optional pagination and filtering options
   * @returns A paginated list of goals
   * @throws HttpError if retrieval fails
   */
  async findActiveGoalsForRAG(userId: string) {
    try {
      return await this.goalRepo.findActiveGoalsForRAG(userId);
    } catch (err: any) {
      await logError({
        action: "getGoals",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }
}

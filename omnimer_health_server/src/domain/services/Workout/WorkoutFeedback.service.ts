import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { IWorkoutFeedback } from "../../models";
import { WorkoutFeedbackRepository } from "../../repositories";
import { HttpError } from "../../../utils/HttpError";
import { PaginationQueryOptions } from "../../entities";

export class WorkoutFeedbackService {
  private readonly workoutFeedbackRepo: WorkoutFeedbackRepository;

  constructor(workoutFeedbackRepo: WorkoutFeedbackRepository) {
    this.workoutFeedbackRepo = workoutFeedbackRepo;
  }

  // ======================================================
  // =============== CREATE WORKOUT FEEDBACK ===============
  // ======================================================
  /**
   * Create a new workout feedback for a user.
   * - Saves the workout feedback into the database.
   * - Logs the creation event in the audit log.
   *
   * @param userId - ID of the user creating the feedback
   * @param data - Partial workout feedback data
   * @returns The created workout feedback document
   * @throws HttpError if creation fails
   */
  async createWorkoutFeedback(userId: string, data: Partial<IWorkoutFeedback>) {
    try {
      const newFeedback = await this.workoutFeedbackRepo.create(data);

      await logAudit({
        userId,
        action: "createWorkoutFeedback",
        message: `Tạo WorkoutFeedback thành công`,
        status: StatusLogEnum.Success,
        targetId: newFeedback._id.toString(),
      });

      return newFeedback;
    } catch (err: any) {
      await logError({
        userId,
        action: "createWorkoutFeedback",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể tạo đánh giá buổi tập");
    }
  }

  // ======================================================
  // =============== UPDATE WORKOUT FEEDBACK ===============
  // ======================================================
  /**
   * Update an existing workout feedback.
   * - Applies partial updates to the feedback data.
   * - Logs the update event in the audit log.
   *
   * @param userId - ID of the user performing the update
   * @param workoutFeedbackId - ID of the workout feedback to update
   * @param updateData - Partial data to update
   * @returns The updated workout feedback document
   * @throws HttpError if update fails or feedback not found
   */
  async updateWorkoutFeedback(
    userId: string,
    workoutFeedbackId: string,
    updateData: Partial<IWorkoutFeedback>
  ) {
    try {
      const updated = await this.workoutFeedbackRepo.update(
        workoutFeedbackId,
        updateData
      );

      if (!updated) {
        throw new HttpError(404, "Đánh giá buổi tập không tồn tại");
      }

      await logAudit({
        userId,
        action: "updateWorkoutFeedback",
        message: `Cập nhật WorkoutFeedback thành công`,
        status: StatusLogEnum.Success,
        targetId: workoutFeedbackId,
      });

      return updated;
    } catch (err: any) {
      await logError({
        userId,
        action: "updateWorkoutFeedback",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // ======================================================
  // =============== DELETE WORKOUT FEEDBACK ===============
  // ======================================================
  /**
   * Delete a workout feedback by ID.
   * - Removes the feedback from the database.
   * - Logs success or failure.
   *
   * @param userId - ID of the user performing the deletion
   * @param workoutFeedbackId - ID of the feedback to delete
   * @returns The deleted workout feedback document
   * @throws HttpError(404) if the feedback does not exist
   */
  async deleteWorkoutFeedback(userId: string, workoutFeedbackId: string) {
    try {
      const deleted = await this.workoutFeedbackRepo.delete(workoutFeedbackId);

      if (!deleted) {
        await logAudit({
          userId,
          action: "deleteWorkoutFeedback",
          message: `WorkoutFeedback không tồn tại`,
          status: StatusLogEnum.Failure,
          targetId: workoutFeedbackId,
        });
        throw new HttpError(404, "Đánh giá buổi tập không tồn tại");
      }

      await logAudit({
        userId,
        action: "deleteWorkoutFeedback",
        message: `Xóa WorkoutFeedback thành công`,
        status: StatusLogEnum.Success,
        targetId: workoutFeedbackId,
      });

      return deleted;
    } catch (err: any) {
      await logError({
        userId,
        action: "deleteWorkoutFeedback",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // ======================================================
  // =============== GET WORKOUT FEEDBACK BY ID ============
  // ======================================================
  /**
   * Retrieve a single workout feedback by ID.
   * - Throws error if not found.
   *
   * @param workoutFeedbackId - ID of the workout feedback to retrieve
   * @returns The workout feedback document
   * @throws HttpError(404) if not found
   */
  async getWorkoutFeedbackById(userId: string, workoutFeedbackId: string) {
    try {
      const feedback = await this.workoutFeedbackRepo.findById(
        workoutFeedbackId
      );

      if (!feedback) {
        throw new HttpError(404, "Đánh giá buổi tập không tồn tại");
      }

      return feedback;
    } catch (err: any) {
      await logError({
        userId: userId,
        action: "getWorkoutFeedbackById",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // ======================================================
  // =============== GET ALL WORKOUT FEEDBACKS (ADMIN) =====
  // ======================================================
  /**
   * Retrieve all workout feedbacks in the system.
   * - For admin usage.
   * - Supports pagination and sorting.
   *
   * @param options - Optional pagination and filtering options
   * @returns Paginated list of workout feedbacks
   */
  async getAllWorkoutFeedbacks(
    userId: string,
    options?: PaginationQueryOptions
  ) {
    try {
      return await this.workoutFeedbackRepo.findAll({}, options);
    } catch (err: any) {
      await logError({
        userId: userId,
        action: "getAllWorkoutFeedbacks",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể lấy danh sách đánh giá buổi tập");
    }
  }

  // ======================================================
  // =============== GET WORKOUT FEEDBACKS BY WORKOUT =========
  // ======================================================
  /**
   * Retrieve all workout feedbacks created by a specific user.
   * - Supports pagination.
   *
   * @param userId - ID of the user whose feedbacks to retrieve
   * @param workoutId - ID of the workout
   * @param options - Optional pagination and filtering options
   * @returns Paginated list of user's workout feedbacks
   */
  async getWorkoutFeedbacksByWorkoutId(
    userId: string,
    workoutId: string,
    options?: PaginationQueryOptions
  ) {
    try {
      return await this.workoutFeedbackRepo.findAll(
        { workoutId: workoutId },
        options
      );
    } catch (err: any) {
      await logError({
        userId,
        action: "getWorkoutFeedbacksByUserId",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(
        500,
        "Không thể lấy danh sách đánh giá buổi tập của người dùng"
      );
    }
  }
}

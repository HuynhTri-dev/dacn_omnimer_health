import { Request, Response, NextFunction } from "express";
import { WorkoutFeedbackService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities/DecodePayload.entity";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class WorkoutFeedbackController {
  private readonly workoutFeedbackService: WorkoutFeedbackService;

  constructor(workoutFeedbackService: WorkoutFeedbackService) {
    this.workoutFeedbackService = workoutFeedbackService;
  }

  // ======================================================
  // =================== CREATE ============================
  // ======================================================
  /**
   * Create a new workout feedback.
   * - Requires authentication (userId).
   * - Returns the created feedback.
   */
  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const feedback = await this.workoutFeedbackService.createWorkoutFeedback(
        userId,
        req.body
      );
      return sendCreated(res, feedback, "Tạo đánh giá buổi tập thành công");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== UPDATE ============================
  // ======================================================
  /**
   * Update an existing workout feedback.
   * - Requires authentication (userId).
   * - Applies partial updates.
   */
  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const feedback = await this.workoutFeedbackService.updateWorkoutFeedback(
        userId,
        req.params.id,
        req.body
      );
      return sendSuccess(
        res,
        feedback,
        "Cập nhật đánh giá buổi tập thành công"
      );
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== DELETE ============================
  // ======================================================
  /**
   * Delete a workout feedback by ID.
   * - Requires authentication (userId).
   * - Permanently removes the feedback.
   */
  delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const deleted = await this.workoutFeedbackService.deleteWorkoutFeedback(
        userId,
        req.params.id
      );
      return sendSuccess(res, deleted, "Xóa đánh giá buổi tập thành công");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== GET BY ID =========================
  // ======================================================
  /**
   * Retrieve a workout feedback by ID.
   * - Returns detailed feedback information.
   */
  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);
      const feedback = await this.workoutFeedbackService.getWorkoutFeedbackById(
        userId,
        req.params.id
      );
      return sendSuccess(res, feedback, "Chi tiết đánh giá buổi tập");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== GET ALL (ADMIN) ==================
  // ======================================================
  /**
   * Retrieve all workout feedbacks.
   *! - For admin usage only.
   * - Supports pagination and sorting.
   */
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);
      const options = buildQueryOptions(req.params as any);

      const feedbacks =
        await this.workoutFeedbackService.getAllWorkoutFeedbacks(
          userId,
          options
        );
      return sendSuccess(res, feedbacks, "Danh sách tất cả đánh giá buổi tập");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== GET BY WORKOUT ====================
  // ======================================================
  /**
   * Retrieve all feedbacks for a specific workout.
   * - Requires authentication (userId).
   * - Supports pagination and sorting.
   */
  getByWorkoutId = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const options = buildQueryOptions(req.params as any);
      const feedbacks =
        await this.workoutFeedbackService.getWorkoutFeedbacksByWorkoutId(
          userId,
          req.params.workoutId,
          options
        );
      return sendSuccess(
        res,
        feedbacks,
        "Danh sách đánh giá buổi tập theo workout"
      );
    } catch (err) {
      next(err);
    }
  };
}

import { Request, Response, NextFunction } from "express";
import { WorkoutService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities/DecodePayload.entity";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class WorkoutController {
  private readonly workoutService: WorkoutService;

  constructor(workoutService: WorkoutService) {
    this.workoutService = workoutService;
  }

  // ======================================================
  // =================== CREATE WORKOUT ====================
  // ======================================================
  /**
   * Create a new workout.
   * - Requires authentication (userId).
   * - Returns created workout.
   */
  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);

      const workout = await this.workoutService.createWorkout(userId, req.body);
      return sendCreated(res, workout, "Tạo buổi tập thành công");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== UPDATE WORKOUT ====================
  // ======================================================
  /**
   * Update a workout by ID.
   * - Requires authentication (userId).
   * - Applies partial updates.
   */
  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);
      const { id } = req.params;

      const workout = await this.workoutService.updateWorkout(
        userId,
        id,
        req.body
      );
      return sendSuccess(res, workout, "Cập nhật buổi tập thành công");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== DELETE WORKOUT ====================
  // ======================================================
  /**
   * Delete a workout by ID.
   * - Requires authentication (userId).
   */
  delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);
      const { id } = req.params;

      const deleted = await this.workoutService.deleteWorkout(userId, id);
      return sendSuccess(res, deleted, "Xóa buổi tập thành công");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== GET ALL (ADMIN) ==================
  // ======================================================
  /**
   * Retrieve all workouts.
   *! - For admin usage.
   */
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);
      const options = buildQueryOptions(req.query as any);
      const workouts = await this.workoutService.getAllWorkouts(
        userId,
        options
      );
      return sendSuccess(res, workouts, "Danh sách tất cả buổi tập");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== GET BY USER =======================
  // ======================================================
  /**
   * Retrieve all workouts of the logged-in user.
   * - Requires authentication (userId).
   */
  getByUser = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);

      const options = buildQueryOptions(req.query as any);
      const workouts = await this.workoutService.getWorkoutsByUserId(
        userId,
        options
      );
      return sendSuccess(res, workouts, "Danh sách buổi tập của người dùng");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== GET BY ID =========================
  // ======================================================
  /**
   * Retrieve a single workout by ID.
   */
  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const workout = await this.workoutService.getWorkoutById(id);
      return sendSuccess(res, workout, "Chi tiết buổi tập");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =========== CREATE WORKOUT FROM TEMPLATE ==============
  // ======================================================
  /**
   * Create a new workout based on an existing template.
   * - Requires authentication (userId).
   */
  createFromTemplate = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);

      const { templateId } = req.params;
      const workout = await this.workoutService.createWorkoutByTemplateId(
        userId,
        templateId
      );
      return sendCreated(res, workout, "Tạo buổi tập từ template thành công");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== START WORKOUT =====================
  // ======================================================
  /**
   * Start a workout (set timeStart = now).
   */
  start = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const workout = await this.workoutService.startWorkout(id);
      return sendSuccess(res, workout, "Bắt đầu buổi tập");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== COMPLETE SET ======================
  // ======================================================
  /**
   * Mark a set as completed.
   */
  completeSet = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const { workoutDetailId, workoutSetId } = req.body;
      const result = await this.workoutService.completeSet(
        id,
        workoutDetailId,
        workoutSetId
      );
      return sendSuccess(res, result, "Hoàn thành set thành công");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== COMPLETE EXERCISE =================
  // ======================================================
  /**
   * Complete an exercise and update duration/device data.
   */
  completeExercise = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const { id } = req.params;
      const { workoutDetailId, durationMin, deviceData } = req.body;

      const result = await this.workoutService.completeExercise(
        id,
        workoutDetailId,
        durationMin,
        deviceData
      );
      return sendSuccess(res, result, "Hoàn thành bài tập thành công");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== FINISH WORKOUT ====================
  // ======================================================
  /**
   * Finish workout and calculate summary.
   */
  finish = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const result = await this.workoutService.finishWorkout(id);
      return sendSuccess(res, result, "Đã hoàn thành buổi tập");
    } catch (err) {
      next(err);
    }
  };
}

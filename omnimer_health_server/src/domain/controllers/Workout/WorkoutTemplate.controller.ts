import { Request, Response, NextFunction } from "express";
import { WorkoutTemplateService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities/DecodePayload.entity";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class WorkoutTemplateController {
  private readonly workoutTemplateService: WorkoutTemplateService;

  constructor(workoutTemplateService: WorkoutTemplateService) {
    this.workoutTemplateService = workoutTemplateService;
  }

  // ======================================================
  // =================== CREATE ============================
  // ======================================================
  /**
   * Create a new workout template.
   * - Requires authentication (userId).
   * - Returns created workout template.
   */
  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const template = await this.workoutTemplateService.createWorkoutTemplate(
        userId,
        req.body
      );
      return sendCreated(res, template, "Tạo mẫu tập luyện thành công");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== GET ALL (ADMIN) ==================
  // ======================================================
  /**
   * Retrieve all workout templates.
   *! - For admin usage.
   * - Supports pagination and sorting.
   */
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const options = buildQueryOptions(req.params as any);
      const templates =
        await this.workoutTemplateService.getAllWorkoutTemplates(options);
      return sendSuccess(res, templates, "Danh sách mẫu tập luyện");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== GET BY USER =======================
  // ======================================================
  /**
   * Retrieve workout templates created by the logged-in user.
   *! - Requires authentication (userId).
   * - Supports pagination and sorting.
   */
  getByUser = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const options = buildQueryOptions(req.params as any);
      const templates =
        await this.workoutTemplateService.getWorkoutTemplatesByUserId(
          userId,
          options
        );
      return sendSuccess(
        res,
        templates,
        "Danh sách mẫu tập luyện của người dùng"
      );
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== GET BY ID =========================
  // ======================================================
  /**
   * Retrieve a single workout template by ID.
   * - Returns detailed information.
   */
  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const template = await this.workoutTemplateService.getWorkoutTemplateById(
        req.params.id
      );
      return sendSuccess(res, template, "Chi tiết mẫu tập luyện");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== UPDATE ============================
  // ======================================================
  /**
   * Update an existing workout template by ID.
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

      const template = await this.workoutTemplateService.updateWorkoutTemplate(
        userId,
        req.params.id,
        req.body
      );
      return sendSuccess(res, template, "Cập nhật mẫu tập luyện thành công");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== DELETE ============================
  // ======================================================
  /**
   * Delete a workout template by ID.
   * - Requires authentication (userId).
   * - Removes the template permanently.
   */
  delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const template = await this.workoutTemplateService.deleteWorkoutTemplate(
        userId,
        req.params.id
      );
      return sendSuccess(res, template, "Xóa mẫu tập luyện thành công");
    } catch (err) {
      next(err);
    }
  };
}

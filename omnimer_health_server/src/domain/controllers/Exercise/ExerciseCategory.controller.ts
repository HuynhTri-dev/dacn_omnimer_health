import { Request, Response, NextFunction } from "express";
import { ExerciseCategoryService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities/DecodePayload";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class ExerciseCategoryController {
  private readonly exerciseCategoryService: ExerciseCategoryService;

  constructor(exerciseCategoryService: ExerciseCategoryService) {
    this.exerciseCategoryService = exerciseCategoryService;
  }

  // =================== CREATE ===================
  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const exerciseCategory =
        await this.exerciseCategoryService.createExerciseCategory(
          userId,
          req.body
        );
      return sendCreated(res, exerciseCategory, "Tạo loại bài tập thành công");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET ALL ===================
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const options = buildQueryOptions(req.params as any);
      const exerciseCategories =
        await this.exerciseCategoryService.getExerciseCategorys(options);
      return sendSuccess(res, exerciseCategories, "Danh sách loại bài tập");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET BY ID ===================
  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const exerciseCategory =
        await this.exerciseCategoryService.getExerciseCategoryById(
          req.params.id
        );
      return sendSuccess(res, exerciseCategory, "Chi tiết loại bài tập");
    } catch (err) {
      next(err);
    }
  };

  // =================== UPDATE ===================
  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const exerciseCategory =
        await this.exerciseCategoryService.updateExerciseCategory(
          req.params.id,
          req.body,
          userId
        );
      return sendSuccess(
        res,
        exerciseCategory,
        "Cập nhật loại bài tập thành công"
      );
    } catch (err) {
      next(err);
    }
  };

  // =================== DELETE ===================
  delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const exerciseCategory =
        await this.exerciseCategoryService.deleteExerciseCategory(
          req.params.id,
          userId
        );
      return sendSuccess(res, exerciseCategory, "Xóa loại bài tập thành công");
    } catch (err) {
      next(err);
    }
  };
}

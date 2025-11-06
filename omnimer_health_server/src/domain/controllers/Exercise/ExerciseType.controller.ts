import { Request, Response, NextFunction } from "express";
import { ExerciseTypeService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities/DecodePayload.entity";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class ExerciseTypeController {
  private readonly exerciseTypeService: ExerciseTypeService;

  constructor(exerciseTypeService: ExerciseTypeService) {
    this.exerciseTypeService = exerciseTypeService;
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

      const exerciseType = await this.exerciseTypeService.createExerciseType(
        userId,
        req.body
      );
      return sendCreated(res, exerciseType, "Tạo loại bài tập thành công");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET ALL ===================
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const options = buildQueryOptions(req.params as any);
      const exerciseTypes = await this.exerciseTypeService.getExerciseTypes(
        options
      );
      return sendSuccess(res, exerciseTypes, "Danh sách loại bài tập");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET BY ID ===================
  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const exerciseType = await this.exerciseTypeService.getExerciseTypeById(
        req.params.id
      );
      return sendSuccess(res, exerciseType, "Chi tiết loại bài tập");
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

      const exerciseType = await this.exerciseTypeService.updateExerciseType(
        req.params.id,
        req.body,
        userId
      );
      return sendSuccess(res, exerciseType, "Cập nhật loại bài tập thành công");
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

      const exerciseType = await this.exerciseTypeService.deleteExerciseType(
        req.params.id,
        userId
      );
      return sendSuccess(res, exerciseType, "Xóa loại bài tập thành công");
    } catch (err) {
      next(err);
    }
  };
}

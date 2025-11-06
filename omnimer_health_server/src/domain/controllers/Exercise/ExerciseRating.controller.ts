import { Request, Response, NextFunction } from "express";
import { ExerciseRatingService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities/DecodePayload.entity";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class ExerciseRatingController {
  private readonly exerciseRatingService: ExerciseRatingService;

  constructor(exerciseRatingService: ExerciseRatingService) {
    this.exerciseRatingService = exerciseRatingService;
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

      const exerciseRating =
        await this.exerciseRatingService.createExerciseRating(userId, req.body);
      return sendCreated(res, exerciseRating, "Tạo loại bài tập thành công");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET ALL ===================
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const options = buildQueryOptions(req.params as any);
      const exerciseRatings =
        await this.exerciseRatingService.getExerciseRatings(options);
      return sendSuccess(res, exerciseRatings, "Danh sách loại bài tập");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET BY ID ===================
  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const exerciseRating =
        await this.exerciseRatingService.getExerciseRatingById(req.params.id);
      return sendSuccess(res, exerciseRating, "Chi tiết loại bài tập");
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

      const exerciseRating =
        await this.exerciseRatingService.updateExerciseRating(
          req.params.id,
          req.body,
          userId
        );
      return sendSuccess(
        res,
        exerciseRating,
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

      const exerciseRating =
        await this.exerciseRatingService.deleteExerciseRating(
          req.params.id,
          userId
        );
      return sendSuccess(res, exerciseRating, "Xóa loại bài tập thành công");
    } catch (err) {
      next(err);
    }
  };
}

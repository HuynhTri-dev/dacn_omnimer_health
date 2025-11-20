import { Request, Response, NextFunction } from "express";
import { ExerciseService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class ExerciseController {
  private readonly exerciseService: ExerciseService;

  constructor(exerciseService: ExerciseService) {
    this.exerciseService = exerciseService;
  }

  // =================== CREATE ===================
  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);

      const files = req.files as
        | Record<string, Express.Multer.File[]>
        | undefined;
      const imageFiles = files?.image; // lấy tất cả ảnh
      const videoFile = files?.video?.[0];

      const exercise = await this.exerciseService.createExercise(
        userId,
        imageFiles,
        videoFile,
        req.body
      );

      return sendCreated(res, exercise, "Create exercise success");
    } catch (err) {
      next(err);
    }
  };

  // =================== UPDATE ===================
  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);

      const { id } = req.params;
      const files = req.files as
        | Record<string, Express.Multer.File[]>
        | undefined;
      const imageFiles = files?.image;
      const videoFile = files?.video?.[0];

      const updated = await this.exerciseService.updateExercise(
        userId,
        id,
        imageFiles,
        videoFile,
        req.body
      );

      return sendSuccess(res, updated, "Update exercise success");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET ALL ===================
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const options = buildQueryOptions(req.query as any);

      const list = await this.exerciseService.getAllExercises(options);

      return sendSuccess(res, list);
    } catch (err) {
      next(err);
    }
  };

  // =================== GET ALL ===================
  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const id = req.params.id;

      const exercise = await this.exerciseService.getExerciseById(id);

      return sendSuccess(res, exercise);
    } catch (err) {
      next(err);
    }
  };

  // =================== DELETE ===================
  delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);

      const { id } = req.params;
      await this.exerciseService.deleteExercise(userId, id);

      return sendSuccess(res, true, "Delete exercise success");
    } catch (err) {
      next(err);
    }
  };
}

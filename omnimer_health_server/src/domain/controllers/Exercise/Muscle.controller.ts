import { Request, Response, NextFunction } from "express";
import { MuscleService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class MuscleController {
  private readonly muscleService: MuscleService;

  constructor(muscleService: MuscleService) {
    this.muscleService = muscleService;
  }

  // =================== CREATE ===================
  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);

      const file = req.file;
      const muscle = await this.muscleService.createMuscle(
        userId,
        file,
        req.body
      );

      return sendCreated(res, muscle, "Tạo cơ thành công");
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

      const file = req.file;
      const { id } = req.params;

      const updated = await this.muscleService.updateMuscle(
        userId,
        id,
        file,
        req.body
      );

      return sendSuccess(res, updated, "Cập nhật cơ thành công");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET ALL ===================
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const options = buildQueryOptions(req.query as any);

      const list = await this.muscleService.getAllMuscles(options);

      return sendSuccess(res, list, "Lấy danh sách cơ thành công");
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
      await this.muscleService.deleteMuscle(userId, id);

      return sendSuccess(res, true, "Xoá cơ thành công");
    } catch (err) {
      next(err);
    }
  };
}

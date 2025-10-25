import { Request, Response, NextFunction } from "express";
import { BodyPartService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities/DecodePayload";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class BodyPartController {
  private readonly equipmentController: BodyPartService;

  constructor(equipmentController: BodyPartService) {
    this.equipmentController = equipmentController;
  }

  // =================== CREATE ===================
  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);

      const file = req.file;
      const bodyPart = await this.equipmentController.createBodyPart(
        userId,
        file,
        req.body
      );

      return sendCreated(res, bodyPart, "Tạo nhóm cơ thành công");
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

      const updated = await this.equipmentController.updateBodyPart(
        userId,
        id,
        file,
        req.body
      );

      return sendSuccess(res, updated, "Cập nhật nhóm cơ thành công");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET ALL ===================
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const options = buildQueryOptions(req.query as any);

      const list = await this.equipmentController.getAllBodyParts(options);

      return sendSuccess(res, list, "Lấy danh sách nhóm cơ thành công");
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
      await this.equipmentController.deleteBodyPart(userId, id);

      return sendSuccess(res, true, "Xoá nhóm cơ thành công");
    } catch (err) {
      next(err);
    }
  };
}

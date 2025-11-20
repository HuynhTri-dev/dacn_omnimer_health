import { Request, Response, NextFunction } from "express";
import { EquipmentService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities/DecodePayload.entity";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class EquipmentController {
  private readonly equipmentController: EquipmentService;

  constructor(equipmentController: EquipmentService) {
    this.equipmentController = equipmentController;
  }

  // =================== CREATE ===================
  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);

      const file = req.file;
      const bodyPart = await this.equipmentController.createEquipment(
        userId,
        file,
        req.body
      );

      return sendCreated(res, bodyPart, "Tạo thiết bị thành công");
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

      const updated = await this.equipmentController.updateEquipment(
        userId,
        id,
        file,
        req.body
      );

      return sendSuccess(res, updated, "Cập nhật thiết bị thành công");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET ALL ===================
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const options = buildQueryOptions(req.query as any);

      const list = await this.equipmentController.getAllEquipments(options);

      return sendSuccess(res, list, "Lấy danh sách thiết bị thành công");
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
      await this.equipmentController.deleteEquipment(userId, id);

      return sendSuccess(res, true, "Xoá thiết bị thành công");
    } catch (err) {
      next(err);
    }
  };
}

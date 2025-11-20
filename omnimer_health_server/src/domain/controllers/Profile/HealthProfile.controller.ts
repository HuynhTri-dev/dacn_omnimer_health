import { Request, Response, NextFunction } from "express";
import { HealthProfileService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
  sendForbidden,
  sendBadRequest,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class HealthProfileController {
  private readonly healthProfileService: HealthProfileService;

  constructor(healthProfileService: HealthProfileService) {
    this.healthProfileService = healthProfileService;
  }

  // =================== CREATE ===================
  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);

      const created = await this.healthProfileService.createHealthProfile(
        userId,
        req.body
      );

      return sendCreated(res, created, "Tạo hồ sơ sức khỏe thành công");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET ALL ===================
  //! GET ALL FOR ADMIN
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const options = buildQueryOptions(req.query as any);

      const list = await this.healthProfileService.getHealthProfiles(options);

      return sendSuccess(res, list, "Lấy danh sách hồ sơ sức khỏe thành công");
    } catch (err) {
      next(err);
    }
  };

  //! GET ALL FOR USER
  getAllByUserId = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const options = buildQueryOptions(req.query as any);
      const userId = req.params.userId;
      const actorId = (req.user as DecodePayload)?.id?.toString();
      if (!actorId && !userId) return sendUnauthorized(res);
      if (actorId !== userId) return sendForbidden(res);

      const list = await this.healthProfileService.getHealthProfilesByUserId(
        userId,
        options
      );

      return sendSuccess(
        res,
        list,
        "Lấy danh sách hồ sơ sức khỏe cá nhân thành công"
      );
    } catch (err) {
      next(err);
    }
  };

  // =================== GET BY ID ===================
  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;

      const item = await this.healthProfileService.getHealthProfileById(id);

      return sendSuccess(res, item, "Get health profile by ID success");
    } catch (err) {
      next(err);
    }
  };

  getHealthProfileLatest = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const userId = (req.user as DecodePayload)?.id?.toString();

      const profile =
        await this.healthProfileService.getHealthProfileLatestByUserId(userId);

      return sendSuccess(res, profile, "Get health profile by ID success");
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
      if (!id) return sendBadRequest(res);

      const updated = await this.healthProfileService.updateHealthProfile(
        id,
        req.body,
        userId
      );

      return sendSuccess(res, updated, "Cập nhật hồ sơ sức khỏe thành công");
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
      if (!id) return sendBadRequest(res);

      const deleted = await this.healthProfileService.deleteHealthProfile(
        id,
        userId
      );

      return sendSuccess(res, deleted, "Xóa hồ sơ sức khỏe thành công");
    } catch (err) {
      next(err);
    }
  };
}

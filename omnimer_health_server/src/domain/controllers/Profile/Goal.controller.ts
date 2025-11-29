import { Request, Response, NextFunction } from "express";
import { GoalService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
  sendForbidden,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities/DecodePayload.entity";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class GoalController {
  private readonly goalService: GoalService;

  constructor(goalService: GoalService) {
    this.goalService = goalService;
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

      const goal = await this.goalService.createGoal(userId, req.body);
      return sendCreated(res, goal, "Tạo mục tiêu thành công");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET ALL ===================
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const options = buildQueryOptions(req.params as any);
      const exerciseCategories = await this.goalService.getGoals(options);
      return sendSuccess(res, exerciseCategories, "Danh sách mục tiêu");
    } catch (err) {
      next(err);
    }
  };

  getAllByUserId = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const options = buildQueryOptions(req.query as any);
      const userId = req.params.userId;
      const actorId = (req.user as DecodePayload)?.id?.toString();
      if (!actorId && !userId) return sendUnauthorized(res);
      if (actorId !== userId) return sendForbidden(res);

      const list = await this.goalService.getGoalsByUserId(userId, options);

      return sendSuccess(res, list, "Get goals for user success");
    } catch (err) {
      next(err);
    }
  };

  // =================== GET BY ID ===================
  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const goal = await this.goalService.getGoalById(req.params.id);
      return sendSuccess(res, goal, "Chi tiết mục tiêu");
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

      const goal = await this.goalService.updateGoal(
        req.params.id,
        req.body,
        userId
      );
      return sendSuccess(res, goal, "Cập nhật mục tiêu thành công");
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

      const goal = await this.goalService.deleteGoal(req.params.id, userId);
      return sendSuccess(res, goal, "Xóa mục tiêu thành công");
    } catch (err) {
      next(err);
    }
  };
}

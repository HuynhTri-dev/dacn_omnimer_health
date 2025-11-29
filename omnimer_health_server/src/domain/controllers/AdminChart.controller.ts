import { Request, Response, NextFunction } from "express";
import { AdminChartService } from "../services/AdminChart.service";
import { sendSuccess } from "../../utils/ResponseHelper";

export class AdminChartController {
  private readonly adminChartService: AdminChartService;

  constructor(adminChartService: AdminChartService) {
    this.adminChartService = adminChartService;
  }

  getUserGrowth = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const period =
        (req.query.period as "daily" | "weekly" | "monthly") || "monthly";
      const data = await this.adminChartService.getUserGrowth(period);
      return sendSuccess(res, data, "Get user growth chart success");
    } catch (error) {
      next(error);
    }
  };

  getWorkoutActivity = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const period =
        (req.query.period as "daily" | "weekly" | "monthly") || "monthly";
      const data = await this.adminChartService.getWorkoutActivity(period);
      return sendSuccess(res, data, "Get workout activity chart success");
    } catch (error) {
      next(error);
    }
  };

  getPopularExercises = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const limit = Number(req.query.limit) || 5;
      const data = await this.adminChartService.getPopularExercises(limit);
      return sendSuccess(res, data, "Get popular exercises chart success");
    } catch (error) {
      next(error);
    }
  };

  getSystemSummary = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const data = await this.adminChartService.getSystemSummary();
      return sendSuccess(res, data, "Get system summary success");
    } catch (error) {
      next(error);
    }
  };
}

import { Request, Response, NextFunction } from "express";
import { ChartService } from "../services/Chart.service";
import { sendSuccess, sendUnauthorized } from "../../utils/ResponseHelper";
import { DecodePayload } from "../entities/DecodePayload.entity";

export class ChartController {
  private readonly chartService: ChartService;

  constructor(chartService: ChartService) {
    this.chartService = chartService;
  }

  getWeightProgress = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id;
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const data = await this.chartService.getWeightProgress(userId.toString());
      return sendSuccess(res, data, "Get weight progress success");
    } catch (error) {
      next(error);
    }
  };

  getWorkoutFrequency = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id;
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const data = await this.chartService.getWorkoutFrequency(
        userId.toString()
      );
      return sendSuccess(res, data, "Get workout frequency success");
    } catch (error) {
      next(error);
    }
  };

  getCaloriesBurned = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id;
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const data = await this.chartService.getCaloriesBurned(userId.toString());
      return sendSuccess(res, data, "Get calories burned success");
    } catch (error) {
      next(error);
    }
  };

  getMuscleDistribution = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id;
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const data = await this.chartService.getMuscleDistribution(
        userId.toString()
      );
      return sendSuccess(res, data, "Get muscle distribution success");
    } catch (error) {
      next(error);
    }
  };

  getGoalProgress = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id;
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const data = await this.chartService.getGoalProgress(userId.toString());
      return sendSuccess(res, data, "Get goal progress success");
    } catch (error) {
      next(error);
    }
  };
}

import { Router } from "express";
import { ChartController } from "../controllers/Chart.controller";
import { ChartService } from "../services/Chart.service";
import {
  GoalRepository,
  HealthProfileRepository,
  WorkoutRepository,
  WorkoutTemplateRepository,
} from "../repositories";
import { Goal, HealthProfile, Workout, WorkoutTemplate } from "../models";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";

const router = Router();

// Repositories
const healthProfileRepo = new HealthProfileRepository(HealthProfile);
const workoutRepo = new WorkoutRepository(Workout);
const workoutTemplateRepo = new WorkoutTemplateRepository(WorkoutTemplate);
const goalRepo = new GoalRepository(Goal);

// Service
const chartService = new ChartService(
  healthProfileRepo,
  workoutRepo,
  workoutTemplateRepo,
  goalRepo
);

// Controller
const chartController = new ChartController(chartService);

// Routes
router.get(
  "/weight-progress",
  verifyAccessToken,
  chartController.getWeightProgress
);

router.get(
  "/workout-frequency",
  verifyAccessToken,
  chartController.getWorkoutFrequency
);

router.get(
  "/calories-burned",
  verifyAccessToken,
  chartController.getCaloriesBurned
);

router.get(
  "/muscle-distribution",
  verifyAccessToken,
  chartController.getMuscleDistribution
);

router.get(
  "/goal-progress",
  verifyAccessToken,
  chartController.getGoalProgress
);

export default router;

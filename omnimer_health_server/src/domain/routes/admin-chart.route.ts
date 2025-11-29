import { Router } from "express";
import { AdminChartController } from "../controllers/AdminChart.controller";
import { AdminChartService } from "../services/AdminChart.service";
import {
  ExerciseRepository,
  UserRepository,
  WorkoutRepository,
} from "../repositories";
import { Exercise, User, Workout } from "../models";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";
import { ExerciseRating } from "../models/Exercise/ExerciseRating.model";

const router = Router();

// Repositories
const userRepo = new UserRepository(User);
const workoutRepo = new WorkoutRepository(Workout);
// ExerciseRepository needs Exercise model AND ExerciseRating model
const exerciseRepo = new ExerciseRepository(Exercise, ExerciseRating);

// Service
const adminChartService = new AdminChartService(
  userRepo,
  workoutRepo,
  exerciseRepo
);

// Controller
const adminChartController = new AdminChartController(adminChartService);

// Routes
router.get(
  "/user-growth",
  verifyAccessToken,
  adminChartController.getUserGrowth
);

router.get(
  "/workout-activity",
  verifyAccessToken,
  adminChartController.getWorkoutActivity
);

router.get(
  "/popular-exercises",
  verifyAccessToken,
  adminChartController.getPopularExercises
);

router.get(
  "/summary",
  verifyAccessToken,
  adminChartController.getSystemSummary
);

export default router;

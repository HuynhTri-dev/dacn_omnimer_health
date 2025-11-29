import { Router } from "express";
import { PermissionController, RAGController } from "../controllers";
import {
  AIService,
  ExerciseService,
  GoalService,
  HealthProfileService,
  WorkoutTemplateService,
} from "../services";
import {
  ExerciseRepository,
  GoalRepository,
  HealthProfileRepository,
  PermissionRepository,
  UserRepository,
  WorkoutTemplateRepository,
} from "../repositories";
import {
  Exercise,
  ExerciseRating,
  Goal,
  HealthProfile,
  User,
  WorkoutTemplate,
} from "../models";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";
// import { checkPermission } from "../../common/middlewares/checkPermission";
import { HttpError } from "../../utils/HttpError";
import dotenv from "dotenv";

dotenv.config();

const router = Router();
const apiUrl = process.env.AI_API;

// === Validate AI API endpoint ===
// if (!apiUrl) {
//   throw new HttpError(500, "Missing AI_API environment variable");
// }

// === Instantiate Services & Repositories ===
const healthProfileService = new HealthProfileService(
  new HealthProfileRepository(HealthProfile),
  new UserRepository(User)
);

const goalService = new GoalService(new GoalRepository(Goal));

const exerciseService = new ExerciseService(
  new ExerciseRepository(Exercise, ExerciseRating)
);

const aiService = new AIService(apiUrl || "http://localhost:8000");

const workoutTemplateService = new WorkoutTemplateService(
  new WorkoutTemplateRepository(WorkoutTemplate)
);

// === Instantiate Controller ===
const ragController = new RAGController(
  healthProfileService,
  goalService,
  exerciseService,
  aiService,
  workoutTemplateService
);

// === Define Routes ===
// Recommend personalized workout using AI
router.post(
  "/recommend",
  verifyAccessToken,
  // checkPermission(["user", "coach"]),
  ragController.recommendExerciseIntensity
);

export default router;

import { NextFunction, Request, Response } from "express";
import {
  AIService,
  ExerciseService,
  GoalService,
  HealthProfileService,
  WorkoutTemplateService,
} from "../../services";
import { DecodePayload, IRAGUserContext, UserRAGRequest } from "../../entities";
import {
  sendBadRequest,
  sendCreated,
  sendUnauthorized,
} from "../../../utils/ResponseHelper";

export class RAGController {
  private readonly healthProfileService: HealthProfileService;
  private readonly goalService: GoalService;
  private readonly exerciseService: ExerciseService;
  private readonly aiService: AIService;
  private readonly workoutTemplateService: WorkoutTemplateService;

  constructor(
    healthProfileService: HealthProfileService,
    goalService: GoalService,
    exerciseService: ExerciseService,
    aiService: AIService,
    workoutTemplateService: WorkoutTemplateService
  ) {
    this.healthProfileService = healthProfileService;
    this.goalService = goalService;
    this.exerciseService = exerciseService;
    this.aiService = aiService;
    this.workoutTemplateService = workoutTemplateService;
  }

  // ======================================================
  // =================== RAG GENERAL PIPELINE ====================
  // ======================================================

  recommendExerciseIntensity = async (
    req: Request,
    res: Response,
    next: NextFunction
  ) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) return sendUnauthorized(res);

      const userRequest = req.body as UserRAGRequest;

      const profile = await this.healthProfileService.findProfileForRAG(userId);
      const goals = await this.goalService.findActiveGoalsForRAG(userId);

      if (!profile) {
        return sendBadRequest(res, "You need to fill the health profile");
      }

      const exercises = await this.exerciseService.getAllExercisesForRAG(
        userId,
        userRequest,
        profile
      );

      const context: IRAGUserContext = {
        healthProfile: profile,
        goals: goals,
        exercises: exercises,
      };

      console.log(context);

      const aiResponse = await this.aiService.recommendExercises(context);

      console.log(aiResponse);

      const workoutTemplate =
        await this.workoutTemplateService.createWorkoutTemplateByAI(
          userId,
          userRequest,
          aiResponse
        );

      return sendCreated(res, workoutTemplate, "Tạo buổi tập thành công");
    } catch (err) {
      next(err);
    }
  };
}

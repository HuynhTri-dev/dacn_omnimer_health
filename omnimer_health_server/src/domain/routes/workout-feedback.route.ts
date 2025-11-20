import express from "express";

import { WorkoutFeedbackController } from "../controllers";
import { WorkoutFeedback } from "../models";
import { WorkoutFeedbackRepository } from "../repositories";
import { WorkoutFeedbackService } from "../services";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";

const service = new WorkoutFeedbackService(
  new WorkoutFeedbackRepository(WorkoutFeedback)
);

const controller = new WorkoutFeedbackController(service);

const router = express.Router();

router.post("/", verifyAccessToken, controller.create);
router.get("/", verifyAccessToken, controller.getAll);
router.get("/workout/:workoutId", verifyAccessToken, controller.getByWorkoutId);
router.get("/:id", verifyAccessToken, controller.getById);
router.put("/:id", verifyAccessToken, controller.update);
router.delete("/:id", verifyAccessToken, controller.delete);

export default router;

import express from "express";

import { WorkoutController } from "../controllers";
import { HealthProfile, Workout, WorkoutTemplate } from "../models";
import {
  HealthProfileRepository,
  WorkoutRepository,
  WorkoutTemplateRepository,
} from "../repositories";
import { WorkoutService } from "../services";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";

const service = new WorkoutService(
  new WorkoutRepository(Workout),
  new WorkoutTemplateRepository(WorkoutTemplate),
  new HealthProfileRepository(HealthProfile)
);

const controller = new WorkoutController(service);

const router = express.Router();

router.post("/", verifyAccessToken, controller.create);
router.get("/", verifyAccessToken, controller.getAll);
router.get("/user", verifyAccessToken, controller.getByUser);
router.get("/:id", verifyAccessToken, controller.getById);
router.put("/:id", verifyAccessToken, controller.update);
router.delete("/:id", verifyAccessToken, controller.delete);
router.post(
  "/template/:templateId",
  verifyAccessToken,
  controller.createFromTemplate
);
router.patch("/:id/start", verifyAccessToken, controller.start);
router.patch("/:id/complete-set", verifyAccessToken, controller.completeSet);
router.patch(
  "/:id/complete-exercise",
  verifyAccessToken,
  controller.completeExercise
);
router.patch("/:id/finish", verifyAccessToken, controller.finish);

export default router;

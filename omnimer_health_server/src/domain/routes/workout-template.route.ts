import express from "express";

import { WorkoutTemplateController } from "../controllers";
import { WorkoutTemplate } from "../models";
import { WorkoutTemplateRepository } from "../repositories";
import { WorkoutTemplateService } from "../services";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";

const service = new WorkoutTemplateService(
  new WorkoutTemplateRepository(WorkoutTemplate)
);

const controller = new WorkoutTemplateController(service);

const router = express.Router();

router.post("/", verifyAccessToken, controller.create);
router.get("/", verifyAccessToken, controller.getAll);
router.get("/user", verifyAccessToken, controller.getByUser);
router.get("/:id", verifyAccessToken, controller.getById);
router.put("/:id", verifyAccessToken, controller.update);
router.delete("/:id", verifyAccessToken, controller.delete);

export default router;

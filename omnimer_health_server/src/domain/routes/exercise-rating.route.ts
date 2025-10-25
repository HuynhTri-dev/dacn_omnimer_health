import { Router } from "express";
import { ExerciseRatingController } from "../controllers";
import { ExerciseRatingService } from "../services";
import { ExerciseRatingRepository } from "../repositories";
import { ExerciseRating } from "../models";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";

const exerciseRatingRepository = new ExerciseRatingRepository(ExerciseRating);
const exerciseRatingService = new ExerciseRatingService(
  exerciseRatingRepository
);
const exerciseRatingController = new ExerciseRatingController(
  exerciseRatingService
);
const router = Router();

router.get("/", exerciseRatingController.getAll);
router.post("/", verifyAccessToken, exerciseRatingController.create);
router.delete("/:id", verifyAccessToken, exerciseRatingController.delete);
router.get("/:id", exerciseRatingController.getById);
router.put("/:id", verifyAccessToken, exerciseRatingController.update);

export default router;

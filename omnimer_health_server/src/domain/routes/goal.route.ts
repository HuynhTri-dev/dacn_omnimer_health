import { Router } from "express";
import { GoalController } from "../controllers";
import { GoalService } from "../services";
import { GoalRepository } from "../repositories";
import { Goal } from "../models";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";

const goalRepository = new GoalRepository(Goal);
const goalService = new GoalService(goalRepository);
const goalController = new GoalController(goalService);
const router = Router();

router.get("/", goalController.getAll);
router.get("/user/:userId", verifyAccessToken, goalController.getAllByUserId);
router.post("/", verifyAccessToken, goalController.create);
router.delete("/:id", verifyAccessToken, goalController.delete);
router.get("/:id", goalController.getById);
router.put("/:id", verifyAccessToken, goalController.update);

export default router;

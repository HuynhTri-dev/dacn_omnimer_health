import { Router } from "express";
import { HealthProfileController } from "../controllers";
import { HealthProfileService } from "../services";
import { HealthProfileRepository, UserRepository } from "../repositories";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";
import { HealthProfile, User } from "../models";

const router = Router();

// Khởi tạo controller
const healthProfileService = new HealthProfileService(
  new HealthProfileRepository(HealthProfile),
  new UserRepository(User)
);
const controller = new HealthProfileController(healthProfileService);

// Routes
router.post("/", verifyAccessToken, controller.create);
// Get All Route
//! For Admin
router.get("/", controller.getAll);
//! For User
router.get("/user/:userId", verifyAccessToken, controller.getAllByUserId);

router.get("/:id", controller.getById);
router.put("/:id", verifyAccessToken, controller.update);
router.delete("/:id", verifyAccessToken, controller.delete);

export default router;

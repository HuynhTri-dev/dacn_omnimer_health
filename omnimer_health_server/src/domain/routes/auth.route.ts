import { Router } from "express";
import { AuthController } from "../controllers";
import { UserRepository } from "../repositories";
import { User } from "../models";
import { AuthService } from "../services";

const userRepository = new UserRepository(User);
const authService = new AuthService(userRepository);
const authController = new AuthController(authService);

const router = Router();

router.post("/register", authController.register);

router.post("/login", authController.login);

router.post("/new-access-token", authController.createNewAccessToken);

export default router;

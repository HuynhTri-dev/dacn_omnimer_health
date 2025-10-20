import { Router } from "express";
import { UserController } from "../controllers";
import { UserRepository } from "../repositories";
import { User } from "../models";
import { UserService } from "../services";

const userRepository = new UserRepository(User);
const userService = new UserService(userRepository);
const userController = new UserController(userService);

const router = Router();

router.post("/register", userController.register);

router.post("/login", userController.login);

export default router;

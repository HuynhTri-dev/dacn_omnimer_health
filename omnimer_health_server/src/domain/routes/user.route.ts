import express from "express";
import { UserController } from "../controllers";
import { UserService } from "../services";
import { UserRepository } from "../repositories";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";
import { uploadImage } from "../../common/middlewares/upload.middleware";
import { User } from "../models";

const router = express.Router();

const repo = new UserRepository(User);
const service = new UserService(repo);
const controller = new UserController(service);

router.put("/:id", verifyAccessToken, uploadImage("image"), controller.update);
router.get("/", controller.getAll);

export default router;

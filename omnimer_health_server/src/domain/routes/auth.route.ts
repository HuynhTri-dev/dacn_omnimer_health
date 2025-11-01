import { Router } from "express";
import { AuthController } from "../controllers";
import { UserRepository } from "../repositories";
import { User } from "../models";
import { AuthService } from "../services";
import { uploadImage } from "../../common/middlewares/upload.middleware";

const userRepository = new UserRepository(User);
const authService = new AuthService(userRepository);
const authController = new AuthController(authService);

const router = Router();
/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     tags: [Auth]
 *     summary: Đăng ký tài khoản mới
 *     description: Tạo tài khoản mới, có thể upload ảnh đại diện
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               fullName:
 *                 type: string
 *                 example: "Huynh Minh Tri"
 *               email:
 *                 type: string
 *                 example: "example@gmail.com"
 *               password:
 *                 type: string
 *                 example: "12345678"
 *               image:
 *                 type: string
 *                 format: binary
 *     responses:
 *       201:
 *         description: Đăng ký thành công
 */
router.post("/register", uploadImage("image"), authController.register);

router.post("/login", authController.login);

router.post("/new-access-token", authController.createNewAccessToken);

export default router;

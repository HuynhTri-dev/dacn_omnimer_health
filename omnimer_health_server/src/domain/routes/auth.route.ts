import { Router } from "express";
import { AuthController } from "../controllers";
import { RoleRepository, UserRepository } from "../repositories";
import { Role, User } from "../models";
import { AuthService } from "../services";
import { uploadImage } from "../../common/middlewares/upload.middleware";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";

const userRepository = new UserRepository(User);
const authService = new AuthService(userRepository, new RoleRepository(Role));
const authController = new AuthController(authService);

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Auth
 *   description: Authentication and authorization endpoints
 */

/**
 * @swagger
 * components:
 *   securitySchemes:
 *     bearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 *   schemas:
 *     User:
 *       type: object
 *       properties:
 *         _id:
 *           type: string
 *           example: "507f1f77bcf86cd799439011"
 *         fullName:
 *           type: string
 *           example: "Huynh Minh Tri"
 *         email:
 *           type: string
 *           example: "example@gmail.com"
 *         image:
 *           type: string
 *           example: "https://example.com/avatar.jpg"
 *         roleId:
 *           type: string
 *           example: "507f1f77bcf86cd799439012"
 *         createdAt:
 *           type: string
 *           format: date-time
 *         updatedAt:
 *           type: string
 *           format: date-time
 */

/**
 * @swagger
 * /register:
 *   post:
 *     tags: [Auth]
 *     summary: Đăng ký tài khoản mới
 *     description: Tạo tài khoản người dùng mới với thông tin cơ bản và có thể upload ảnh đại diện
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - fullName
 *               - email
 *               - password
 *             properties:
 *               fullName:
 *                 type: string
 *                 description: Họ và tên đầy đủ
 *                 example: "Huynh Minh Tri"
 *               email:
 *                 type: string
 *                 format: email
 *                 description: Địa chỉ email (phải duy nhất)
 *                 example: "example@gmail.com"
 *               password:
 *                 type: string
 *                 format: password
 *                 description: Mật khẩu (tối thiểu 8 ký tự)
 *                 example: "12345678"
 *               image:
 *                 type: string
 *                 format: binary
 *                 description: Ảnh đại diện (tùy chọn)
 *     responses:
 *       201:
 *         description: Đăng ký thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "User registered successfully"
 *                 data:
 *                   $ref: '#/components/schemas/User'
 *                 tokens:
 *                   type: object
 *                   properties:
 *                     accessToken:
 *                       type: string
 *                     refreshToken:
 *                       type: string
 *       400:
 *         description: Dữ liệu không hợp lệ
 *       409:
 *         description: Email đã tồn tại
 */
router.post("/register", uploadImage("image"), authController.register);

/**
 * @swagger
 * /login:
 *   post:
 *     tags: [Auth]
 *     summary: Đăng nhập
 *     description: Đăng nhập vào hệ thống bằng email và mật khẩu
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: "example@gmail.com"
 *               password:
 *                 type: string
 *                 format: password
 *                 example: "12345678"
 *     responses:
 *       200:
 *         description: Đăng nhập thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Login successful"
 *                 data:
 *                   $ref: '#/components/schemas/User'
 *                 tokens:
 *                   type: object
 *                   properties:
 *                     accessToken:
 *                       type: string
 *                       description: JWT access token (expires in 1 hour)
 *                     refreshToken:
 *                       type: string
 *                       description: JWT refresh token (expires in 7 days)
 *       401:
 *         description: Email hoặc mật khẩu không đúng
 *       404:
 *         description: Người dùng không tồn tại
 */
router.post("/login", authController.login);

/**
 * @swagger
 * /new-access-token:
 *   post:
 *     tags: [Auth]
 *     summary: Làm mới access token
 *     description: Tạo access token mới từ refresh token
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - refreshToken
 *             properties:
 *               refreshToken:
 *                 type: string
 *                 description: Refresh token nhận được khi đăng nhập
 *                 example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *     responses:
 *       200:
 *         description: Tạo access token mới thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "New access token created"
 *                 accessToken:
 *                   type: string
 *                   description: JWT access token mới
 *       401:
 *         description: Refresh token không hợp lệ hoặc đã hết hạn
 */
router.post("/new-access-token", authController.createNewAccessToken);

/**
 * @swagger
 * /:
 *   get:
 *     tags: [Auth]
 *     summary: Lấy thông tin người dùng hiện tại
 *     description: Lấy thông tin chi tiết của người dùng đang đăng nhập
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lấy thông tin thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "User retrieved successfully"
 *                 data:
 *                   $ref: '#/components/schemas/User'
 *       401:
 *         description: Chưa đăng nhập hoặc token không hợp lệ
 */
router.get("/", verifyAccessToken, authController.getAuth);

export default router;

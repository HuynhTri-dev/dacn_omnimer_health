import { Router } from "express";
import { VerificationController } from "../controllers/Profile/Verification.controller";
import { VerificationService } from "../services/Profile/Verification.service";
import { UserRepository } from "../repositories";
import { User } from "../models";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";

// Initialize dependencies
const userRepository = new UserRepository(User);
const verificationService = new VerificationService(userRepository);
const verificationController = new VerificationController(verificationService);

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Verification
 *   description: Email and phone verification endpoints
 */

/**
 * @swagger
 * /verification/status:
 *   get:
 *     tags: [Verification]
 *     summary: Lấy trạng thái xác thực của user
 *     description: Trả về trạng thái xác thực email và phone của user hiện tại
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Lấy trạng thái thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Lấy trạng thái xác thực thành công"
 *                 data:
 *                   type: object
 *                   properties:
 *                     isEmailVerified:
 *                       type: boolean
 *                       example: false
 *                     isPhoneVerified:
 *                       type: boolean
 *                       example: false
 *                     email:
 *                       type: string
 *                       example: "user@example.com"
 *                     phoneNumber:
 *                       type: string
 *                       nullable: true
 *                       example: null
 *       401:
 *         description: Chưa đăng nhập
 */
router.get("/status", verifyAccessToken, verificationController.getVerificationStatus);

/**
 * @swagger
 * /verification/send-verification-email:
 *   post:
 *     tags: [Verification]
 *     summary: Gửi email xác thực
 *     description: Gửi email xác thực đến địa chỉ email của user hiện tại
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Email đã được gửi thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Email xác thực đã được gửi"
 *                 data:
 *                   type: object
 *                   properties:
 *                     message:
 *                       type: string
 *                       example: "Email xác thực đã được gửi. Vui lòng kiểm tra hộp thư của bạn."
 *       400:
 *         description: Email đã được xác thực trước đó
 *       401:
 *         description: Chưa đăng nhập
 */
router.post(
  "/send-verification-email",
  verifyAccessToken,
  verificationController.sendVerificationEmail
);

/**
 * @swagger
 * /verification/resend-verification-email:
 *   post:
 *     tags: [Verification]
 *     summary: Gửi lại email xác thực
 *     description: Gửi lại email xác thực (có rate limiting 1 phút)
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Email đã được gửi lại thành công
 *       400:
 *         description: Email đã được xác thực trước đó
 *       429:
 *         description: Rate limit - vui lòng đợi 1 phút
 *       401:
 *         description: Chưa đăng nhập
 */
router.post(
  "/resend-verification-email",
  verifyAccessToken,
  verificationController.resendVerificationEmail
);

/**
 * @swagger
 * /verification/verify-email:
 *   get:
 *     tags: [Verification]
 *     summary: Xác thực email bằng token
 *     description: |
 *       Endpoint này được gọi khi user click vào link trong email.
 *       Trả về trang HTML thông báo kết quả.
 *     parameters:
 *       - in: query
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *         description: Token xác thực từ email
 *     responses:
 *       200:
 *         description: Xác thực thành công (trả về HTML page)
 *         content:
 *           text/html:
 *             schema:
 *               type: string
 *       400:
 *         description: Token không hợp lệ hoặc hết hạn (trả về HTML page)
 */
router.get("/verify-email", verificationController.verifyEmail);

/**
 * @swagger
 * /verification/request-change-email:
 *   post:
 *     tags: [Verification]
 *     summary: Yêu cầu đổi email
 *     description: Gửi yêu cầu đổi email mới
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - newEmail
 *             properties:
 *               newEmail:
 *                 type: string
 *                 format: email
 *                 example: "newemail@example.com"
 *     responses:
 *       200:
 *         description: Yêu cầu đổi email đã được gửi
 *       400:
 *         description: Email không hợp lệ hoặc trùng với email hiện tại
 *       409:
 *         description: Email đã được sử dụng bởi tài khoản khác
 *       401:
 *         description: Chưa đăng nhập
 */
router.post(
  "/request-change-email",
  verifyAccessToken,
  verificationController.requestChangeEmail
);

/**
 * @swagger
 * /verification/confirm-change-email:
 *   get:
 *     tags: [Verification]
 *     summary: Xác nhận đổi email
 *     description: |
 *       Endpoint này được gọi khi user click vào link xác nhận đổi email.
 *       Trả về trang HTML thông báo kết quả.
 *     parameters:
 *       - in: query
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *         description: Token xác nhận đổi email
 *     responses:
 *       200:
 *         description: Đổi email thành công (trả về HTML page)
 *       400:
 *         description: Token không hợp lệ (trả về HTML page)
 */
router.get("/confirm-change-email", verificationController.confirmChangeEmail);

export default router;


import { Router } from "express";
import { ForgotPasswordController } from "../controllers/Profile/ForgotPassword.controller";
import { ForgotPasswordService } from "../services/Profile/ForgotPassword.service";
import { UserRepository } from "../repositories";
import { User } from "../models";

const userRepository = new UserRepository(User);
const forgotPasswordService = new ForgotPasswordService(userRepository);
const forgotPasswordController = new ForgotPasswordController(
  forgotPasswordService
);

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Forgot Password
 *   description: Password recovery endpoints
 */

/**
 * @swagger
 * /forgot-password/request:
 *   post:
 *     tags: [Forgot Password]
 *     summary: Yêu cầu khôi phục mật khẩu
 *     description: |
 *       Gửi yêu cầu khôi phục mật khẩu đến email.
 *       - Nếu email chưa verified → trả về lỗi 403 với requireEmailVerification = true
 *       - Nếu email đã verified → gửi mã 6 số đến email
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 description: Email đã đăng ký
 *                 example: "user@example.com"
 *     responses:
 *       200:
 *         description: Yêu cầu thành công (mã đã được gửi hoặc email không tồn tại)
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
 *                   example: "Mã khôi phục đã được gửi đến email của bạn."
 *       403:
 *         description: Email chưa được xác thực
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: false
 *                 requireEmailVerification:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Email chưa được xác thực. Vui lòng xác thực email trước khi khôi phục mật khẩu."
 *       429:
 *         description: Rate limit - vui lòng đợi trước khi yêu cầu lại
 */
router.post("/request", forgotPasswordController.requestPasswordReset);

/**
 * @swagger
 * /forgot-password/verify-code:
 *   post:
 *     tags: [Forgot Password]
 *     summary: Xác thực mã khôi phục
 *     description: |
 *       Xác thực mã 6 số được gửi đến email.
 *       - Mã hết hạn sau 10 phút
 *       - Nếu thành công, trả về resetToken để sử dụng cho bước đặt lại mật khẩu
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - code
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 description: Email đã đăng ký
 *                 example: "user@example.com"
 *               code:
 *                 type: string
 *                 pattern: '^\d{6}$'
 *                 description: Mã 6 số từ email
 *                 example: "123456"
 *     responses:
 *       200:
 *         description: Mã xác thực hợp lệ
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
 *                   example: "Mã xác thực hợp lệ."
 *                 data:
 *                   type: object
 *                   properties:
 *                     resetToken:
 *                       type: string
 *                       description: Token để đặt lại mật khẩu (hết hạn sau 15 phút)
 *                       example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *       400:
 *         description: Mã không đúng hoặc đã hết hạn
 */
router.post("/verify-code", forgotPasswordController.verifyResetCode);

/**
 * @swagger
 * /forgot-password/reset:
 *   post:
 *     tags: [Forgot Password]
 *     summary: Đặt lại mật khẩu
 *     description: |
 *       Đặt lại mật khẩu bằng resetToken từ bước xác thực mã.
 *       - Token hết hạn sau 15 phút
 *       - Mật khẩu mới phải có ít nhất 6 ký tự
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - resetToken
 *               - newPassword
 *             properties:
 *               resetToken:
 *                 type: string
 *                 description: Token từ bước verify-code
 *                 example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *               newPassword:
 *                 type: string
 *                 format: password
 *                 minLength: 6
 *                 description: Mật khẩu mới (tối thiểu 6 ký tự)
 *                 example: "newPassword123"
 *     responses:
 *       200:
 *         description: Đặt lại mật khẩu thành công
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
 *                   example: "Mật khẩu đã được đặt lại thành công."
 *       400:
 *         description: Token không hợp lệ hoặc đã hết hạn
 *       404:
 *         description: Người dùng không tồn tại
 */
router.post("/reset", forgotPasswordController.resetPassword);

/**
 * @swagger
 * /forgot-password/resend-code:
 *   post:
 *     tags: [Forgot Password]
 *     summary: Gửi lại mã khôi phục
 *     description: |
 *       Gửi lại mã 6 số đến email.
 *       - Có rate limiting (1 phút giữa các lần gửi)
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 description: Email đã đăng ký
 *                 example: "user@example.com"
 *     responses:
 *       200:
 *         description: Mã mới đã được gửi
 *       403:
 *         description: Email chưa được xác thực
 *       429:
 *         description: Rate limit - vui lòng đợi trước khi yêu cầu lại
 */
router.post("/resend-code", forgotPasswordController.resendResetCode);

export default router;


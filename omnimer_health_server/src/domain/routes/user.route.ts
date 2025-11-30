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

/**
 * @swagger
 * tags:
 *   name: User
 *   description: User management endpoints
 */

/**
 * @swagger
 * /data-sharing:
 *   patch:
 *     tags: [User]
 *     summary: Chuyển đổi trạng thái chia sẻ dữ liệu
 *     description: Chuyển đổi trạng thái isDataSharingAccepted. Nếu bật, đồng bộ dữ liệu sang GraphDB. Nếu tắt, xóa dữ liệu khỏi GraphDB.
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Cập nhật trạng thái chia sẻ dữ liệu thành công"
 *                 data:
 *                   $ref: '#/components/schemas/User'
 *       401:
 *         description: Chưa đăng nhập
 *       404:
 *         description: Người dùng không tồn tại
 */
router.patch("/data-sharing", verifyAccessToken, controller.toggleDataSharing);

/**
 * @swagger
 * /{id}:
 *   put:
 *     tags: [User]
 *     summary: Cập nhật thông tin người dùng
 *     description: Cập nhật thông tin người dùng bao gồm cả ảnh đại diện
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ID của người dùng
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               fullName:
 *                 type: string
 *                 description: Họ và tên đầy đủ
 *                 example: "Nguyen Van A"
 *               email:
 *                 type: string
 *                 format: email
 *                 description: Địa chỉ email
 *                 example: "nguyenvana@gmail.com"
 *               image:
 *                 type: string
 *                 format: binary
 *                 description: Ảnh đại diện mới
 *     responses:
 *       200:
 *         description: Cập nhật thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "User updated successfully"
 *                 data:
 *                   $ref: '#/components/schemas/User'
 *       401:
 *         description: Chưa đăng nhập
 *       404:
 *         description: Người dùng không tồn tại
 */
router.put("/:id", verifyAccessToken, uploadImage("image"), controller.update);

/**
 * @swagger
 * /:
 *   get:
 *     tags: [User]
 *     summary: Lấy danh sách tất cả người dùng
 *     description: Lấy danh sách tất cả người dùng trong hệ thống (dành cho admin)
 *     responses:
 *       200:
 *         description: Lấy danh sách thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Users retrieved successfully"
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/User'
 */
router.get("/", verifyAccessToken, controller.getAll);

export default router;

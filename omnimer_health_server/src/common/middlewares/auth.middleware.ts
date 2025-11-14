import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import { User } from "../../domain/models";
import { DecodePayload } from "../../domain/entities/DecodePayload.entity";
import { sendError } from "../../utils/ResponseHelper";
import { JwtUtils } from "../../utils/JwtUtils";

/**
 * Middleware: verifyAccessToken
 * ---------------------------------
 * - Xác thực access token hợp lệ.
 * - Giải mã token và gán payload (DecodePayload) vào req.user.
 * - Không truy vấn cơ sở dữ liệu → hiệu năng cao.
 *
 * Dùng khi bạn chỉ cần xác thực nhanh (ví dụ: log activity, audit, v.v.)
 */
export const verifyAccessToken = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader?.startsWith("Bearer ")) {
      return sendError(res, "Chưa đăng nhập", 401);
    }

    const token = authHeader.split(" ")[1];
    const payload = JwtUtils.verifyAccessToken(token) as DecodePayload;

    // Gán payload (DecodePayload) vào req.user
    req.user = payload;
    next();
  } catch (err) {
    sendError(res, "Token không hợp lệ", 401, err);
  }
};

/**
 * Middleware: authenticateUser
 * ---------------------------------
 * - Xác thực access token hợp lệ.
 * - Giải mã token và tìm user tương ứng trong DB.
 * - Gán đối tượng IUser vào req.user.
 *
 * Dùng khi bạn cần thông tin user đầy đủ (vai trò, email, trạng thái,...)
 * để truy cập dữ liệu hoặc kiểm tra quyền hạn.
 */
export const authenticateUser = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader?.startsWith("Bearer ")) {
      return sendError(res, "Chưa đăng nhập", 401);
    }

    const token = authHeader.split(" ")[1];
    const payload = jwt.verify(
      token,
      process.env.ACCESS_TOKEN_SECRET!
    ) as DecodePayload;

    const user = await User.findById(payload.id);
    if (!user) {
      return sendError(res, "Người dùng không tồn tại", 401);
    }

    // Gán IUser vào req.user
    req.user = user;
    next();
  } catch (err) {
    sendError(res, "Token không hợp lệ", 401, err);
  }
};

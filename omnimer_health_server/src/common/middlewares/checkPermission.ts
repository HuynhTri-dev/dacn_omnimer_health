import { Request, Response, NextFunction } from "express";
import { connectRedis } from "../configs/redisConnect";
import { HttpError } from "../../utils/HttpError";

/**
 * Middleware: checkPermission
 * ------------------------------------------------
 * Kiểm tra xem user hiện tại có quyền trong danh sách `permissionKeys` hay không.
 * - Nếu user có role chứa quyền "all" → tự động pass (admin).
 * - Hỗ trợ `permissionKeys` dạng string | string[]
 * - Dữ liệu permission lấy từ Redis cache (key: role:<roleId>)
 */
export const checkPermission = (permissionKeys: string | string[]) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const roleIds = req.user?.roleIds;

      if (!roleIds || roleIds.length === 0) {
        return next(new HttpError(403, "User has no assigned roles"));
      }

      const redisClient = await connectRedis();
      let hasPermission = false;

      // Chuẩn hóa permissionKeys thành mảng
      const requiredPermissions = Array.isArray(permissionKeys)
        ? permissionKeys
        : [permissionKeys];

      for (const roleId of roleIds) {
        const cacheKey = `role:${roleId}`;
        const cachedPermissions = await redisClient.get(cacheKey);
        if (!cachedPermissions) continue;

        const permissions: string[] = JSON.parse(cachedPermissions);

        // Nếu role có quyền "all" => bypass toàn bộ
        if (permissions.includes("all")) {
          hasPermission = true;
          break;
        }

        // Nếu role có bất kỳ quyền nào được yêu cầu
        if (requiredPermissions.some((p) => permissions.includes(p))) {
          hasPermission = true;
          break;
        }
      }

      if (!hasPermission) {
        return next(
          new HttpError(403, "Bạn không có quyền", { code: "No-Permission" })
        );
      }

      next();
    } catch (err: any) {
      next(new HttpError(500, err.message || "Internal server error"));
    }
  };
};

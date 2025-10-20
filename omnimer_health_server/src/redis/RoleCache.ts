import { Role } from "../domain/models";
import { RedisClientType } from "redis";

/**
 * Tải toàn bộ Role-Permission từ MongoDB vào Redis cache.
 * --------------------------------------------------------
 * Mỗi role được lưu với key: role:<roleId>
 * Value là JSON mảng các permission key.
 *
 * Gọi hàm này khi:
 * - Server khởi động
 * - Role hoặc Permission thay đổi
 */
export const loadRolePermissionsToCache = async (
  redisClient: RedisClientType
) => {
  const roles = await Role.find().populate("permissionIds").lean();

  for (const role of roles) {
    const permissionKeys = role.permissionIds.map((p: any) => p.key);
    await redisClient.set(`role:${role._id}`, JSON.stringify(permissionKeys));
  }

  console.log("Role-Permission cached in Redis");
};

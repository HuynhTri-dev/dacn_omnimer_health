import { Role } from "../domain/models";
import { Types } from "mongoose";

export async function seedRoles(allPermission: any, permissions: any[]) {
  await Role.deleteMany({});

  // Superadmin
  const superadmin = await Role.create({
    name: "superadmin",
    description: "Quản trị toàn hệ thống",
    permissionIds: [allPermission._id, ...permissions.map((p) => p._id)],
  });

  // Coach
  const coachPermissions = permissions.filter((p) =>
    ["workout", "exercise", "profile"].includes(p.module)
  );
  const coach = await Role.create({
    name: "coach",
    description: "Huấn luyện viên, có quyền quản lý người tập và nội dung",
    permissionIds: coachPermissions.map((p) => p._id),
  });

  // User
  const userPermissions = permissions.filter((p) =>
    ["profile.get", "profile.put", "workout.get"].includes(p.key)
  );
  const user = await Role.create({
    name: "user",
    description: "Người dùng thông thường",
    permissionIds: userPermissions.map((p) => p._id),
  });

  console.log("✅ Roles created successfully");
  return { superadmin, coach, user };
}

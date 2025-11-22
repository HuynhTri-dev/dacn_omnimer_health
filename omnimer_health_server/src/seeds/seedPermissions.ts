import { Permission } from "../domain/models";

export async function seedPermissions() {
  // Xóa cũ
  await Permission.deleteMany({});

  const modules = ["workout", "system", "profile", "exercise", "devices"];
  const actions = ["all", "getAll", "get", "post", "put", "patch", "delete"];
  const permissions: any[] = [];

  // Permission all.all cho superadmin
  const allPermission = await Permission.create({
    key: "all.all",
    description: "Toàn quyền hệ thống",
    module: "all",
  });

  for (const moduleName of modules) {
    for (const action of actions) {
      const p = await Permission.create({
        key: `${moduleName}.${action}`,
        description: `Quyền ${action} trong module ${moduleName}`,
        module: moduleName,
      });
      permissions.push(p);
    }
  }

  console.log(`✅ Created ${permissions.length + 1} permissions`);
  return { allPermission, permissions };
}

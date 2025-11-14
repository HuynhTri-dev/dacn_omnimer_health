import { connectDB, disconnectDB } from "./db";
import { seedExerciseCategory } from "./seedExerciseCategory";
import { seedExerciseType } from "./seedExerciseType";
import { seedPermissions } from "./seedPermissions";
import { seedRoles } from "./seedRoles";

async function main() {
  try {
    await connectDB();

    const { allPermission, permissions } = await seedPermissions();
    const roles = await seedRoles(allPermission, permissions);
    const categories = await seedExerciseCategory();
    const types = await seedExerciseType();

    console.log("✅ Seeding completed successfully");
    console.table({
      superadmin: roles.superadmin._id.toString(),
      coach: roles.coach._id.toString(),
      user: roles.user._id.toString(),
      categories: categories.length,
      types: types.length,
    });
  } catch (err) {
    console.error("❌ Seeding error:", err);
  } finally {
    await disconnectDB();
  }
}

main();

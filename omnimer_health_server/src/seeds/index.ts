import { connectDB, disconnectDB } from "./db";
import { seedBodyPartsAndMuscles } from "./seedBodyPartAndMuscles";
import { seedEquipment } from "./seedEquipment";
import { seedExercises } from "./seedExercise";
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
    const equipments = await seedEquipment(); // Chạy seed Equipment
    const { savedBodyParts, savedMuscles } = await seedBodyPartsAndMuscles();

    const exercises = await seedExercises(
      categories as any, // Truyền documents categories
      types as any, // Truyền documents types
      equipments as any, // Truyền documents equipments
      savedMuscles as any // Truyền documents muscles (để ánh xạ BodyPart)
    );

    console.log("✅ Seeding completed successfully");
    console.table({
      superadmin: roles.superadmin._id.toString(),
      coach: roles.coach._id.toString(),
      user: roles.user._id.toString(),
      categories: categories.length,
      types: types.length,
      equipments: equipments.length,
      bodyParts: savedBodyParts.length,
      muscles: savedMuscles.length,
      exercises: exercises.length,
    });
  } catch (err) {
    console.error("❌ Seeding error:", err);
  } finally {
    await disconnectDB();
  }
}

main();

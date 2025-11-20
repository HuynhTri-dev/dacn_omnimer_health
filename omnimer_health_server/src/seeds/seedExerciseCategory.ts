import { ExerciseCategory } from "../domain/models";

export async function seedExerciseCategory() {
  await ExerciseCategory.deleteMany({});

  const categories = [
    { name: "Cardio", description: "Bài tập tim mạch, đốt calo, tăng sức bền" },
    { name: "Strength", description: "Bài tập sức mạnh, phát triển cơ bắp" },
    { name: "Flexibility", description: "Bài tập kéo giãn, cải thiện dẻo dai" },
    { name: "Balance", description: "Bài tập giữ thăng bằng, ổn định cơ thể" },
    { name: "HIIT", description: "Tập cường độ cao ngắt quãng, đốt mỡ nhanh" },
    { name: "Rehabilitation", description: "Bài tập phục hồi chức năng" },
    { name: "Mobility", description: "Cải thiện khả năng vận động khớp" },
    { name: "Mindfulness", description: "Tập trung hơi thở, giảm căng thẳng" },
  ];

  const docs = await ExerciseCategory.insertMany(categories);
  console.log(`✅ Seeded ${docs.length} ExerciseCategories`);
  return docs;
}

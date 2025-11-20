import { GoalTypeEnum } from "../common/constants/EnumConstants";
import { ExerciseType } from "../domain/models";

export async function seedExerciseType() {
  await ExerciseType.deleteMany({});

  const types = [
    {
      name: "Aerobic",
      description: "Bài tập cải thiện sức khỏe tim mạch, đốt mỡ",
      suitableGoals: [
        GoalTypeEnum.WeightLoss,
        GoalTypeEnum.HeartHealth,
        GoalTypeEnum.Endurance,
      ],
    },
    {
      name: "Strength Training",
      description: "Tập tạ, bodyweight để tăng cơ và sức mạnh",
      suitableGoals: [
        GoalTypeEnum.MuscleGain,
        GoalTypeEnum.AthleticPerformance,
      ],
    },
    {
      name: "Yoga",
      description: "Cải thiện linh hoạt, giảm stress, cân bằng tâm trí",
      suitableGoals: [
        GoalTypeEnum.Flexibility,
        GoalTypeEnum.StressRelief,
        GoalTypeEnum.Mobility,
      ],
    },
    {
      name: "Pilates",
      description: "Tăng sức mạnh cơ lõi, tư thế và kiểm soát chuyển động",
      suitableGoals: [
        GoalTypeEnum.Mobility,
        GoalTypeEnum.Flexibility,
        GoalTypeEnum.MuscleGain,
      ],
    },
    {
      name: "HIIT",
      description: "Cường độ cao giúp đốt calo và tăng sức bền tim mạch",
      suitableGoals: [GoalTypeEnum.WeightLoss, GoalTypeEnum.Endurance],
    },
    {
      name: "Stretching",
      description: "Kéo giãn cơ thể, giảm căng cơ và cải thiện linh hoạt",
      suitableGoals: [GoalTypeEnum.Flexibility, GoalTypeEnum.Mobility],
    },
    {
      name: "Functional Training",
      description:
        "Tập luyện mô phỏng hoạt động hằng ngày để cải thiện vận động tổng thể",
      suitableGoals: [
        GoalTypeEnum.Mobility,
        GoalTypeEnum.AthleticPerformance,
        GoalTypeEnum.HeartHealth,
      ],
    },
    {
      name: "Rehabilitation",
      description: "Phục hồi chấn thương và duy trì vận động",
      suitableGoals: [GoalTypeEnum.Mobility, GoalTypeEnum.Custom],
    },
  ];

  const docs = await ExerciseType.insertMany(types);
  console.log(`✅ Seeded ${docs.length} ExerciseTypes`);
  return docs;
}

import {
  IRAGExercise,
  IRAGHealthProfile,
  IRAGUserContext,
  IRAGGoal,
} from "../domain/entities";

/**
 * Chuyển đổi IRAGUserContext sang định dạng UserProfile của AI backend (Pydantic)
 */
export function normalizeUserContext(context: IRAGUserContext) {
  const hp: IRAGHealthProfile = context.healthProfile;

  // --- Coerce số về number ---
  const age = Number(hp.age) || 0;
  const height_cm = Number(hp.height) || 0;
  const weight_kg = Number(hp.weight) || 0;
  const bmi = Number(hp.bmi) || 0;
  const body_fat_percentage = Number(hp.bodyFatPercentage) || 0;

  const resting_hr = Number(hp.restingHeartRate) || 0;
  const workout_frequency_per_week = Number(hp.workoutFrequency) || 0;
  const activity_level = Number(hp.activityLevel) || 1;

  // --- Chuyển targetMetric từ array sang dict ---
  let target_metric: Record<string, any> = {};
  const firstGoal: IRAGGoal | undefined = context.goals?.[0];
  if (firstGoal && Array.isArray(firstGoal.targetMetric)) {
    target_metric = firstGoal.targetMetric.reduce((acc, item: any) => {
      // Giả sử mỗi item có key `metricName` và `value`
      if (item.metricName) acc[item.metricName] = item.value;
      return acc;
    }, {} as Record<string, any>);
  }

  // --- Chuyển exercises ---
  const exercises: Record<string, any>[] = (context.exercises ?? []).map(
    (ex: IRAGExercise) => ({
      exercise_name: ex.exerciseName ?? "",
    })
  );

  const profile = {
    // Số nguyên
    age: Math.round(age),
    resting_hr: Math.round(resting_hr),
    workout_frequency_per_week: Math.round(workout_frequency_per_week),
    activity_level: Math.round(activity_level),

    // Số thực
    height_cm,
    weight_kg,
    bmi,
    body_fat_percentage,

    // Chuỗi
    gender: hp.gender?.toString() || "",
    experience_level: hp.experienceLevel ?? "beginner",
    goal_type: firstGoal?.goalType ?? "General",

    // Dict / List
    health_status: hp.healthStatus ?? {},
    target_metric,
    exercises,
  };

  return profile;
}

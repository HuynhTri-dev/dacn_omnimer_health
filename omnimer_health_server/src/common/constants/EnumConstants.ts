// =================== GENDER ===================
export enum GenderEnum {
  Male = "male",
  Female = "female",
  Other = "other",
}

// Tuple tự động từ enum TS để dùng trong Mongoose enum
export const GenderTuple = Object.values(GenderEnum) as [
  GenderEnum,
  ...GenderEnum[]
];

// =================== GOAL TYPE ===================
export enum GoalTypeEnum {
  WeightLoss = "WeightLoss",
  MuscleGain = "MuscleGain",
  Endurance = "Endurance",
  Flexibility = "Flexibility",
  Custom = "Custom",
}

// Tuple tự động từ enum TS để dùng trong Mongoose enum
export const GoalTypeTuple = Object.values(GoalTypeEnum) as [
  GoalTypeEnum,
  ...GoalTypeEnum[]
];

//  =================== EXPERIENCE LEVEL ===================
export enum ExperienceLevelEnum {
  Beginner = "Beginner",
  Intermediate = "Intermediate",
  Advanced = "Advanced",
  Expert = "Expert",
}

export const ExperienceLevelTuple = Object.values(ExperienceLevelEnum) as [
  ExperienceLevelEnum,
  ...ExperienceLevelEnum[]
];

//  =================== EXPERIENCE LEVEL ===================
export enum DifficultyLevelEnum {
  Beginner = "Beginner",
  Intermediate = "Intermediate",
  Advanced = "Advanced",
  Expert = "Expert",
}

export const DifficultyLevelTuple = Object.values(DifficultyLevelEnum) as [
  DifficultyLevelEnum,
  ...DifficultyLevelEnum[]
];

//  =================== WORKOUT DETAIL ===================
export enum WorkoutDetailTypeEnum {
  Reps = "reps",
  Time = "time",
  Distance = "distance",
  Mixed = "mixed",
}

export const WorkoutDetailTypeTuple = Object.values(WorkoutDetailTypeEnum) as [
  WorkoutDetailTypeEnum,
  ...WorkoutDetailTypeEnum[]
];

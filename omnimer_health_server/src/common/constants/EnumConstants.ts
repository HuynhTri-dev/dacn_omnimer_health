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
  WeightLoss = "WeightLoss", // Giảm cân, giảm mỡ
  MuscleGain = "MuscleGain", // Tăng cơ, săn chắc cơ bắp
  Endurance = "Endurance", // Tăng sức bền, sức chịu đựng
  Flexibility = "Flexibility", // Tăng linh hoạt, dẻo dai
  StressRelief = "StressRelief", // Giảm căng thẳng, thư giãn
  HeartHealth = "HeartHealth", // Cải thiện tim mạch, sức khỏe tổng quát
  Mobility = "Mobility", // Cải thiện khả năng vận động khớp
  AthleticPerformance = "AthleticPerformance", // Cải thiện hiệu suất thể thao
  Custom = "Custom", // Mục tiêu tùy chỉnh
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

//  =================== LOCATION EXERCISE/WORKOUT ===================
export enum LocationEnum {
  Home = "Home",
  Gym = "Gym",
  Outdoor = "Outdoor",
  Pool = "Pool",
  None = "None",
}

export const LocationTuple = Object.values(LocationEnum) as [
  LocationEnum,
  ...LocationEnum[]
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

//  =================== RISK LEVEL ===================
export enum RiskLevelEnum {
  Low = "low",
  Medium = "Medium",
  High = "high",
  Unknown = "",
}

export const RiskLevelTuple = Object.values(RiskLevelEnum) as [
  RiskLevelEnum,
  ...RiskLevelEnum[]
];

//  =================== NAME DEVICES ===================
export enum NameDeviceEnum {
  AppleWatch = "Apple Watch",
  Garmin = "Garmin",
  Fitbit = "Fitbit",
  Samsung = "Samsung Galaxy Watch",
  Huawei = "Huawei Watch",
  Polar = "Polar",
  Amazfit = "Amazfit",
  Withings = "Withings",
  Suunto = "Suunto",
  Xiaomi = "Xiaomi Watch",
  OuraRing = "Oura Ring",
  Whoop = "Whoop Strap",
  Unknown = "",
}

export const NameDeviceTuple = Object.values(NameDeviceEnum) as [
  NameDeviceEnum,
  ...NameDeviceEnum[]
];

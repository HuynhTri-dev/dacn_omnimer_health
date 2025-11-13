// =================== GENDER ===================
enum GenderEnum {
  Male("male"),
  Female("female"),
  Other("other");

  final String displayName;
  const GenderEnum(this.displayName);

  String get asString => name;

  static GenderEnum fromString(String? value) {
    return GenderEnum.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GenderEnum.Other,
    );
  }
}

// =================== GOAL TYPE ===================
enum GoalTypeEnum {
  WeightLoss("Giảm cân, giảm mỡ"),
  MuscleGain("Tăng cơ, săn chắc cơ bắp"),
  Endurance("Tăng sức bền, sức chịu đựng"),
  Flexibility("Tăng linh hoạt, dẻo dai"),
  StressRelief("Giảm căng thẳng, thư giãn"),
  HeartHealth("Cải thiện tim mạch, sức khỏe tổng quát"),
  Mobility("Cải thiện khả năng vận động khớp"),
  AthleticPerformance("Cải thiện hiệu suất thể thao"),
  Custom("Mục tiêu tùy chỉnh");

  final String displayName;
  const GoalTypeEnum(this.displayName);

  String get asString => name;

  static GoalTypeEnum fromString(String? value) {
    return GoalTypeEnum.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GoalTypeEnum.Custom,
    );
  }
}

// =================== EXPERIENCE LEVEL ===================
enum ExperienceLevelEnum {
  Beginner("Beginner"),
  Intermediate("Intermediate"),
  Advanced("Advanced"),
  Expert("Expert");

  final String displayName;
  const ExperienceLevelEnum(this.displayName);

  String get asString => name;

  static ExperienceLevelEnum fromString(String? value) {
    return ExperienceLevelEnum.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExperienceLevelEnum.Beginner,
    );
  }
}

// =================== DIFFICULTY LEVEL ===================
enum DifficultyLevelEnum {
  Beginner("Beginner"),
  Intermediate("Intermediate"),
  Advanced("Advanced"),
  Expert("Expert");

  final String displayName;
  const DifficultyLevelEnum(this.displayName);

  String get asString => name;

  static DifficultyLevelEnum fromString(String? value) {
    return DifficultyLevelEnum.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DifficultyLevelEnum.Beginner,
    );
  }
}

// =================== LOCATION EXERCISE/WORKOUT ===================
enum LocationEnum {
  Home("Home"),
  Gym("Gym"),
  Outdoor("Outdoor"),
  Pool("Pool"),
  None("None");

  final String displayName;
  const LocationEnum(this.displayName);

  String get asString => name;

  static LocationEnum fromString(String? value) {
    return LocationEnum.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LocationEnum.None,
    );
  }
}

// =================== WORKOUT DETAIL ===================
enum WorkoutDetailTypeEnum {
  Reps("reps"),
  Time("time"),
  Distance("distance"),
  Mixed("mixed");

  final String displayName;
  const WorkoutDetailTypeEnum(this.displayName);

  String get asString => name;

  static WorkoutDetailTypeEnum fromString(String? value) {
    return WorkoutDetailTypeEnum.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WorkoutDetailTypeEnum.Mixed,
    );
  }
}

// =================== RISK LEVEL ===================
enum RiskLevelEnum {
  Low("low"),
  Medium("Medium"),
  High("high"),
  Unknown("");

  final String displayName;
  const RiskLevelEnum(this.displayName);

  String get asString => name;

  static RiskLevelEnum fromString(String? value) {
    return RiskLevelEnum.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RiskLevelEnum.Unknown,
    );
  }
}

// =================== NAME DEVICES ===================
enum NameDeviceEnum {
  AppleWatch("Apple Watch"),
  Garmin("Garmin"),
  Fitbit("Fitbit"),
  Samsung("Samsung Galaxy Watch"),
  Huawei("Huawei Watch"),
  Polar("Polar"),
  Amazfit("Amazfit"),
  Withings("Withings"),
  Suunto("Suunto"),
  Xiaomi("Xiaomi Watch"),
  OuraRing("Oura Ring"),
  Whoop("Whoop Strap"),
  Unknown("");

  final String displayName;
  const NameDeviceEnum(this.displayName);

  String get asString => name;

  static NameDeviceEnum fromString(String? value) {
    return NameDeviceEnum.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NameDeviceEnum.Unknown,
    );
  }
}

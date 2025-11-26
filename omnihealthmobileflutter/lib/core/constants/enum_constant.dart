// =================== GENDER ===================
enum GenderEnum {
  male("Male"),
  female("Female"),
  other("Other");

  final String displayName;
  const GenderEnum(this.displayName);

  String get asString => name;

  static GenderEnum fromString(String? value) {
    return GenderEnum.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GenderEnum.other,
    );
  }
}

// =================== GOAL TYPE ===================
enum GoalTypeEnum {
  WeightLoss("Weight Loss"),
  MuscleGain("Muscle Gain"),
  Endurance("Endurance"),
  Flexibility("Flexibility"),
  StressRelief("Stress Relief"),
  HeartHealth("Heart Health"),
  Mobility("Mobility"),
  AthleticPerformance("Athletic Performance"),
  Custom("Custom");

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

// =================== ACTIVITY LEVEL ===================
enum ActivityLevelEnum {
  sedentary(1, "Sedentary (little or no exercise)"),
  lightlyActive(2, "Lightly active (light exercise/sports 1-3 days/week)"),
  moderatelyActive(
    3,
    "Moderately active (moderate exercise/sports 3-5 days/week)",
  ),
  veryActive(4, "Very active (hard exercise/sports 6-7 days/week)"),
  extraActive(
    5,
    "Extra active (very hard exercise/sports & physical job or 2x training)",
  );

  final int value;
  final String displayName;
  const ActivityLevelEnum(this.value, this.displayName);

  static ActivityLevelEnum fromValue(int? value) {
    return ActivityLevelEnum.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ActivityLevelEnum.sedentary,
    );
  }
}

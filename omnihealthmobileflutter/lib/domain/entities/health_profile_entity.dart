class HealthProfileEntity {
  final String fullName;
  final String gender;
  final DateTime birthday;
  final int age;
  final double bmi;
  final double whr;
  final double bmr;
  final double bodyFat;
  final double muscleMass;
  final double height;
  final double weight;
  final double neck;
  final double waist;
  final double hip;
  final String? profileImage;

  HealthProfileEntity({
    required this.fullName,
    required this.gender,
    required this.birthday,
    required this.age,
    required this.bmi,
    required this.whr,
    required this.bmr,
    required this.bodyFat,
    required this.muscleMass,
    required this.height,
    required this.weight,
    required this.neck,
    required this.waist,
    required this.hip,
    this.profileImage,
  });
}
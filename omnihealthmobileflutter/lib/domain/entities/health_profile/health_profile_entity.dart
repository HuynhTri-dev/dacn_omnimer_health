import 'package:equatable/equatable.dart';

class HealthProfile extends Equatable {
  final String? id;
  final String? userId;
  final DateTime checkupDate;
  final double? height;
  final double? weight;
  final double? waist;
  final double? neck;
  final double? hip;
  final double? bmi;
  final double? bmr;
  final double? whr;
  final double? bodyFat;
  final double? muscleMass;
  final int? maxPushUps;
  final double? maxWeightLifted;
  final int? activityLevel;
  final String? experienceLevel;
  final int? workoutFrequency;
  final int? restingHeartRate;
  final BloodPressure? bloodPressure;
  final Cholesterol? cholesterol;
  final double? bloodSugar;
  final List<String>? healthStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HealthProfile({
    this.id,
    this.userId,
    required this.checkupDate,
    this.height,
    this.weight,
    this.waist,
    this.neck,
    this.hip,
    this.bmi,
    this.bmr,
    this.whr,
    this.bodyFat,
    this.muscleMass,
    this.maxPushUps,
    this.maxWeightLifted,
    this.activityLevel,
    this.experienceLevel,
    this.workoutFrequency,
    this.restingHeartRate,
    this.bloodPressure,
    this.cholesterol,
    this.bloodSugar,
    this.healthStatus,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        checkupDate,
        height,
        weight,
        waist,
        neck,
        hip,
        bmi,
        bmr,
        whr,
        bodyFat,
        muscleMass,
        maxPushUps,
        maxWeightLifted,
        activityLevel,
        experienceLevel,
        workoutFrequency,
        restingHeartRate,
        bloodPressure,
        cholesterol,
        bloodSugar,
        healthStatus,
        createdAt,
        updatedAt,
      ];

  HealthProfile copyWith({
    String? id,
    String? userId,
    DateTime? checkupDate,
    double? height,
    double? weight,
    double? waist,
    double? neck,
    double? hip,
    double? bmi,
    double? bmr,
    double? whr,
    double? bodyFat,
    double? muscleMass,
    int? maxPushUps,
    double? maxWeightLifted,
    int? activityLevel,
    String? experienceLevel,
    int? workoutFrequency,
    int? restingHeartRate,
    BloodPressure? bloodPressure,
    Cholesterol? cholesterol,
    double? bloodSugar,
    List<String>? healthStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkupDate: checkupDate ?? this.checkupDate,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      waist: waist ?? this.waist,
      neck: neck ?? this.neck,
      hip: hip ?? this.hip,
      bmi: bmi ?? this.bmi,
      bmr: bmr ?? this.bmr,
      whr: whr ?? this.whr,
      bodyFat: bodyFat ?? this.bodyFat,
      muscleMass: muscleMass ?? this.muscleMass,
      maxPushUps: maxPushUps ?? this.maxPushUps,
      maxWeightLifted: maxWeightLifted ?? this.maxWeightLifted,
      activityLevel: activityLevel ?? this.activityLevel,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      workoutFrequency: workoutFrequency ?? this.workoutFrequency,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      cholesterol: cholesterol ?? this.cholesterol,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      healthStatus: healthStatus ?? this.healthStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BloodPressure extends Equatable {
  final int systolic;
  final int diastolic;

  const BloodPressure({
    required this.systolic,
    required this.diastolic,
  });

  @override
  List<Object?> get props => [systolic, diastolic];
}

class Cholesterol extends Equatable {
  final double total;
  final double hdl;
  final double ldl;

  const Cholesterol({
    required this.total,
    required this.hdl,
    required this.ldl,
  });

  @override
  List<Object?> get props => [total, hdl, ldl];
}
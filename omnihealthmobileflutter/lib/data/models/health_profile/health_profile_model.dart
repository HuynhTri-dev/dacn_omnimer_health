import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

class HealthProfileModel {
  final String? id;
  final String? userId;
  final String checkupDate;
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
  final ExperienceLevelEnum? experienceLevel;
  final int? workoutFrequency;
  final int? restingHeartRate;
  final BloodPressureModel? bloodPressure;
  final CholesterolModel? cholesterol;
  final double? bloodSugar;
  final HealthStatusModel? healthStatus;
  final AiEvaluationModel? aiEvaluation;
  final String? createdAt;
  final String? updatedAt;

  HealthProfileModel({
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
    this.aiEvaluation,
    this.createdAt,
    this.updatedAt,
  });

  factory HealthProfileModel.fromJson(Map<String, dynamic> json) {
    // Handle userId being either a String or a Map
    String? userId;
    if (json['userId'] is Map) {
      userId = json['userId']['_id'] as String?;
    } else {
      userId = json['userId'] as String?;
    }

    return HealthProfileModel(
      id: json['id'] as String? ?? json['_id'] as String?,
      userId: userId,
      checkupDate: json['checkupDate'] as String,
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      waist: json['waist']?.toDouble(),
      neck: json['neck']?.toDouble(),
      hip: json['hip']?.toDouble(),
      bmi: json['bmi']?.toDouble(),
      bmr: json['bmr']?.toDouble(),
      whr: json['whr']?.toDouble(),
      bodyFat:
          json['bodyFat']?.toDouble() ?? json['bodyFatPercentage']?.toDouble(),
      muscleMass: json['muscleMass']?.toDouble(),
      maxPushUps: json['maxPushUps'] as int?,
      maxWeightLifted: json['maxWeightLifted']?.toDouble(),
      activityLevel: json['activityLevel'] as int?,
      experienceLevel: ExperienceLevelEnum.fromString(json['experienceLevel']),
      workoutFrequency: json['workoutFrequency'] as int?,
      restingHeartRate: json['restingHeartRate'] as int?,
      bloodPressure: json['bloodPressure'] != null
          ? BloodPressureModel.fromJson(json['bloodPressure'])
          : null,
      cholesterol: json['cholesterol'] != null
          ? CholesterolModel.fromJson(json['cholesterol'])
          : null,
      bloodSugar: json['bloodSugar']?.toDouble(),
      healthStatus: json['healthStatus'] != null
          ? HealthStatusModel.fromJson(json['healthStatus'])
          : null,
      aiEvaluation: json['aiEvaluation'] != null
          ? AiEvaluationModel.fromJson(json['aiEvaluation'])
          : null,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      'checkupDate': checkupDate,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (waist != null) 'waist': waist,
      if (neck != null) 'neck': neck,
      if (hip != null) 'hip': hip,
      if (bmi != null) 'bmi': bmi,
      if (bmr != null) 'bmr': bmr,
      if (whr != null) 'whr': whr,
      if (bodyFat != null) 'bodyFat': bodyFat,
      if (muscleMass != null) 'muscleMass': muscleMass,
      if (maxPushUps != null) 'maxPushUps': maxPushUps,
      if (maxWeightLifted != null) 'maxWeightLifted': maxWeightLifted,
      if (activityLevel != null) 'activityLevel': activityLevel,
      if (experienceLevel != null) 'experienceLevel': experienceLevel?.name,
      if (workoutFrequency != null) 'workoutFrequency': workoutFrequency,
      if (restingHeartRate != null) 'restingHeartRate': restingHeartRate,
      if (bloodPressure != null) 'bloodPressure': bloodPressure!.toJson(),
      if (cholesterol != null) 'cholesterol': cholesterol!.toJson(),
      if (bloodSugar != null) 'bloodSugar': bloodSugar,
      if (healthStatus != null) 'healthStatus': healthStatus!.toJson(),
      if (aiEvaluation != null) 'aiEvaluation': aiEvaluation!.toJson(),
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  HealthProfile toEntity() {
    return HealthProfile(
      id: id,
      userId: userId,
      checkupDate: DateTime.parse(checkupDate),
      height: height,
      weight: weight,
      waist: waist,
      neck: neck,
      hip: hip,
      bmi: bmi,
      bmr: bmr,
      whr: whr,
      bodyFat: bodyFat,
      muscleMass: muscleMass,
      maxPushUps: maxPushUps,
      maxWeightLifted: maxWeightLifted,
      activityLevel: activityLevel,
      experienceLevel: experienceLevel,
      workoutFrequency: workoutFrequency,
      restingHeartRate: restingHeartRate,
      bloodPressure: bloodPressure?.toEntity(),
      cholesterol: cholesterol?.toEntity(),
      bloodSugar: bloodSugar,
      healthStatus: healthStatus?.toEntity(),
      aiEvaluation: aiEvaluation?.toEntity(),
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  factory HealthProfileModel.fromEntity(HealthProfile entity) {
    return HealthProfileModel(
      id: entity.id,
      userId: entity.userId,
      checkupDate: entity.checkupDate.toIso8601String(),
      height: entity.height,
      weight: entity.weight,
      waist: entity.waist,
      neck: entity.neck,
      hip: entity.hip,
      bmi: entity.bmi,
      bmr: entity.bmr,
      whr: entity.whr,
      bodyFat: entity.bodyFat,
      muscleMass: entity.muscleMass,
      maxPushUps: entity.maxPushUps,
      maxWeightLifted: entity.maxWeightLifted,
      activityLevel: entity.activityLevel,
      experienceLevel: entity.experienceLevel,
      workoutFrequency: entity.workoutFrequency,
      restingHeartRate: entity.restingHeartRate,
      bloodPressure: entity.bloodPressure != null
          ? BloodPressureModel.fromEntity(entity.bloodPressure!)
          : null,
      cholesterol: entity.cholesterol != null
          ? CholesterolModel.fromEntity(entity.cholesterol!)
          : null,
      bloodSugar: entity.bloodSugar,
      healthStatus: entity.healthStatus != null
          ? HealthStatusModel.fromEntity(entity.healthStatus!)
          : null,
      aiEvaluation: entity.aiEvaluation != null
          ? AiEvaluationModel.fromEntity(entity.aiEvaluation!)
          : null,
      createdAt: entity.createdAt?.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }
}

class BloodPressureModel {
  final int systolic;
  final int diastolic;

  BloodPressureModel({required this.systolic, required this.diastolic});

  factory BloodPressureModel.fromJson(Map<String, dynamic> json) {
    return BloodPressureModel(
      systolic: json['systolic'] as int,
      diastolic: json['diastolic'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'systolic': systolic, 'diastolic': diastolic};
  }

  BloodPressure toEntity() {
    return BloodPressure(systolic: systolic, diastolic: diastolic);
  }

  factory BloodPressureModel.fromEntity(BloodPressure entity) {
    return BloodPressureModel(
      systolic: entity.systolic,
      diastolic: entity.diastolic,
    );
  }
}

class CholesterolModel {
  final double total;
  final double hdl;
  final double ldl;

  CholesterolModel({required this.total, required this.hdl, required this.ldl});

  factory CholesterolModel.fromJson(Map<String, dynamic> json) {
    return CholesterolModel(
      total: json['total'].toDouble(),
      hdl: json['hdl'].toDouble(),
      ldl: json['ldl'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'hdl': hdl, 'ldl': ldl};
  }

  Cholesterol toEntity() {
    return Cholesterol(total: total, hdl: hdl, ldl: ldl);
  }

  factory CholesterolModel.fromEntity(Cholesterol entity) {
    return CholesterolModel(
      total: entity.total,
      hdl: entity.hdl,
      ldl: entity.ldl,
    );
  }
}

class HealthStatusModel {
  final List<String> knownConditions;
  final List<String> painLocations;
  final List<String> jointIssues;
  final List<String> injuries;
  final List<String> abnormalities;
  final String? notes;

  HealthStatusModel({
    this.knownConditions = const [],
    this.painLocations = const [],
    this.jointIssues = const [],
    this.injuries = const [],
    this.abnormalities = const [],
    this.notes,
  });

  factory HealthStatusModel.fromJson(dynamic json) {
    if (json is List) {
      // Handle legacy format where healthStatus was List<String>
      // Map all items to knownConditions as a fallback
      return HealthStatusModel(knownConditions: List<String>.from(json));
    } else if (json is Map<String, dynamic>) {
      return HealthStatusModel(
        knownConditions: json['knownConditions'] != null
            ? List<String>.from(json['knownConditions'])
            : [],
        painLocations: json['painLocations'] != null
            ? List<String>.from(json['painLocations'])
            : [],
        jointIssues: json['jointIssues'] != null
            ? List<String>.from(json['jointIssues'])
            : [],
        injuries: json['injuries'] != null
            ? List<String>.from(json['injuries'])
            : [],
        abnormalities: json['abnormalities'] != null
            ? List<String>.from(json['abnormalities'])
            : [],
        notes: json['notes'] as String?,
      );
    }
    return HealthStatusModel();
  }

  Map<String, dynamic> toJson() {
    return {
      'knownConditions': knownConditions,
      'painLocations': painLocations,
      'jointIssues': jointIssues,
      'injuries': injuries,
      'abnormalities': abnormalities,
      if (notes != null) 'notes': notes,
    };
  }

  HealthStatus toEntity() {
    return HealthStatus(
      knownConditions: knownConditions,
      painLocations: painLocations,
      jointIssues: jointIssues,
      injuries: injuries,
      abnormalities: abnormalities,
      notes: notes,
    );
  }

  factory HealthStatusModel.fromEntity(HealthStatus entity) {
    return HealthStatusModel(
      knownConditions: entity.knownConditions,
      painLocations: entity.painLocations,
      jointIssues: entity.jointIssues,
      injuries: entity.injuries,
      abnormalities: entity.abnormalities,
      notes: entity.notes,
    );
  }
}

class AiEvaluationModel {
  final String summary;
  final int? score;
  final RiskLevelEnum? riskLevel;
  final String? updatedAt;
  final String? modelVersion;

  AiEvaluationModel({
    required this.summary,
    this.score,
    this.riskLevel,
    this.updatedAt,
    this.modelVersion,
  });

  factory AiEvaluationModel.fromJson(Map<String, dynamic> json) {
    return AiEvaluationModel(
      summary: json['summary'] as String? ?? '',
      score: json['score'] as int?,
      riskLevel: RiskLevelEnum.fromString(json['riskLevel']),
      updatedAt: json['updatedAt'] as String?,
      modelVersion: json['modelVersion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      if (score != null) 'score': score,
      if (riskLevel != null) 'riskLevel': riskLevel?.name,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (modelVersion != null) 'modelVersion': modelVersion,
    };
  }

  AiEvaluation toEntity() {
    return AiEvaluation(
      summary: summary,
      score: score,
      riskLevel: riskLevel,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      modelVersion: modelVersion,
    );
  }

  factory AiEvaluationModel.fromEntity(AiEvaluation entity) {
    return AiEvaluationModel(
      summary: entity.summary,
      score: entity.score,
      riskLevel: entity.riskLevel,
      updatedAt: entity.updatedAt?.toIso8601String(),
      modelVersion: entity.modelVersion,
    );
  }
}

import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_entity.dart';

/// Model for a completed set in workout log
class WorkoutLogSetModel {
  final String? id;
  final int setOrder;
  final int? reps;
  final double? weight;
  final int? duration;
  final double? distance;
  final int? restAfterSetSeconds;
  final String? notes;
  final bool isCompleted;

  WorkoutLogSetModel({
    this.id,
    required this.setOrder,
    this.reps,
    this.weight,
    this.duration,
    this.distance,
    this.restAfterSetSeconds,
    this.notes,
    this.isCompleted = false,
  });

  factory WorkoutLogSetModel.fromJson(Map<String, dynamic> json) {
    return WorkoutLogSetModel(
      id: json['_id'],
      setOrder: json['setOrder'] ?? 0,
      reps: json['reps'],
      weight: json['weight']?.toDouble(),
      duration: json['duration'],
      distance: json['distance']?.toDouble(),
      restAfterSetSeconds: json['restAfterSetSeconds'],
      notes: json['notes'],
      // Server uses 'done', convert to isCompleted
      isCompleted: json['done'] ?? json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'setOrder': setOrder,
      if (reps != null) 'reps': reps,
      if (weight != null) 'weight': weight,
      if (duration != null) 'duration': duration,
      if (distance != null) 'distance': distance,
      if (restAfterSetSeconds != null)
        'restAfterSetSeconds': restAfterSetSeconds,
      if (notes != null) 'notes': notes,
      'done': isCompleted,
    };
  }

  WorkoutLogSetEntity toEntity() {
    return WorkoutLogSetEntity(
      id: id,
      setOrder: setOrder,
      reps: reps,
      weight: weight,
      duration: duration,
      distance: distance,
      restAfterSetSeconds: restAfterSetSeconds,
      notes: notes,
      isCompleted: isCompleted,
    );
  }

  factory WorkoutLogSetModel.fromEntity(WorkoutLogSetEntity entity) {
    return WorkoutLogSetModel(
      id: entity.id,
      setOrder: entity.setOrder,
      reps: entity.reps,
      weight: entity.weight,
      duration: entity.duration,
      distance: entity.distance,
      restAfterSetSeconds: entity.restAfterSetSeconds,
      notes: entity.notes,
      isCompleted: entity.isCompleted,
    );
  }
}

/// Model for device data in workout log
class WorkoutDeviceDataModel {
  final String? id;
  final double? heartRateAvg;
  final double? heartRateMax;
  final double? caloriesBurned;

  WorkoutDeviceDataModel({
    this.id,
    this.heartRateAvg,
    this.heartRateMax,
    this.caloriesBurned,
  });

  factory WorkoutDeviceDataModel.fromJson(Map<String, dynamic> json) {
    return WorkoutDeviceDataModel(
      id: json['_id'],
      heartRateAvg: json['heartRateAvg']?.toDouble(),
      heartRateMax: json['heartRateMax']?.toDouble(),
      caloriesBurned: json['caloriesBurned']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (heartRateAvg != null) 'heartRateAvg': heartRateAvg,
      if (heartRateMax != null) 'heartRateMax': heartRateMax,
      if (caloriesBurned != null) 'caloriesBurned': caloriesBurned,
    };
  }

  WorkoutDeviceDataEntity toEntity() {
    return WorkoutDeviceDataEntity(
      id: id,
      heartRateAvg: heartRateAvg,
      heartRateMax: heartRateMax,
      caloriesBurned: caloriesBurned,
    );
  }

  factory WorkoutDeviceDataModel.fromEntity(WorkoutDeviceDataEntity entity) {
    return WorkoutDeviceDataModel(
      id: entity.id,
      heartRateAvg: entity.heartRateAvg,
      heartRateMax: entity.heartRateMax,
      caloriesBurned: entity.caloriesBurned,
    );
  }
}

/// Model for an exercise in workout log
class WorkoutLogExerciseModel {
  final String? id; // Workout Detail ID (subdocument ID)
  final String exerciseId;
  final String exerciseName;
  final String? exerciseImageUrl;
  final String type;
  final List<WorkoutLogSetModel> sets;
  final double? durationMin;
  final WorkoutDeviceDataModel? deviceData;
  final bool isCompleted;

  WorkoutLogExerciseModel({
    this.id,
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseImageUrl,
    required this.type,
    required this.sets,
    this.durationMin,
    this.deviceData,
    this.isCompleted = false,
  });

  factory WorkoutLogExerciseModel.fromJson(Map<String, dynamic> json) {
    // Handle populated exerciseId
    String exId = '';
    String exName = '';
    String? exImageUrl;

    if (json['exerciseId'] is String) {
      exId = json['exerciseId'];
      exName = json['exerciseName'] ?? '';
    } else if (json['exerciseId'] is Map<String, dynamic>) {
      final exercise = json['exerciseId'] as Map<String, dynamic>;
      exId = exercise['_id'] ?? '';
      exName = exercise['name'] ?? '';
      if (exercise['imageUrls'] != null &&
          (exercise['imageUrls'] as List).isNotEmpty) {
        exImageUrl = exercise['imageUrls'][0];
      }
    }

    return WorkoutLogExerciseModel(
      id: json['_id'], // Capture the subdocument ID
      exerciseId: exId,
      exerciseName: exName,
      exerciseImageUrl: exImageUrl ?? json['exerciseImageUrl'],
      type: json['type'] ?? '',
      sets:
          (json['sets'] as List?)
              ?.map((set) => WorkoutLogSetModel.fromJson(set))
              .toList() ??
          [],
      durationMin: json['durationMin']?.toDouble(),
      deviceData: json['deviceData'] != null
          ? WorkoutDeviceDataModel.fromJson(json['deviceData'])
          : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      if (exerciseImageUrl != null) 'exerciseImageUrl': exerciseImageUrl,
      'type': type,
      'sets': sets.map((set) => set.toJson()).toList(),
      if (durationMin != null) 'durationMin': durationMin,
      if (deviceData != null) 'deviceData': deviceData!.toJson(),
      'isCompleted': isCompleted,
    };
  }

  WorkoutLogExerciseEntity toEntity() {
    return WorkoutLogExerciseEntity(
      id: id,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      exerciseImageUrl: exerciseImageUrl,
      type: type,
      sets: sets.map((set) => set.toEntity()).toList(),
      durationMin: durationMin,
      deviceData: deviceData?.toEntity(),
      isCompleted: isCompleted,
    );
  }

  factory WorkoutLogExerciseModel.fromEntity(WorkoutLogExerciseEntity entity) {
    return WorkoutLogExerciseModel(
      id: entity.id,
      exerciseId: entity.exerciseId,
      exerciseName: entity.exerciseName,
      exerciseImageUrl: entity.exerciseImageUrl,
      type: entity.type,
      sets: entity.sets
          .map((set) => WorkoutLogSetModel.fromEntity(set))
          .toList(),
      durationMin: entity.durationMin,
      deviceData: entity.deviceData != null
          ? WorkoutDeviceDataModel.fromEntity(entity.deviceData!)
          : null,
      isCompleted: entity.isCompleted,
    );
  }
}

/// Model for workout summary
class WorkoutSummaryModel {
  final double? heartRateAvgAllWorkout;
  final double? heartRateMaxAllWorkout;
  final int? totalSets;
  final int? totalReps;
  final double? totalWeight;
  final int? totalDuration;
  final double? totalCalories;
  final double? totalDistance;

  WorkoutSummaryModel({
    this.heartRateAvgAllWorkout,
    this.heartRateMaxAllWorkout,
    this.totalSets,
    this.totalReps,
    this.totalWeight,
    this.totalDuration,
    this.totalCalories,
    this.totalDistance,
  });

  factory WorkoutSummaryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSummaryModel(
      heartRateAvgAllWorkout: json['heartRateAvgAllWorkout']?.toDouble(),
      heartRateMaxAllWorkout: json['heartRateMaxAllWorkout']?.toDouble(),
      totalSets: (json['totalSets'] as num?)?.toInt(),
      totalReps: (json['totalReps'] as num?)?.toInt(),
      totalWeight: json['totalWeight']?.toDouble(),
      totalDuration: (json['totalDuration'] as num?)?.toInt(),
      totalCalories: json['totalCalories']?.toDouble(),
      totalDistance: json['totalDistance']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (heartRateAvgAllWorkout != null)
        'heartRateAvgAllWorkout': heartRateAvgAllWorkout,
      if (heartRateMaxAllWorkout != null)
        'heartRateMaxAllWorkout': heartRateMaxAllWorkout,
      if (totalSets != null) 'totalSets': totalSets,
      if (totalReps != null) 'totalReps': totalReps,
      if (totalWeight != null) 'totalWeight': totalWeight,
      if (totalDuration != null) 'totalDuration': totalDuration,
      if (totalCalories != null) 'totalCalories': totalCalories,
      if (totalDistance != null) 'totalDistance': totalDistance,
    };
  }

  WorkoutSummaryEntity toEntity() {
    return WorkoutSummaryEntity(
      heartRateAvgAllWorkout: heartRateAvgAllWorkout,
      heartRateMaxAllWorkout: heartRateMaxAllWorkout,
      totalSets: totalSets,
      totalReps: totalReps,
      totalWeight: totalWeight,
      totalDuration: totalDuration,
      totalCalories: totalCalories,
      totalDistance: totalDistance,
    );
  }

  factory WorkoutSummaryModel.fromEntity(WorkoutSummaryEntity entity) {
    return WorkoutSummaryModel(
      heartRateAvgAllWorkout: entity.heartRateAvgAllWorkout,
      heartRateMaxAllWorkout: entity.heartRateMaxAllWorkout,
      totalSets: entity.totalSets,
      totalReps: entity.totalReps,
      totalWeight: entity.totalWeight,
      totalDuration: entity.totalDuration,
      totalCalories: entity.totalCalories,
      totalDistance: entity.totalDistance,
    );
  }
}

/// Model for workout log
class WorkoutLogModel {
  final String? id;
  final String userId;
  final String? healthProfileId;
  final String? templateId;
  final String workoutName;
  final List<WorkoutLogExerciseModel> exercises;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String? notes;
  final WorkoutSummaryModel? summary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkoutLogModel({
    this.id,
    required this.userId,
    this.healthProfileId,
    this.templateId,
    required this.workoutName,
    required this.exercises,
    required this.startedAt,
    this.finishedAt,
    this.notes,
    this.summary,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    // Handle workoutTemplateId as object or string
    String? templateId;
    String workoutName = json['workoutName'] ?? json['name'] ?? '';

    if (json['workoutTemplateId'] is Map<String, dynamic>) {
      final templateData = json['workoutTemplateId'] as Map<String, dynamic>;
      templateId = templateData['_id'];
      if (workoutName.isEmpty) {
        workoutName = templateData['name'] ?? '';
      }
    } else if (json['workoutTemplateId'] is String) {
      templateId = json['workoutTemplateId'];
    } else if (json['templateId'] != null) {
      templateId = json['templateId'];
    }

    // Parse exercises from workoutDetail
    List<WorkoutLogExerciseModel> exercises = [];
    final exerciseList = json['exercises'] ?? json['workoutDetail'];
    if (exerciseList is List) {
      exercises = exerciseList
          .map(
            (e) => WorkoutLogExerciseModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }

    // Handle startedAt or timeStart
    DateTime? startedAt;
    if (json['startedAt'] != null) {
      startedAt = DateTime.parse(json['startedAt']);
    } else if (json['timeStart'] != null) {
      startedAt = DateTime.parse(json['timeStart']);
    } else if (json['createdAt'] != null) {
      startedAt = DateTime.parse(json['createdAt']);
    }

    return WorkoutLogModel(
      id: json['_id'],
      userId: json['userId'] ?? '', // Should be present
      healthProfileId: json['healthProfileId'],
      templateId: templateId,
      workoutName: workoutName,
      exercises: exercises,
      startedAt: startedAt ?? DateTime.now(),
      finishedAt: json['finishedAt'] != null
          ? DateTime.parse(json['finishedAt'])
          : null,
      notes: json['notes'],
      summary: json['summary'] != null
          ? WorkoutSummaryModel.fromJson(json['summary'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      if (healthProfileId != null) 'healthProfileId': healthProfileId,
      if (templateId != null) 'workoutTemplateId': templateId,
      'workoutName': workoutName,
      'workoutDetail': exercises.map((e) => e.toJson()).toList(),
      'timeStart': startedAt.toIso8601String(),
      if (finishedAt != null) 'finishedAt': finishedAt!.toIso8601String(),
      if (notes != null) 'notes': notes,
      if (summary != null) 'summary': summary!.toJson(),
    };
  }

  WorkoutLogEntity toEntity() {
    return WorkoutLogEntity(
      id: id,
      userId: userId,
      healthProfileId: healthProfileId,
      templateId: templateId,
      workoutName: workoutName,
      exercises: exercises.map((e) => e.toEntity()).toList(),
      startedAt: startedAt,
      finishedAt: finishedAt,
      notes: notes,
      summary: summary?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory WorkoutLogModel.fromEntity(WorkoutLogEntity entity) {
    return WorkoutLogModel(
      id: entity.id,
      userId: entity.userId,
      healthProfileId: entity.healthProfileId,
      templateId: entity.templateId,
      workoutName: entity.workoutName,
      exercises: entity.exercises
          .map((e) => WorkoutLogExerciseModel.fromEntity(e))
          .toList(),
      startedAt: entity.startedAt,
      finishedAt: entity.finishedAt,
      notes: entity.notes,
      summary: entity.summary != null
          ? WorkoutSummaryModel.fromEntity(entity.summary!)
          : null,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

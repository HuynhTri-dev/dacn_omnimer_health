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
  final bool isCompleted;
  final DateTime? completedAt;

  WorkoutLogSetModel({
    this.id,
    required this.setOrder,
    this.reps,
    this.weight,
    this.duration,
    this.distance,
    this.restAfterSetSeconds,
    this.isCompleted = false,
    this.completedAt,
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
      // Server uses 'done', convert to isCompleted
      isCompleted: json['done'] ?? json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
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
      isCompleted: isCompleted,
      completedAt: completedAt,
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
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
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
  final bool isCompleted;

  WorkoutLogExerciseModel({
    this.id,
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseImageUrl,
    required this.type,
    required this.sets,
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
      isCompleted: entity.isCompleted,
    );
  }
}

/// Model for workout log
class WorkoutLogModel {
  final String? id;
  final String? templateId;
  final String workoutName;
  final List<WorkoutLogExerciseModel> exercises;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int durationSeconds;
  final String? notes;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkoutLogModel({
    this.id,
    this.templateId,
    required this.workoutName,
    required this.exercises,
    required this.startedAt,
    this.finishedAt,
    required this.durationSeconds,
    this.notes,
    this.status = 'completed',
    this.createdAt,
    this.updatedAt,
  });

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    // Calculate duration if not provided
    int durationSeconds = 0;
    if (json['durationSeconds'] != null) {
      durationSeconds = json['durationSeconds'];
    } else if (json['summary'] != null &&
        json['summary']['totalDuration'] != null) {
      durationSeconds = json['summary']['totalDuration'];
    } else if (json['startedAt'] != null && json['finishedAt'] != null) {
      final started = DateTime.parse(json['startedAt']);
      final finished = DateTime.parse(json['finishedAt']);
      durationSeconds = finished.difference(started).inSeconds;
    }

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
      templateId: templateId,
      workoutName: workoutName,
      exercises: exercises,
      startedAt: startedAt ?? DateTime.now(),
      finishedAt: json['finishedAt'] != null
          ? DateTime.parse(json['finishedAt'])
          : null,
      durationSeconds: durationSeconds,
      notes: json['notes'],
      status: json['status'] ?? 'completed',
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
      if (templateId != null) 'templateId': templateId,
      'workoutName': workoutName,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'startedAt': startedAt.toIso8601String(),
      if (finishedAt != null) 'finishedAt': finishedAt!.toIso8601String(),
      'durationSeconds': durationSeconds,
      if (notes != null) 'notes': notes,
      'status': status,
    };
  }

  WorkoutLogEntity toEntity() {
    return WorkoutLogEntity(
      id: id,
      templateId: templateId,
      workoutName: workoutName,
      exercises: exercises.map((e) => e.toEntity()).toList(),
      startedAt: startedAt,
      finishedAt: finishedAt,
      durationSeconds: durationSeconds,
      notes: notes,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory WorkoutLogModel.fromEntity(WorkoutLogEntity entity) {
    return WorkoutLogModel(
      id: entity.id,
      templateId: entity.templateId,
      workoutName: entity.workoutName,
      exercises: entity.exercises
          .map((e) => WorkoutLogExerciseModel.fromEntity(e))
          .toList(),
      startedAt: entity.startedAt,
      finishedAt: entity.finishedAt,
      durationSeconds: entity.durationSeconds,
      notes: entity.notes,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

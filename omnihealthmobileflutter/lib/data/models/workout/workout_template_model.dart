import 'package:omnihealthmobileflutter/data/models/exercise/body_part_model.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/equipment_model.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_category_model.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_type_model.dart';
import 'package:omnihealthmobileflutter/data/models/muscle/muscle_model.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';

/// Model for Workout Template Set
class WorkoutTemplateSetModel {
  final int setOrder;
  final int? reps;
  final double? weight;
  final int? duration;
  final double? distance;
  final int? restAfterSetSeconds;
  final String? notes;

  WorkoutTemplateSetModel({
    required this.setOrder,
    this.reps,
    this.weight,
    this.duration,
    this.distance,
    this.restAfterSetSeconds,
    this.notes,
  });

  factory WorkoutTemplateSetModel.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplateSetModel(
      setOrder: json['setOrder'] ?? 0,
      reps: json['reps'],
      weight: json['weight']?.toDouble(),
      duration: json['duration'],
      distance: json['distance']?.toDouble(),
      restAfterSetSeconds: json['restAfterSetSeconds'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setOrder': setOrder,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'distance': distance,
      'restAfterSetSeconds': restAfterSetSeconds,
      'notes': notes,
    };
  }

  WorkoutTemplateSetEntity toEntity() {
    return WorkoutTemplateSetEntity(
      setOrder: setOrder,
      reps: reps,
      weight: weight,
      duration: duration,
      distance: distance,
      restAfterSetSeconds: restAfterSetSeconds,
      notes: notes,
    );
  }
}

/// Model for Workout Template Detail
class WorkoutTemplateDetailModel {
  final String exerciseId;
  final String exerciseName;
  final String? exerciseImageUrl;
  final String type;
  final List<WorkoutTemplateSetModel> sets;

  WorkoutTemplateDetailModel({
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseImageUrl,
    required this.type,
    required this.sets,
  });

  factory WorkoutTemplateDetailModel.fromJson(Map<String, dynamic> json) {
    // Handle populated exerciseId
    String exId = '';
    String exName = '';
    String? exImageUrl;

    if (json['exerciseId'] is String) {
      exId = json['exerciseId'];
      exName = '';
    } else if (json['exerciseId'] is Map<String, dynamic>) {
      final exercise = json['exerciseId'] as Map<String, dynamic>;
      exId = exercise['_id'] ?? '';
      exName = exercise['name'] ?? '';
      if (exercise['imageUrls'] != null &&
          (exercise['imageUrls'] as List).isNotEmpty) {
        exImageUrl = exercise['imageUrls'][0];
      }
    }

    return WorkoutTemplateDetailModel(
      exerciseId: exId,
      exerciseName: exName,
      exerciseImageUrl: exImageUrl,
      type: json['type'] ?? '',
      sets: (json['sets'] as List?)
              ?.map((set) => WorkoutTemplateSetModel.fromJson(set))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'type': type,
      'sets': sets.map((set) => set.toJson()).toList(),
    };
  }

  WorkoutTemplateDetailEntity toEntity() {
    return WorkoutTemplateDetailEntity(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      exerciseImageUrl: exerciseImageUrl,
      type: type,
      sets: sets.map((set) => set.toEntity()).toList(),
    );
  }
}

/// Model for Workout Template
class WorkoutTemplateModel {
  final String id;
  final String name;
  final String description;
  final String? notes;
  final List<EquipmentModel> equipments;
  final List<BodyPartModel> bodyPartsTarget;
  final List<ExerciseTypeModel> exerciseTypes;
  final List<ExerciseCategoryModel> exerciseCategories;
  final List<MuscleModel> musclesTarget;
  final String? location;
  final List<WorkoutTemplateDetailModel> workOutDetail;
  final bool createdByAI;
  final String? createdForUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkoutTemplateModel({
    required this.id,
    required this.name,
    required this.description,
    this.notes,
    required this.equipments,
    required this.bodyPartsTarget,
    required this.exerciseTypes,
    required this.exerciseCategories,
    required this.musclesTarget,
    this.location,
    required this.workOutDetail,
    required this.createdByAI,
    this.createdForUserId,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkoutTemplateModel.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplateModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      notes: json['notes'],
      equipments: (json['equipments'] as List?)
              ?.map((e) => EquipmentModel.fromJson(e))
              .toList() ??
          [],
      bodyPartsTarget: (json['bodyPartsTarget'] as List?)
              ?.map((bp) => BodyPartModel.fromJson(bp))
              .toList() ??
          [],
      exerciseTypes: (json['exerciseTypes'] as List?)
              ?.map((et) => ExerciseTypeModel.fromJson(et))
              .toList() ??
          [],
      exerciseCategories: (json['exerciseCategories'] as List?)
              ?.map((ec) => ExerciseCategoryModel.fromJson(ec))
              .toList() ??
          [],
      musclesTarget: (json['musclesTarget'] as List?)
              ?.map((m) => MuscleModel.fromJson(m))
              .toList() ??
          [],
      location: json['location'],
      workOutDetail: (json['workOutDetail'] as List?)
              ?.map((detail) => WorkoutTemplateDetailModel.fromJson(detail))
              .toList() ??
          [],
      createdByAI: json['createdByAI'] ?? false,
      createdForUserId: json['createdForUserId'],
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
      '_id': id,
      'name': name,
      'description': description,
      'notes': notes,
      'equipments': equipments.map((e) => e.toJson()).toList(),
      'bodyPartsTarget': bodyPartsTarget.map((bp) => bp.toJson()).toList(),
      'exerciseTypes': exerciseTypes.map((et) => et.toJson()).toList(),
      'exerciseCategories':
          exerciseCategories.map((ec) => ec.toJson()).toList(),
      'musclesTarget': musclesTarget.map((m) => m.toJson()).toList(),
      'location': location,
      'workOutDetail': workOutDetail.map((detail) => detail.toJson()).toList(),
      'createdByAI': createdByAI,
      'createdForUserId': createdForUserId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  WorkoutTemplateEntity toEntity() {
    return WorkoutTemplateEntity(
      id: id,
      name: name,
      description: description,
      notes: notes,
      equipments: equipments.map((e) => e.toEntity()).toList(),
      bodyPartsTarget: bodyPartsTarget.map((bp) => bp.toEntity()).toList(),
      exerciseTypes: exerciseTypes.map((et) => et.toEntity()).toList(),
      exerciseCategories:
          exerciseCategories.map((ec) => ec.toEntity()).toList(),
      musclesTarget: musclesTarget.map((m) => m.toEntity()).toList(),
      location: location,
      workOutDetail: workOutDetail.map((detail) => detail.toEntity()).toList(),
      createdByAI: createdByAI,
      createdForUserId: createdForUserId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<WorkoutTemplateEntity> toEntityList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => WorkoutTemplateModel.fromJson(json).toEntity())
        .toList();
  }
}


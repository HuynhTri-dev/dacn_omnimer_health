import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/body_part_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/equipment_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_category_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_type_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/muscle_entity.dart';

/// Entity for Workout Template Set
class WorkoutTemplateSetEntity extends Equatable {
  final int setOrder;
  final int? reps;
  final double? weight;
  final int? duration; // seconds
  final double? distance; // meters
  final int? restAfterSetSeconds;
  final String? notes;

  const WorkoutTemplateSetEntity({
    required this.setOrder,
    this.reps,
    this.weight,
    this.duration,
    this.distance,
    this.restAfterSetSeconds,
    this.notes,
  });

  @override
  List<Object?> get props => [
    setOrder,
    reps,
    weight,
    duration,
    distance,
    restAfterSetSeconds,
    notes,
  ];
}

/// Entity for Workout Template Detail (Exercise in template)
class WorkoutTemplateDetailEntity extends Equatable {
  final String exerciseId;
  final String exerciseName;
  final String? exerciseImageUrl;
  final String type; // Strength, Cardio, etc.
  final List<WorkoutTemplateSetEntity> sets;

  const WorkoutTemplateDetailEntity({
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseImageUrl,
    required this.type,
    required this.sets,
  });

  @override
  List<Object?> get props => [
    exerciseId,
    exerciseName,
    exerciseImageUrl,
    type,
    sets,
  ];
}

/// Entity for Workout Template
class WorkoutTemplateEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? notes;
  final List<EquipmentEntity> equipments;
  final List<BodyPartEntity> bodyPartsTarget;
  final List<ExerciseTypeEntity> exerciseTypes;
  final List<ExerciseCategoryEntity> exerciseCategories;
  final List<MuscleEntity> musclesTarget;
  final String? location; // gym, home, outdoor
  final List<WorkoutTemplateDetailEntity> workOutDetail;
  final bool createdByAI;
  final String? createdForUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkoutTemplateEntity({
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

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    notes,
    equipments,
    bodyPartsTarget,
    exerciseTypes,
    exerciseCategories,
    musclesTarget,
    location,
    workOutDetail,
    createdByAI,
    createdForUserId,
    createdAt,
    updatedAt,
  ];

  WorkoutTemplateEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? notes,
    List<EquipmentEntity>? equipments,
    List<BodyPartEntity>? bodyPartsTarget,
    List<ExerciseTypeEntity>? exerciseTypes,
    List<ExerciseCategoryEntity>? exerciseCategories,
    List<MuscleEntity>? musclesTarget,
    String? location,
    List<WorkoutTemplateDetailEntity>? workOutDetail,
    bool? createdByAI,
    String? createdForUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutTemplateEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      equipments: equipments ?? this.equipments,
      bodyPartsTarget: bodyPartsTarget ?? this.bodyPartsTarget,
      exerciseTypes: exerciseTypes ?? this.exerciseTypes,
      exerciseCategories: exerciseCategories ?? this.exerciseCategories,
      musclesTarget: musclesTarget ?? this.musclesTarget,
      location: location ?? this.location,
      workOutDetail: workOutDetail ?? this.workOutDetail,
      createdByAI: createdByAI ?? this.createdByAI,
      createdForUserId: createdForUserId ?? this.createdForUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

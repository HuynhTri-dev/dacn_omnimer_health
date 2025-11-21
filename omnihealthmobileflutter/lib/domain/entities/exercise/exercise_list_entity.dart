import 'package:equatable/equatable.dart';

/// Entity for Exercise in list view (getAllExercise)
/// Domain layer representation of exercise list item
class ExerciseListEntity extends Equatable {
  final String id;
  final String name;
  final List<EquipmentEntity> equipments;
  final List<BodyPartEntity> bodyParts;
  final List<MuscleReferenceEntity> mainMuscles;
  final List<MuscleReferenceEntity> secondaryMuscles;
  final List<ExerciseTypeEntity> exerciseTypes;
  final List<ExerciseCategoryEntity> exerciseCategories;
  final String location;
  final String difficulty;
  final String imageUrl;

  const ExerciseListEntity({
    required this.id,
    required this.name,
    required this.equipments,
    required this.bodyParts,
    required this.mainMuscles,
    required this.secondaryMuscles,
    required this.exerciseTypes,
    required this.exerciseCategories,
    required this.location,
    required this.difficulty,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    equipments,
    bodyParts,
    mainMuscles,
    secondaryMuscles,
    exerciseTypes,
    exerciseCategories,
    location,
    difficulty,
    imageUrl,
  ];

  ExerciseListEntity copyWith({
    String? id,
    String? name,
    List<EquipmentEntity>? equipments,
    List<BodyPartEntity>? bodyParts,
    List<MuscleReferenceEntity>? mainMuscles,
    List<MuscleReferenceEntity>? secondaryMuscles,
    List<ExerciseTypeEntity>? exerciseTypes,
    List<ExerciseCategoryEntity>? exerciseCategories,
    String? location,
    String? difficulty,
    String? imageUrl,
  }) {
    return ExerciseListEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      equipments: equipments ?? this.equipments,
      bodyParts: bodyParts ?? this.bodyParts,
      mainMuscles: mainMuscles ?? this.mainMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      exerciseTypes: exerciseTypes ?? this.exerciseTypes,
      exerciseCategories: exerciseCategories ?? this.exerciseCategories,
      location: location ?? this.location,
      difficulty: difficulty ?? this.difficulty,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

/// Equipment Entity
class EquipmentEntity extends Equatable {
  final String id;
  final String name;

  const EquipmentEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

/// BodyPart Entity
class BodyPartEntity extends Equatable {
  final String id;
  final String name;

  const BodyPartEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

/// Muscle Reference Entity (for main and secondary muscles)
class MuscleReferenceEntity extends Equatable {
  final String id;
  final String name;

  const MuscleReferenceEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

/// ExerciseType Entity
class ExerciseTypeEntity extends Equatable {
  final String id;
  final String name;

  const ExerciseTypeEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

/// ExerciseCategory Entity
class ExerciseCategoryEntity extends Equatable {
  final String id;
  final String name;

  const ExerciseCategoryEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

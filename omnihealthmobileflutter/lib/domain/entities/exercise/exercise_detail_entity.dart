import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_list_entity.dart';

/// Entity for Exercise Detail (getExerciseById)
/// Domain layer representation of complete exercise information
class ExerciseDetailEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String instructions;
  final List<EquipmentEntity> equipments;
  final List<BodyPartEntity> bodyParts;
  final List<MuscleReferenceEntity> mainMuscles;
  final List<MuscleReferenceEntity> secondaryMuscles;
  final List<ExerciseTypeEntity> exerciseTypes;
  final List<ExerciseCategoryEntity> exerciseCategories;
  final String location;
  final String difficulty;
  final List<String> imageUrls;
  final String? videoUrl;
  final int? met;
  final double? averageScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExerciseDetailEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.instructions,
    required this.equipments,
    required this.bodyParts,
    required this.mainMuscles,
    required this.secondaryMuscles,
    required this.exerciseTypes,
    required this.exerciseCategories,
    required this.location,
    required this.difficulty,
    required this.imageUrls,
    this.videoUrl,
    this.met,
    this.averageScore,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    instructions,
    equipments,
    bodyParts,
    mainMuscles,
    secondaryMuscles,
    exerciseTypes,
    exerciseCategories,
    location,
    difficulty,
    imageUrls,
    videoUrl,
    met,
    averageScore,
    createdAt,
    updatedAt,
  ];

  ExerciseDetailEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? instructions,
    List<EquipmentEntity>? equipments,
    List<BodyPartEntity>? bodyParts,
    List<MuscleReferenceEntity>? mainMuscles,
    List<MuscleReferenceEntity>? secondaryMuscles,
    List<ExerciseTypeEntity>? exerciseTypes,
    List<ExerciseCategoryEntity>? exerciseCategories,
    String? location,
    String? difficulty,
    List<String>? imageUrls,
    String? videoUrl,
    int? met,
    double? averageScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExerciseDetailEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      equipments: equipments ?? this.equipments,
      bodyParts: bodyParts ?? this.bodyParts,
      mainMuscles: mainMuscles ?? this.mainMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      exerciseTypes: exerciseTypes ?? this.exerciseTypes,
      exerciseCategories: exerciseCategories ?? this.exerciseCategories,
      location: location ?? this.location,
      difficulty: difficulty ?? this.difficulty,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      met: met ?? this.met,
      averageScore: averageScore ?? this.averageScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

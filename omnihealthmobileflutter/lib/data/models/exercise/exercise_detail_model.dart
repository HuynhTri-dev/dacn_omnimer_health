import 'package:omnihealthmobileflutter/data/models/exercise/exercise_list_model.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_detail_entity.dart';

/// Model for Exercise Detail (getExerciseById response)
/// Contains complete information including description, instructions, multiple images, video, etc.
class ExerciseDetailModel {
  final String id;
  final String name;
  final String description;
  final String instructions;
  final List<EquipmentModel> equipments;
  final List<BodyPartModel> bodyParts;
  final List<MuscleModel> mainMuscles;
  final List<MuscleModel> secondaryMuscles;
  final List<ExerciseTypeModel> exerciseTypes;
  final List<ExerciseCategoryModel> exerciseCategories;
  final String location;
  final String difficulty;
  final List<String> imageUrls;
  final String? videoUrl;
  final int? met;
  final double? averageScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExerciseDetailModel({
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

  /// Parse from JSON (API response)
  factory ExerciseDetailModel.fromJson(Map<String, dynamic> json) {
    return ExerciseDetailModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      instructions: json['instructions'] ?? '',
      equipments:
          (json['equipments'] as List<dynamic>?)
              ?.map((e) => EquipmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bodyParts:
          (json['bodyParts'] as List<dynamic>?)
              ?.map((e) => BodyPartModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mainMuscles:
          (json['mainMuscles'] as List<dynamic>?)
              ?.map((e) => MuscleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      secondaryMuscles:
          (json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => MuscleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      exerciseTypes:
          (json['exerciseTypes'] as List<dynamic>?)
              ?.map(
                (e) => ExerciseTypeModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      exerciseCategories:
          (json['exerciseCategories'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ExerciseCategoryModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      location: json['location'] ?? '',
      difficulty: json['difficulty'] ?? '',
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      videoUrl: json['videoUrl']?.toString(),
      met: json['met'] != null ? (json['met'] as num).toInt() : null,
      averageScore: json['averageScore'] != null
          ? (json['averageScore'] as num).toDouble()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Convert to Entity
  ExerciseDetailEntity toEntity() {
    return ExerciseDetailEntity(
      id: id,
      name: name,
      description: description,
      instructions: instructions,
      equipments: equipments.map((e) => e.toEntity()).toList(),
      bodyParts: bodyParts.map((e) => e.toEntity()).toList(),
      mainMuscles: mainMuscles.map((e) => e.toEntity()).toList(),
      secondaryMuscles: secondaryMuscles.map((e) => e.toEntity()).toList(),
      exerciseTypes: exerciseTypes.map((e) => e.toEntity()).toList(),
      exerciseCategories: exerciseCategories.map((e) => e.toEntity()).toList(),
      location: location,
      difficulty: difficulty,
      imageUrls: imageUrls,
      videoUrl: videoUrl,
      met: met,
      averageScore: averageScore,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

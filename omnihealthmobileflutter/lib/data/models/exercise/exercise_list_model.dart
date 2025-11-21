import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_list_entity.dart';

/// Model for Exercise in list view (getAllExercise response)
/// Contains basic information for displaying exercises in a list
class ExerciseListModel {
  final String id;
  final String name;
  final List<EquipmentModel> equipments;
  final List<BodyPartModel> bodyParts;
  final List<MuscleModel> mainMuscles;
  final List<MuscleModel> secondaryMuscles;
  final List<ExerciseTypeModel> exerciseTypes;
  final List<ExerciseCategoryModel> exerciseCategories;
  final String location;
  final String difficulty;
  final String imageUrl;

  ExerciseListModel({
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

  /// Parse from JSON (API response)
  factory ExerciseListModel.fromJson(Map<String, dynamic> json) {
    return ExerciseListModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
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
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  /// Convert to Entity
  ExerciseListEntity toEntity() {
    return ExerciseListEntity(
      id: id,
      name: name,
      equipments: equipments.map((e) => e.toEntity()).toList(),
      bodyParts: bodyParts.map((e) => e.toEntity()).toList(),
      mainMuscles: mainMuscles.map((e) => e.toEntity()).toList(),
      secondaryMuscles: secondaryMuscles.map((e) => e.toEntity()).toList(),
      exerciseTypes: exerciseTypes.map((e) => e.toEntity()).toList(),
      exerciseCategories: exerciseCategories.map((e) => e.toEntity()).toList(),
      location: location,
      difficulty: difficulty,
      imageUrl: imageUrl,
    );
  }

  /// Convert list of models to list of entities
  static List<ExerciseListEntity> toEntityList(List<ExerciseListModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}

/// Equipment Model
class EquipmentModel {
  final String id;
  final String name;

  EquipmentModel({required this.id, required this.name});

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(id: json['_id'] ?? '', name: json['name'] ?? '');
  }

  EquipmentEntity toEntity() {
    return EquipmentEntity(id: id, name: name);
  }
}

/// BodyPart Model
class BodyPartModel {
  final String id;
  final String name;

  BodyPartModel({required this.id, required this.name});

  factory BodyPartModel.fromJson(Map<String, dynamic> json) {
    return BodyPartModel(id: json['_id'] ?? '', name: json['name'] ?? '');
  }

  BodyPartEntity toEntity() {
    return BodyPartEntity(id: id, name: name);
  }
}

/// Muscle Model (for main and secondary muscles)
class MuscleModel {
  final String id;
  final String name;

  MuscleModel({required this.id, required this.name});

  factory MuscleModel.fromJson(Map<String, dynamic> json) {
    return MuscleModel(id: json['_id'] ?? '', name: json['name'] ?? '');
  }

  MuscleReferenceEntity toEntity() {
    return MuscleReferenceEntity(id: id, name: name);
  }
}

/// ExerciseType Model
class ExerciseTypeModel {
  final String id;
  final String name;

  ExerciseTypeModel({required this.id, required this.name});

  factory ExerciseTypeModel.fromJson(Map<String, dynamic> json) {
    return ExerciseTypeModel(id: json['_id'] ?? '', name: json['name'] ?? '');
  }

  ExerciseTypeEntity toEntity() {
    return ExerciseTypeEntity(id: id, name: name);
  }
}

/// ExerciseCategory Model
class ExerciseCategoryModel {
  final String id;
  final String name;

  ExerciseCategoryModel({required this.id, required this.name});

  factory ExerciseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExerciseCategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  ExerciseCategoryEntity toEntity() {
    return ExerciseCategoryEntity(id: id, name: name);
  }
}

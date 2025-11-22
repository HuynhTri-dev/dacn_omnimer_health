import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_list_entity.dart';

/// Model for Exercise in list view (getAllExercise response)
/// Contains basic information for displaying exercises in a list
class ExerciseListModel {
  final String id;
  final String name;

  // SỬA: Tất cả các List đều là Nullable (List<T>?)
  final List<EquipmentModel>? equipments;
  final List<BodyPartModel>? bodyParts;
  final List<MuscleModel>? mainMuscles;
  final List<MuscleModel>? secondaryMuscles;
  final List<ExerciseTypeModel>? exerciseTypes;
  final List<ExerciseCategoryModel>? exerciseCategories;

  // String vẫn giữ required vì chúng ta dùng ?? '' trong fromJson
  final String location;
  final String difficulty;
  final String imageUrl;

  ExerciseListModel({
    required this.id,
    required this.name,
    // SỬA: Bỏ 'required' cho các List
    this.equipments,
    this.bodyParts,
    this.mainMuscles,
    this.secondaryMuscles,
    this.exerciseTypes,
    this.exerciseCategories,
    required this.location,
    required this.difficulty,
    required this.imageUrl,
  });

  /// Parse from JSON (API response)
  factory ExerciseListModel.fromJson(Map<String, dynamic> json) {
    // Lưu ý: Dùng ?.map để tránh lỗi khi json['key'] là null
    return ExerciseListModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',

      // LOGIC: Dùng List<dynamic>? và map trực tiếp.
      equipments: (json['equipments'] as List<dynamic>?)
          ?.map((e) => EquipmentModel.fromJson(e as Map<String, dynamic>))
          .toList(), // KHÔNG DÙNG ?? [] vì trường đã là nullable

      bodyParts: (json['bodyParts'] as List<dynamic>?)
          ?.map((e) => BodyPartModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      mainMuscles: (json['mainMuscles'] as List<dynamic>?)
          ?.map((e) => MuscleModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
          ?.map((e) => MuscleModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      exerciseTypes: (json['exerciseTypes'] as List<dynamic>?)
          ?.map((e) => ExerciseTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      exerciseCategories: (json['exerciseCategories'] as List<dynamic>?)
          ?.map(
            (e) => ExerciseCategoryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),

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
      // SỬA: Xử lý null bằng toán tử ?? [] trước khi gọi map
      equipments: (equipments ?? []).map((e) => e.toEntity()).toList(),
      bodyParts: (bodyParts ?? []).map((e) => e.toEntity()).toList(),
      mainMuscles: (mainMuscles ?? []).map((e) => e.toEntity()).toList(),
      secondaryMuscles: (secondaryMuscles ?? [])
          .map((e) => e.toEntity())
          .toList(),
      exerciseTypes: (exerciseTypes ?? []).map((e) => e.toEntity()).toList(),
      exerciseCategories: (exerciseCategories ?? [])
          .map((e) => e.toEntity())
          .toList(),
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

// KHÔNG CẦN THIẾT SỬA ĐỔI CÁC MODEL CON
// VÌ CHÚNG VẪN LÀ CÁC ĐỐI TƯỢNG ĐƠN LẺ

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

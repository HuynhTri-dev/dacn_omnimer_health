import '../../../domain/entities/exercise/exercise_category_entity.dart';

class ExerciseCategoryModel {
  final String id;
  final String name;
  final String? description;

  ExerciseCategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory ExerciseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExerciseCategoryModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'description': description};
  }

  ExerciseCategoryEntity toEntity() {
    return ExerciseCategoryEntity(id: id, name: name, description: description);
  }
}

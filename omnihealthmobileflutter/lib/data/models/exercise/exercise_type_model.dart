import '../../../domain/entities/exercise/exercise_type_entity.dart';

class ExerciseTypeModel {
  final String id;
  final String name;
  final String? description;
  final List<String> suitableGoals;

  ExerciseTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.suitableGoals,
  });

  factory ExerciseTypeModel.fromJson(Map<String, dynamic> json) {
    return ExerciseTypeModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      suitableGoals:
          (json['suitableGoals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'suitableGoals': suitableGoals,
    };
  }

  ExerciseTypeEntity toEntity() {
    return ExerciseTypeEntity(
      id: id,
      name: name,
      description: description,
      suitableGoals: suitableGoals,
    );
  }
}

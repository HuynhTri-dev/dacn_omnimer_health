import 'package:omnihealthmobileflutter/domain/entities/exercise/muscle_entity.dart';

class MuscleModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String>? bodyPartNames;

  MuscleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.bodyPartNames,
  });

  factory MuscleModel.fromJson(Map<String, dynamic> json) {
    return MuscleModel(
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      imageUrl: (json['imageUrl'] ?? json['imageUrl'] ?? "") as String,
      bodyPartNames: json['bodyPartNames'] as List<String>?,
    );
  }

  MuscleEntity toEntity() {
    return MuscleEntity(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      bodyPartNames: bodyPartNames,
    );
  }
}

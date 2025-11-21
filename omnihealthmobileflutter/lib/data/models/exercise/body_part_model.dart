import '../../../domain/entities/exercise/body_part_entity.dart';

class BodyPartModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;

  BodyPartModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory BodyPartModel.fromJson(Map<String, dynamic> json) {
    return BodyPartModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  BodyPartEntity toEntity() {
    return BodyPartEntity(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
    );
  }
}

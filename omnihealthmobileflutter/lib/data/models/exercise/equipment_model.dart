import '../../../domain/entities/exercise/equipment_entity.dart';

class EquipmentModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;

  EquipmentModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
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

  EquipmentEntity toEntity() {
    return EquipmentEntity(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
    );
  }
}

import 'package:omnihealthmobileflutter/domain/entities/auth/role_entity.dart';

/// RoleSelectBoxModel - Data layer
/// Chịu trách nhiệm mapping dữ liệu giữa API (JSON) và Domain (Entity)
class RoleSelectBoxModel {
  final String id;
  final String name;

  const RoleSelectBoxModel({required this.id, required this.name});

  /// Parse từ JSON (API response)
  factory RoleSelectBoxModel.fromJson(Map<String, dynamic> json) {
    return RoleSelectBoxModel(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  /// Convert từ Model sang Entity
  RoleSelectBoxEntity toEntity() {
    return RoleSelectBoxEntity(id: id, name: name);
  }

  /// Copy with method
  RoleSelectBoxModel copyWith({String? id, String? name}) {
    return RoleSelectBoxModel(id: id ?? this.id, name: name ?? this.name);
  }

  /// Parse danh sách JSON sang danh sách Model
  static List<RoleSelectBoxModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map(
          (json) => RoleSelectBoxModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Convert list Model → list Entity
  static List<RoleSelectBoxEntity> toEntityList(
    List<RoleSelectBoxModel> models,
  ) {
    return models.map((model) => model.toEntity()).toList();
  }
}

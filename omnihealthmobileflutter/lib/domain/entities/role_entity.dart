import 'package:equatable/equatable.dart';

/// RoleSelectBoxEntity Entity - Domain layer
/// Chứa business logic thuần túy, không phụ thuộc vào implementation details
class RoleSelectBoxEntity extends Equatable {
  final String id;
  final String name;

  const RoleSelectBoxEntity({required this.id, required this.name});

  /// Copy with method để tạo instance mới với một số field thay đổi
  RoleSelectBoxEntity copyWith({String? id, String? name}) {
    return RoleSelectBoxEntity(id: id ?? this.id, name: name ?? this.name);
  }

  /// Business logic: Kiểm tra xem RoleSelectBoxEntity có phải admin không
  bool get isAdmin => name.toLowerCase() == 'admin';

  /// Business logic: Kiểm tra xem RoleSelectBoxEntity có phải user không
  bool get isUser => name.toLowerCase() == 'user';

  /// Business logic: Kiểm tra xem RoleSelectBoxEntity có phải moderator không
  bool get isModerator => name.toLowerCase() == 'moderator';

  /// Business logic: Lấy display name với format đẹp
  String get displayName {
    return name
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  /// Business logic: Validate RoleSelectBoxEntity name
  bool get isValid => id.isNotEmpty && name.isNotEmpty;

  @override
  List<Object?> get props => [id, name];
}

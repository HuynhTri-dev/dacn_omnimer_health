import 'package:omnihealthmobileflutter/domain/entities/auth_entity.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';

class UserAuthModel {
  final String fullname;
  final String? email;
  final String? imageUrl;
  final String? gender; // lưu dạng string để (de)serialize JSON
  final String? birthday; // lưu dạng string (ISO date)

  const UserAuthModel({
    required this.fullname,
    this.email,
    this.imageUrl,
    this.gender,
    this.birthday,
  });

  /// JSON → Model
  factory UserAuthModel.fromJson(Map<String, dynamic> json) {
    return UserAuthModel(
      fullname: json['fullname'] ?? '',
      email: json['email'],
      imageUrl: json['imageUrl'],
      gender: json['gender'],
      birthday: json['birthday'],
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'email': email,
      'imageUrl': imageUrl,
      'gender': gender,
      'birthday': birthday,
    };
  }

  /// Model → Entity
  UserAuth toEntity() {
    return UserAuth(
      fullname: fullname,
      email: email,
      imageUrl: imageUrl,
      gender: gender != null ? GenderEnum.fromString(gender) : null,
      birthday: birthday != null ? DateTime.tryParse(birthday!) : null,
    );
  }

  /// Entity → Model
  factory UserAuthModel.fromEntity(UserAuth entity) {
    return UserAuthModel(
      fullname: entity.fullname,
      email: entity.email,
      imageUrl: entity.imageUrl,
      gender: entity.gender?.asString,
      birthday: entity.birthday?.toIso8601String(),
    );
  }
}

class AuthModel {
  final UserAuthModel user;
  final String accessToken;
  final String refreshToken;

  const AuthModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  /// JSON → Model
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      user: UserAuthModel.fromJson(json['user']),
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  /// Model → Entity
  AuthEntity toEntity() {
    return AuthEntity(
      user: user.toEntity(),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Entity → Model
  factory AuthModel.fromEntity(AuthEntity entity) {
    return AuthModel(
      user: UserAuthModel.fromEntity(entity.user),
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
    );
  }
}

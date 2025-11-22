import 'package:omnihealthmobileflutter/domain/entities/auth/user_entity.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';

class UserModel {
  final String? uid;
  final String? email;
  final String? fullname;
  final String? birthday;
  final GenderEnum? gender; // lưu dạng string để dễ (de)serialize với API
  final List<String>? roleIds;
  final String? imageUrl;

  const UserModel({
    this.uid,
    this.email,
    this.fullname,
    this.birthday,
    this.gender,
    this.roleIds,
    this.imageUrl,
  });

  /// Tạo từ JSON (API → Model)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String?,
      email: json['email'] as String?,
      fullname: json['fullname'] as String?,
      birthday: json['birthday'] as String?,
      gender: GenderEnum.fromString(json['gender']),
      roleIds: (json['roleIds'] as List?)?.map((e) => e.toString()).toList(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// Chuyển sang JSON (Model → API)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullname': fullname,
      'birthday': birthday,
      'gender': gender,
      'roleIds': roleIds,
      'imageUrl': imageUrl,
    };
  }

  /// Chuyển sang Entity (Model → Domain)
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      fullname: fullname,
      birthday: birthday,
      gender: gender,
      roleIds: roleIds,
      imageUrl: imageUrl,
    );
  }

  /// Chuyển từ Entity sang Model (Domain → Data)
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      fullname: entity.fullname,
      birthday: entity.birthday,
      gender: entity.gender,
      roleIds: entity.roleIds,
      imageUrl: entity.imageUrl,
    );
  }
}

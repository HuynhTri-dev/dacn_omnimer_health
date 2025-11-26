import 'dart:io';

import 'package:omnihealthmobileflutter/domain/entities/auth/user_entity.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';

class UserModel {
  final String? id;
  final String? email;
  final String? fullname;
  final String? birthday;
  final GenderEnum? gender; // lưu dạng string để dễ (de)serialize với API
  final List<String>? roleNames;
  final String? imageUrl;
  final File? image;

  const UserModel({
    this.id,
    this.email,
    this.fullname,
    this.birthday,
    this.gender,
    this.roleNames,
    this.imageUrl,
    this.image,
  });

  /// Tạo từ JSON (API → Model)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] as String?,
      email: json['email'] as String?,
      fullname: json['fullname'] as String?,
      birthday: json['birthday'] as String?,
      gender: GenderEnum.fromString(json['gender']),
      roleNames: (json['roleNames'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      image: json['image'] as File?,
    );
  }

  /// Chuyển sang JSON (Model → API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullname': fullname,
      'birthday': birthday,
      'gender': gender,
      'roleNames': roleNames,
      'imageUrl': imageUrl,
      'image': image,
    };
  }

  /// Chuyển sang Entity (Model → Domain)
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      fullname: fullname,
      birthday: birthday,
      gender: gender,
      roleNames: roleNames,
      imageUrl: imageUrl,
      image: image,
    );
  }

  /// Chuyển từ Entity sang Model (Domain → Data)
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullname: entity.fullname,
      birthday: entity.birthday,
      gender: entity.gender,
      roleNames: entity.roleNames,
      imageUrl: entity.imageUrl,
      image: entity.image,
    );
  }
}

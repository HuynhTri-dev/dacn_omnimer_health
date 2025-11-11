import 'dart:io';

import 'package:dio/dio.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth_entity.dart';

class RegisterModel {
  final String? email;
  final String? password;
  final String? uid;
  final String? fullname;
  final String? birthday;
  final GenderEnum? gender;
  final List<String>? roleIds;
  final File? image;

  const RegisterModel({
    this.email,
    this.password,
    this.uid,
    this.fullname,
    this.birthday,
    this.gender,
    this.roleIds,
    this.image,
  });

  // Từ Entity → Model
  factory RegisterModel.fromEntity(RegisterEntity entity) {
    return RegisterModel(
      email: entity.email,
      password: entity.password,
      uid: entity.uid,
      fullname: entity.fullname,
      birthday: entity.birthday,
      gender: entity.gender,
      roleIds: entity.roleIds,
      image: entity.image,
    );
  }

  /// Chuyển Model → FormData để gửi lên API (có file)
  Future<FormData> toFormData() async {
    final Map<String, dynamic> fields = {
      'email': email,
      'uid': uid,
      'fullname': fullname,
      'birthday': birthday,
      'gender': gender?.name, // enum → string
      'roleIds': roleIds,
    };

    if (image != null) {
      fields['image'] = await MultipartFile.fromFile(
        image!.path,
        filename: image!.uri.pathSegments.last,
      );
    }

    return FormData.fromMap(fields);
  }
}

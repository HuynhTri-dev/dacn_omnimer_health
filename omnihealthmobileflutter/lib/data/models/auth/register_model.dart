import 'package:omnihealthmobileflutter/domain/entities/auth_entity.dart';

class RegisterModel {
  final String? email;
  final String? password;
  final String? fullname;
  final String? birthday;
  final String? gender;
  final List<String>? roleIds;
  final String? imageUrl;

  const RegisterModel({
    this.email,
    this.password,
    this.fullname,
    this.birthday,
    this.gender,
    this.roleIds,
    this.imageUrl,
  });

  // Từ Entity → Model
  factory RegisterModel.fromEntity(RegisterEntity entity) {
    return RegisterModel(
      email: entity.email,
      password: entity.password,
      fullname: entity.fullname,
      birthday: entity.birthday,
      gender: entity.gender?.toString().split('.').last,
      roleIds: entity.roleIds,
      imageUrl: entity.imageUrl,
    );
  }

  // Model → JSON (để gửi lên API)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'fullname': fullname,
      'birthday': birthday,
      'gender': gender,
      'roleIds': roleIds,
      'imageUrl': imageUrl,
    };
  }
}

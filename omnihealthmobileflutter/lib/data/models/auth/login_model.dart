import 'package:omnihealthmobileflutter/domain/entities/auth/auth_entity.dart';

class LoginModel {
  final String email;
  final String password;

  const LoginModel({required this.email, required this.password});

  // Từ Entity → Model
  factory LoginModel.fromEntity(LoginEntity entity) {
    return LoginModel(email: entity.email, password: entity.password);
  }

  // Model → JSON (để gửi API)
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

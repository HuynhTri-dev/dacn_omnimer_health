import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/user_entity.dart';

/// Repository interface for authentication domain logic.
/// Bridges between Domain Entities and Data Source Models.
abstract class AuthRepositoryAbs {
  /// Register a new user using a [UserEntity].
  /// Returns ApiResponse<AuthEntity> containing tokens or error message.
  Future<ApiResponse<AuthEntity>> register(UserEntity user);

  /// Login using [LoginEntity].
  /// Returns ApiResponse<AuthEntity> containing tokens or error message.
  Future<ApiResponse<AuthEntity>> login(LoginEntity login);

  /// Create a new access token using stored refresh token.
  /// Returns ApiResponse<String> where data = new token.
  Future<ApiResponse<String>> createNewAccessToken();
}

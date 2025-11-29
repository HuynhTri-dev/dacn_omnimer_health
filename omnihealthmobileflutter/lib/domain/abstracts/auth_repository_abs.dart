import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/auth_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/user_entity.dart';

/// Repository interface for authentication domain logic.
/// Bridges between Domain Entities and Data Source Models.
abstract class AuthRepositoryAbs {
  /// Register a new user using a [RegisterEntity].
  /// Returns ApiResponse<AuthEntity> containing tokens or error message.
  Future<ApiResponse<AuthEntity>> register(RegisterEntity user);

  /// Login using [LoginEntity].
  /// Returns ApiResponse<AuthEntity> containing tokens or error message.
  Future<ApiResponse<AuthEntity>> login(LoginEntity login);

  /// Create a new access token using stored refresh token.
  /// Returns ApiResponse<String> where data = new token.
  Future<ApiResponse<String>> createNewAccessToken();

  /// Log out account
  Future<ApiResponse<void>> logout();

  /// Get AuthEntity
  /// Returns ApiResponse<AuthEntity>
  Future<ApiResponse<UserAuth>> getAuth();

  /// Update user profile
  Future<ApiResponse<UserEntity>> updateUser(String id, UserEntity user);
}

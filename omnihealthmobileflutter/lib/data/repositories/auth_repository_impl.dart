import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/auth_datasource.dart';
import 'package:omnihealthmobileflutter/data/models/auth/login_model.dart';
import 'package:omnihealthmobileflutter/data/models/user_model.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/user_entity.dart';

/// Implementation of [AuthRepository].
/// Converts between domain entities and data models.
/// Delegates data operations to [AuthDataSource].
class AuthRepositoryImpl implements AuthRepositoryAbs {
  final AuthDataSource authDataSource;

  AuthRepositoryImpl({required this.authDataSource});

  @override
  Future<ApiResponse<AuthEntity>> register(UserEntity user) async {
    // Convert Entity -> Model
    final userModel = UserModel.fromEntity(user);

    // Call DataSource
    final response = await authDataSource.register(userModel);

    // Map Model -> Entity
    if (response.data != null) {
      final authEntity = response.data?.toEntity();
      return ApiResponse<AuthEntity>(
        success: response.success,
        message: response.message,
        data: authEntity,
      );
    }

    // Return same structure (null data)
    return ApiResponse<AuthEntity>(
      success: response.success,
      message: response.message,
      data: null,
    );
  }

  @override
  Future<ApiResponse<AuthEntity>> login(LoginEntity login) async {
    final loginModel = LoginModel.fromEntity(login);
    final response = await authDataSource.login(loginModel);

    if (response.data != null) {
      final authEntity = response.data?.toEntity();
      return ApiResponse<AuthEntity>(
        success: response.success,
        message: response.message,
        data: authEntity,
      );
    }

    return ApiResponse<AuthEntity>(
      success: response.success,
      message: response.message,
      data: null,
    );
  }

  @override
  Future<ApiResponse<String>> createNewAccessToken() async {
    // No conversion needed, returns String directly
    final response = await authDataSource.createNewAccessToken();
    return response;
  }
}

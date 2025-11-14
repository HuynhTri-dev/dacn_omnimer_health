import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/auth_datasource.dart';
import 'package:omnihealthmobileflutter/data/models/auth/login_model.dart';
import 'package:omnihealthmobileflutter/data/models/auth/register_model.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth_entity.dart';

/// Implementation of [AuthRepository].
/// Converts between domain entities and data models.
/// Delegates data operations to [AuthDataSource].
class AuthRepositoryImpl implements AuthRepositoryAbs {
  final AuthDataSource authDataSource;

  AuthRepositoryImpl({required this.authDataSource});

  @override
  Future<ApiResponse<AuthEntity>> register(RegisterEntity user) async {
    try {
      // Convert Entity -> Model
      final userModel = RegisterModel.fromEntity(user);

      // Call DataSource
      final response = await authDataSource.register(userModel);

      // Map Model -> Entity
      final authEntity = response.data?.toEntity();
      return ApiResponse<AuthEntity>(
        success: response.success,
        message: response.message,
        data: authEntity,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<AuthEntity>.error(
        "Đăng ký thất bại: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<AuthEntity>> login(LoginEntity login) async {
    try {
      final loginModel = LoginModel.fromEntity(login);
      final response = await authDataSource.login(loginModel);

      final authEntity = response.data?.toEntity();
      return ApiResponse<AuthEntity>(
        success: response.success,
        message: response.message,
        data: authEntity,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<AuthEntity>.error(
        "Đăng nhập thất bại: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<String>> createNewAccessToken() async {
    try {
      final response = await authDataSource.createNewAccessToken();
      return ApiResponse<String>(
        success: response.success,
        message: response.message,
        data: response.data,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<String>.error(
        "Làm mới access token thất bại: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await authDataSource.logout();
      return ApiResponse<void>(
        success: response.success,
        message: response.message,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<void>.error(
        "Đăng xuất thất bại: ${e.toString()}",
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<UserAuth>> getAuth() async {
    try {
      final response = await authDataSource.getAuth();
      if (response.data == null) {
        return ApiResponse<UserAuth>(
          success: response.success,
          message: response.message,
          data: null,
          error: response.error,
        );
      }

      final userAuth = response.data!.toEntity();

      return ApiResponse<UserAuth>(
        success: response.success,
        message: response.message,
        data: userAuth,
        error: response.error,
      );
    } catch (e) {
      // Đã sửa lỗi kiểu trả về ở đây
      return ApiResponse<UserAuth>.error(
        "Get Auth thất bại: ${e.toString()}",
        error: e,
      );
    }
  }
}

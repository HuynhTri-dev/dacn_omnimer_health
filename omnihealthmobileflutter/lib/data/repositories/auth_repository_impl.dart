import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/auth_datasource.dart';
import 'package:omnihealthmobileflutter/data/models/auth/login_model.dart';
import 'package:omnihealthmobileflutter/data/models/auth/register_model.dart';
import 'package:omnihealthmobileflutter/data/models/auth/user_model.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/auth_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/user_entity.dart';

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
        _getErrorMessage(e, "Đăng ký thất bại"),
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
        _getErrorMessage(e, "Đăng nhập thất bại"),
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
        _getErrorMessage(e, "Làm mới access token thất bại"),
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
        _getErrorMessage(e, "Đăng xuất thất bại"),
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
        _getErrorMessage(e, "Get Auth thất bại"),
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<UserEntity>> updateUser(String id, UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final response = await authDataSource.updateUser(id, userModel);

      return ApiResponse<UserEntity>(
        success: response.success,
        message: response.message,
        data: response.data?.toEntity(),
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<UserEntity>.error(
        _getErrorMessage(e, "Cập nhật thông tin thất bại"),
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await authDataSource.changePassword(
        currentPassword,
        newPassword,
      );
      return ApiResponse<void>(
        success: response.success,
        message: response.message,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<void>.error(
        _getErrorMessage(e, "Thay đổi mật khẩu thất bại"),
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<UserEntity>> toggleDataSharing() async {
    try {
      final response = await authDataSource.toggleDataSharing();
      return ApiResponse<UserEntity>(
        success: response.success,
        message: response.message,
        data: response.data?.toEntity(),
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<UserEntity>.error(
        _getErrorMessage(e, "Toggle data sharing failed"),
        error: e,
      );
    }
  }

  String _getErrorMessage(Object e, String defaultPrefix) {
    final errorString = e.toString();
    if (errorString.contains("SocketException") ||
        errorString.contains("Network is unreachable") ||
        errorString.contains("Connection refused")) {
      return "Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.";
    }
    if (errorString.contains("401") || errorString.contains("Unauthorized")) {
      return "Phiên đăng nhập đã hết hạn hoặc thông tin xác thực không đúng.";
    }
    if (errorString.contains("403") || errorString.contains("Forbidden")) {
      return "Bạn không có quyền thực hiện hành động này.";
    }
    if (errorString.contains("404") || errorString.contains("Not Found")) {
      return "Không tìm thấy tài nguyên yêu cầu.";
    }
    if (errorString.contains("500") ||
        errorString.contains("Internal Server Error")) {
      return "Lỗi máy chủ nội bộ. Vui lòng thử lại sau.";
    }
    if (errorString.contains("Timeout")) {
      return "Quá thời gian chờ kết nối. Vui lòng thử lại.";
    }

    return "$defaultPrefix: $errorString";
  }
}

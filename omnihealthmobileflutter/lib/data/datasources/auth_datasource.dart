import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/core/constants/storage_constant.dart';
import 'package:omnihealthmobileflutter/data/models/auth/auth_model.dart';
import 'package:omnihealthmobileflutter/data/models/auth/login_model.dart';
import 'package:omnihealthmobileflutter/data/models/user_model.dart';
import 'package:omnihealthmobileflutter/services/secure_storage_service.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';

/// Data source responsible for authentication related API calls
abstract class AuthDataSource {
  /// Register by sending a UserModel.
  /// Returns the raw ApiResponse<AuthModel> so caller can inspect message/data.
  /// On success tokens will also be persisted into secure storage.
  Future<ApiResponse<AuthModel>> register(UserModel user);

  /// Login by sending LoginModel.
  /// Returns the raw ApiResponse<AuthModel> so caller can inspect message/data.
  /// On success tokens will also be persisted into secure storage.
  Future<ApiResponse<AuthModel>> login(LoginModel loginModel);

  /// Create a new access token using the refresh token stored in
  /// secure storage. Returns ApiResponse<String> where `data` is the new access token.
  /// On success the stored access token will be updated.
  Future<ApiResponse<String>> createNewAccessToken();
}

class AuthDataSourceImpl implements AuthDataSource {
  final ApiClient apiClient;
  final SecureStorageService secureStorage;

  AuthDataSourceImpl({
    required this.apiClient,
    SecureStorageService? secureStorage,
  }) : secureStorage = secureStorage ?? SecureStorageService();

  @override
  Future<ApiResponse<AuthModel>> register(UserModel user) async {
    final response = await apiClient.post<AuthModel>(
      Endpoints.register,
      data: user.toJson(),
      parser: (json) => AuthModel.fromJson(json as Map<String, dynamic>),
    );

    // If success and we have data, persist tokens
    if (response.success && response.data != null) {
      final auth = response.data!;
      await secureStorage.create(
        StorageConstant.kAccessTokenKey,
        auth.accessToken,
      );
      await secureStorage.create(
        StorageConstant.kRefreshTokenKey,
        auth.refreshToken,
      );
    }

    // Return the full ApiResponse so caller can read message/data
    return response;
  }

  @override
  Future<ApiResponse<AuthModel>> login(LoginModel loginModel) async {
    final response = await apiClient.post<AuthModel>(
      Endpoints.login,
      data: loginModel.toJson(),
      parser: (json) => AuthModel.fromJson(json as Map<String, dynamic>),
    );

    // If success and we have data, persist tokens
    if (response.success && response.data != null) {
      final auth = response.data!;
      await secureStorage.create(
        StorageConstant.kAccessTokenKey,
        auth.accessToken,
      );
      await secureStorage.create(
        StorageConstant.kRefreshTokenKey,
        auth.refreshToken,
      );
    }

    return response;
  }

  @override
  Future<ApiResponse<String>> createNewAccessToken() async {
    final refreshToken = await secureStorage.get(
      StorageConstant.kRefreshTokenKey,
    );
    if (refreshToken == null || refreshToken.isEmpty) {
      return ApiResponse<String>.error('Refresh token not found');
    }

    final response = await apiClient.post<String>(
      Endpoints.createNewAccessToken,
      data: {'refreshToken': refreshToken},
      parser: (json) => json?.toString() ?? '',
    );

    // If API returned new token, update storage
    if (response.success &&
        response.data != null &&
        response.data!.isNotEmpty) {
      final newAccessToken = response.data!;
      final exists = await secureStorage.contains(
        StorageConstant.kAccessTokenKey,
      );
      if (exists) {
        await secureStorage.update(
          StorageConstant.kAccessTokenKey,
          newAccessToken,
        );
      } else {
        await secureStorage.create(
          StorageConstant.kAccessTokenKey,
          newAccessToken,
        );
      }
    }

    return response;
  }
}

import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/core/constants/storage_constant.dart';
import 'package:omnihealthmobileflutter/data/models/auth/auth_model.dart';
import 'package:omnihealthmobileflutter/data/models/auth/login_model.dart';
import 'package:omnihealthmobileflutter/data/models/auth/register_model.dart';
import 'package:omnihealthmobileflutter/services/firebase_auth_service.dart';
import 'package:omnihealthmobileflutter/services/secure_storage_service.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/services/shared_preferences_service.dart';

/// Data source responsible for authentication related API calls
abstract class AuthDataSource {
  /// Register by sending a UserModel.
  /// Returns the raw ApiResponse<AuthModel> so caller can inspect message/data.
  /// On success tokens will also be persisted into secure storage.
  Future<ApiResponse<AuthModel>> register(RegisterModel user);

  /// Login by sending LoginModel.
  /// Returns the raw ApiResponse<AuthModel> so caller can inspect message/data.
  /// On success tokens will also be persisted into secure storage.
  Future<ApiResponse<AuthModel>> login(LoginModel loginModel);

  /// Create a new access token using the refresh token stored in
  /// secure storage. Returns ApiResponse<String> where `data` is the new access token.
  /// On success the stored access token will be updated.
  Future<ApiResponse<String>> createNewAccessToken();

  Future<ApiResponse<void>> logout();

  Future<ApiResponse<AuthModel>> getAuth();
}

class AuthDataSourceImpl implements AuthDataSource {
  final ApiClient apiClient;
  final SecureStorageService secureStorage;
  final FirebaseAuthService firebaseAuthService;
  final SharedPreferencesService sharedPreferencesService;

  AuthDataSourceImpl({
    required this.apiClient,
    required this.secureStorage,
    required this.firebaseAuthService,
    required this.sharedPreferencesService,
  });

  @override
  Future<ApiResponse<AuthModel>> register(RegisterModel user) async {
    try {
      // Lấy email và password từ user
      final email = user.email;
      final password = user.password;

      if (email == null || password == null) {
        return ApiResponse<AuthModel>.error(
          "Email hoặc password không được để trống",
        );
      }

      // Tạo user trên Firebase → lấy uid
      final firebaseUid = await firebaseAuthService.createUserAndGetUid(
        email,
        password,
      );

      final updatedUser = RegisterModel(
        uid: firebaseUid,
        fullname: user.fullname,
        birthday: user.birthday,
        gender: user.gender,
        roleIds: user.roleIds,
        image: user.image,
      );

      final formData = await updatedUser.toFormData();

      final response = await apiClient.post<AuthModel>(
        Endpoints.register,
        data: formData,
        parser: (json) => AuthModel.fromJson(json as Map<String, dynamic>),
        headers: {'Content-Type': 'multipart/form-data'},
      );

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
        await sharedPreferencesService.create(
          StorageConstant.kUserInfoKey,
          auth.user,
        );
      }

      return response;
    } catch (e) {
      return ApiResponse<AuthModel>.error("Register failed: ${e.toString()}");
    }
  }

  @override
  Future<ApiResponse<AuthModel>> login(LoginModel loginModel) async {
    try {
      final idToken = await firebaseAuthService.signInAndGetToken(
        loginModel.email,
        loginModel.password,
      );

      final response = await apiClient.post<AuthModel>(
        Endpoints.login,
        data: {"idToken": idToken},
        parser: (json) => AuthModel.fromJson(json as Map<String, dynamic>),
      );

      // Persist token if success
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
        await sharedPreferencesService.create(
          StorageConstant.kUserInfoKey,
          auth.user,
        );
      }

      return response;
    } catch (e) {
      return ApiResponse<AuthModel>.error("Login failed: ${e.toString()}");
    }
  }

  @override
  Future<ApiResponse<String>> createNewAccessToken() async {
    try {
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

      // Update access token if success
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
    } catch (e) {
      return ApiResponse<String>.error("Token refresh failed: ${e.toString()}");
    }
  }

  @override
  Future<ApiResponse<void>> logout() async {
    try {
      await firebaseAuthService.signOut();
      await secureStorage.delete(StorageConstant.kAccessTokenKey);
      await secureStorage.delete(StorageConstant.kRefreshTokenKey);
      await sharedPreferencesService.delete(StorageConstant.kUserInfoKey);

      return ApiResponse<void>.success(null, message: "Logout success");
    } catch (e) {
      return ApiResponse<void>.error("Logout failed: ${e.toString()}");
    }
  }

  @override
  Future<ApiResponse<AuthModel>> getAuth() async {
    try {
      final idToken = await firebaseAuthService.getIdToken();
      final response = await apiClient.post<AuthModel>(
        Endpoints.login,
        data: {"idToken": idToken},
        parser: (json) => AuthModel.fromJson(json as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      return ApiResponse<AuthModel>.error("Get Auth: ${e.toString()}");
    }
  }
}

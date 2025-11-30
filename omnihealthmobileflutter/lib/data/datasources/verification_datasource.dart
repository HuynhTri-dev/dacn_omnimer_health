import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/data/models/auth/verification_model.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

/// Data source responsible for verification related API calls
abstract class VerificationDataSource {
  /// Get current user's verification status
  Future<ApiResponse<VerificationStatusModel>> getVerificationStatus();

  /// Send verification email to current user
  Future<ApiResponse<VerificationActionResponse>> sendVerificationEmail();

  /// Resend verification email to current user
  Future<ApiResponse<VerificationActionResponse>> resendVerificationEmail();

  /// Request to change email
  Future<ApiResponse<VerificationActionResponse>> requestChangeEmail(
    String newEmail,
  );
}

class VerificationDataSourceImpl implements VerificationDataSource {
  final ApiClient apiClient;

  VerificationDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<VerificationStatusModel>> getVerificationStatus() async {
    try {
      final response = await apiClient.get<VerificationStatusModel>(
        Endpoints.verificationStatus,
        parser: (json) =>
            VerificationStatusModel.fromJson(json as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      logger.e('Error getting verification status: $e');
      return ApiResponse<VerificationStatusModel>.error(
        "Failed to get verification status: ${e.toString()}",
      );
    }
  }

  // Email operations may take longer due to SMTP, use extended timeout
  static const _emailTimeout = Duration(seconds: 30);

  @override
  Future<ApiResponse<VerificationActionResponse>>
  sendVerificationEmail() async {
    try {
      final response = await apiClient.post<VerificationActionResponse>(
        Endpoints.sendVerificationEmail,
        data: {},
        parser: (json) =>
            VerificationActionResponse.fromJson(json as Map<String, dynamic>),
        receiveTimeout: _emailTimeout,
        sendTimeout: _emailTimeout,
      );

      return response;
    } catch (e) {
      logger.e('Error sending verification email: $e');
      return ApiResponse<VerificationActionResponse>.error(
        "Failed to send verification email: ${e.toString()}",
      );
    }
  }

  @override
  Future<ApiResponse<VerificationActionResponse>>
  resendVerificationEmail() async {
    try {
      final response = await apiClient.post<VerificationActionResponse>(
        Endpoints.resendVerificationEmail,
        data: {},
        parser: (json) =>
            VerificationActionResponse.fromJson(json as Map<String, dynamic>),
        receiveTimeout: _emailTimeout,
        sendTimeout: _emailTimeout,
      );

      return response;
    } catch (e) {
      logger.e('Error resending verification email: $e');
      return ApiResponse<VerificationActionResponse>.error(
        "Failed to resend verification email: ${e.toString()}",
      );
    }
  }

  @override
  Future<ApiResponse<VerificationActionResponse>> requestChangeEmail(
    String newEmail,
  ) async {
    try {
      final request = RequestChangeEmailModel(newEmail: newEmail);

      final response = await apiClient.post<VerificationActionResponse>(
        Endpoints.requestChangeEmail,
        data: request.toJson(),
        parser: (json) =>
            VerificationActionResponse.fromJson(json as Map<String, dynamic>),
        receiveTimeout: _emailTimeout,
        sendTimeout: _emailTimeout,
      );

      return response;
    } catch (e) {
      logger.e('Error requesting email change: $e');
      return ApiResponse<VerificationActionResponse>.error(
        "Failed to request email change: ${e.toString()}",
      );
    }
  }
}

import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_exception.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

/// Data source responsible for forgot password related API calls
abstract class ForgotPasswordDataSource {
  /// Request password reset - sends OTP code to email
  /// Returns ApiResponse with success status and requireEmailVerification flag
  Future<ApiResponse<ForgotPasswordRequestResponse>> requestPasswordReset(
      String email);

  /// Verify OTP code and get reset token
  Future<ApiResponse<String>> verifyResetCode(String email, String code);

  /// Reset password using reset token
  Future<ApiResponse<void>> resetPassword(String resetToken, String newPassword);

  /// Resend OTP code
  Future<ApiResponse<ForgotPasswordRequestResponse>> resendResetCode(
      String email);
}

class ForgotPasswordDataSourceImpl implements ForgotPasswordDataSource {
  final ApiClient apiClient;

  ForgotPasswordDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<ForgotPasswordRequestResponse>> requestPasswordReset(
      String email) async {
    try {
      final response = await apiClient.post<ForgotPasswordRequestResponse>(
        Endpoints.forgotPasswordRequest,
        data: {'email': email},
        parser: (json) =>
            ForgotPasswordRequestResponse.fromJson(json as Map<String, dynamic>),
        requiresAuth: false,
      );
      return response;
    } on ApiException catch (e) {
      logger.e('Request password reset error: $e');
      // Check if it's email verification required error (403)
      if (e.statusCode == 403) {
        return ApiResponse<ForgotPasswordRequestResponse>.success(
          ForgotPasswordRequestResponse(
            success: false,
            requireEmailVerification: true,
          ),
          message: e.message,
        );
      }
      return ApiResponse<ForgotPasswordRequestResponse>.error(e.message);
    } catch (e) {
      logger.e('Request password reset error: $e');
      return ApiResponse<ForgotPasswordRequestResponse>.error(
        'Có lỗi xảy ra. Vui lòng thử lại.',
      );
    }
  }

  @override
  Future<ApiResponse<String>> verifyResetCode(
      String email, String code) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        Endpoints.forgotPasswordVerifyCode,
        data: {'email': email, 'code': code},
        parser: (json) => json as Map<String, dynamic>,
        requiresAuth: false,
      );

      if (response.success && response.data != null) {
        final resetToken = response.data!['resetToken'] as String?;
        if (resetToken != null) {
          return ApiResponse<String>.success(resetToken,
              message: response.message.isNotEmpty
                  ? response.message
                  : 'Mã xác thực hợp lệ');
        }
      }

      return ApiResponse<String>.error(response.message.isNotEmpty
          ? response.message
          : 'Mã xác thực không hợp lệ');
    } on ApiException catch (e) {
      logger.e('Verify reset code error: $e');
      return ApiResponse<String>.error(e.message);
    } catch (e) {
      logger.e('Verify reset code error: $e');
      return ApiResponse<String>.error('Có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  @override
  Future<ApiResponse<void>> resetPassword(
      String resetToken, String newPassword) async {
    try {
      final response = await apiClient.post<void>(
        Endpoints.forgotPasswordReset,
        data: {'resetToken': resetToken, 'newPassword': newPassword},
        parser: (_) => null,
        requiresAuth: false,
      );
      return response;
    } on ApiException catch (e) {
      logger.e('Reset password error: $e');
      return ApiResponse<void>.error(e.message);
    } catch (e) {
      logger.e('Reset password error: $e');
      return ApiResponse<void>.error('Có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  @override
  Future<ApiResponse<ForgotPasswordRequestResponse>> resendResetCode(
      String email) async {
    try {
      final response = await apiClient.post<ForgotPasswordRequestResponse>(
        Endpoints.forgotPasswordResendCode,
        data: {'email': email},
        parser: (json) =>
            ForgotPasswordRequestResponse.fromJson(json as Map<String, dynamic>),
        requiresAuth: false,
      );
      return response;
    } on ApiException catch (e) {
      logger.e('Resend reset code error: $e');
      if (e.statusCode == 403) {
        return ApiResponse<ForgotPasswordRequestResponse>.success(
          ForgotPasswordRequestResponse(
            success: false,
            requireEmailVerification: true,
          ),
          message: e.message,
        );
      }
      return ApiResponse<ForgotPasswordRequestResponse>.error(e.message);
    } catch (e) {
      logger.e('Resend reset code error: $e');
      return ApiResponse<ForgotPasswordRequestResponse>.error(
        'Có lỗi xảy ra. Vui lòng thử lại.',
      );
    }
  }
}

/// Response model for forgot password request
class ForgotPasswordRequestResponse {
  final bool success;
  final bool requireEmailVerification;

  ForgotPasswordRequestResponse({
    required this.success,
    this.requireEmailVerification = false,
  });

  factory ForgotPasswordRequestResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequestResponse(
      success: json['success'] as bool? ?? true,
      requireEmailVerification:
          json['requireEmailVerification'] as bool? ?? false,
    );
  }
}


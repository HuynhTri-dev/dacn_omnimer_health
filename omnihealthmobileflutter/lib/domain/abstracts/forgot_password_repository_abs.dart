import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/forgot_password_datasource.dart';

/// Abstract repository for forgot password operations
abstract class ForgotPasswordRepositoryAbs {
  /// Request password reset - sends OTP code to email
  /// Returns success status and whether email verification is required
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


import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/verification_status_entity.dart';

/// Abstract repository for verification operations
abstract class VerificationRepositoryAbs {
  /// Get verification status of current user
  Future<ApiResponse<VerificationStatusEntity>> getVerificationStatus();

  /// Send verification email to current user
  Future<ApiResponse<String>> sendVerificationEmail();

  /// Resend verification email to current user
  Future<ApiResponse<String>> resendVerificationEmail();

  /// Request to change email address
  Future<ApiResponse<String>> requestChangeEmail(String newEmail);
}


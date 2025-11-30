import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/forgot_password_repository_abs.dart';

/// Use case for resetting password with reset token
class ResetPasswordUseCase {
  final ForgotPasswordRepositoryAbs repository;

  ResetPasswordUseCase(this.repository);

  Future<ApiResponse<void>> call(String resetToken, String newPassword) {
    return repository.resetPassword(resetToken, newPassword);
  }
}


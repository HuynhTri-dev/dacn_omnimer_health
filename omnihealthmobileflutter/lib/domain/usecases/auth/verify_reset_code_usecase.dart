import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/forgot_password_repository_abs.dart';

/// Use case for verifying reset code
/// Returns reset token on success
class VerifyResetCodeUseCase {
  final ForgotPasswordRepositoryAbs repository;

  VerifyResetCodeUseCase(this.repository);

  Future<ApiResponse<String>> call(String email, String code) {
    return repository.verifyResetCode(email, code);
  }
}


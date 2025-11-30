import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/forgot_password_datasource.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/forgot_password_repository_abs.dart';

/// Use case for requesting password reset
/// Sends OTP code to user's email
class RequestPasswordResetUseCase {
  final ForgotPasswordRepositoryAbs repository;

  RequestPasswordResetUseCase(this.repository);

  Future<ApiResponse<ForgotPasswordRequestResponse>> call(String email) {
    return repository.requestPasswordReset(email);
  }
}


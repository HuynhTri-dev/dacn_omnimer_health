import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/forgot_password_datasource.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/forgot_password_repository_abs.dart';

/// Use case for resending reset code
class ResendResetCodeUseCase {
  final ForgotPasswordRepositoryAbs repository;

  ResendResetCodeUseCase(this.repository);

  Future<ApiResponse<ForgotPasswordRequestResponse>> call(String email) {
    return repository.resendResetCode(email);
  }
}


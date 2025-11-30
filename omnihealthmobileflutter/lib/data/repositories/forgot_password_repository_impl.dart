import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/forgot_password_datasource.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/forgot_password_repository_abs.dart';

/// Implementation of ForgotPasswordRepositoryAbs
class ForgotPasswordRepositoryImpl implements ForgotPasswordRepositoryAbs {
  final ForgotPasswordDataSource dataSource;

  ForgotPasswordRepositoryImpl({required this.dataSource});

  @override
  Future<ApiResponse<ForgotPasswordRequestResponse>> requestPasswordReset(
      String email) {
    return dataSource.requestPasswordReset(email);
  }

  @override
  Future<ApiResponse<String>> verifyResetCode(String email, String code) {
    return dataSource.verifyResetCode(email, code);
  }

  @override
  Future<ApiResponse<void>> resetPassword(
      String resetToken, String newPassword) {
    return dataSource.resetPassword(resetToken, newPassword);
  }

  @override
  Future<ApiResponse<ForgotPasswordRequestResponse>> resendResetCode(
      String email) {
    return dataSource.resendResetCode(email);
  }
}


import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/verification_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

/// UseCase to resend verification email to current user
class ResendVerificationEmailUseCase
    implements UseCase<ApiResponse<String>, NoParams> {
  final VerificationRepositoryAbs repository;

  ResendVerificationEmailUseCase(this.repository);

  @override
  Future<ApiResponse<String>> call(NoParams params) {
    return repository.resendVerificationEmail();
  }
}


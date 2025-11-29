import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/verification_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

/// UseCase to send verification email to current user
class SendVerificationEmailUseCase
    implements UseCase<ApiResponse<String>, NoParams> {
  final VerificationRepositoryAbs repository;

  SendVerificationEmailUseCase(this.repository);

  @override
  Future<ApiResponse<String>> call(NoParams params) {
    return repository.sendVerificationEmail();
  }
}


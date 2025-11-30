import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/verification_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

/// Parameters for RequestChangeEmailUseCase
class RequestChangeEmailParams {
  final String newEmail;

  const RequestChangeEmailParams({required this.newEmail});
}

/// UseCase to request email change
class RequestChangeEmailUseCase
    implements UseCase<ApiResponse<String>, RequestChangeEmailParams> {
  final VerificationRepositoryAbs repository;

  RequestChangeEmailUseCase(this.repository);

  @override
  Future<ApiResponse<String>> call(RequestChangeEmailParams params) {
    return repository.requestChangeEmail(params.newEmail);
  }
}


import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/verification_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/verification_status_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

/// UseCase to get the current user's verification status
class GetVerificationStatusUseCase
    implements UseCase<ApiResponse<VerificationStatusEntity>, NoParams> {
  final VerificationRepositoryAbs repository;

  GetVerificationStatusUseCase(this.repository);

  @override
  Future<ApiResponse<VerificationStatusEntity>> call(NoParams params) {
    return repository.getVerificationStatus();
  }
}


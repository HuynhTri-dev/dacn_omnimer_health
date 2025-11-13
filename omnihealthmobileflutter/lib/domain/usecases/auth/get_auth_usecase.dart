import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth_entity.dart';
import '../base_usecase.dart';

/// Retrieves the currently authenticated user (cached or remote)
class GetAuthUseCase implements UseCase<ApiResponse<AuthEntity>, NoParams> {
  final AuthRepositoryAbs repository;

  GetAuthUseCase(this.repository);

  @override
  Future<ApiResponse<AuthEntity>> call(NoParams params) async {
    return await repository.getAuth();
  }
}

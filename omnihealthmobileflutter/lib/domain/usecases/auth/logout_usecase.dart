import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import '../base_usecase.dart';

/// Handles logout process (clearing tokens, server logout, etc.)
class LogoutUseCase implements UseCase<ApiResponse<void>, NoParams> {
  final AuthRepositoryAbs repository;

  LogoutUseCase(this.repository);

  @override
  Future<ApiResponse<void>> call(NoParams params) async {
    return await repository.logout();
  }
}

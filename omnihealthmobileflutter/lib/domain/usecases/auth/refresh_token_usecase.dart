import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import '../base_usecase.dart';

/// Handles refresh token to get new access token
class RefreshTokenUseCase implements UseCase<ApiResponse<String>, NoParams> {
  final AuthRepositoryAbs repository;

  RefreshTokenUseCase(this.repository);

  @override
  Future<ApiResponse<String>> call(NoParams params) async {
    return await repository.createNewAccessToken();
  }
}

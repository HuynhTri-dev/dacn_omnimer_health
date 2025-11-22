import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/auth_entity.dart';
import '../base_usecase.dart';

/// Handles user login business logic
class LoginUseCase implements UseCase<ApiResponse<AuthEntity>, LoginEntity> {
  final AuthRepositoryAbs repository;

  LoginUseCase(this.repository);

  @override
  Future<ApiResponse<AuthEntity>> call(LoginEntity params) async {
    // You could add additional logic here (e.g. validate email/password)
    return await repository.login(params);
  }
}

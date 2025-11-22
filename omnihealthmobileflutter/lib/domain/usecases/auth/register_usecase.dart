import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/auth_entity.dart';
import '../base_usecase.dart';

/// Handles user registration logic
class RegisterUseCase
    implements UseCase<ApiResponse<AuthEntity>, RegisterEntity> {
  final AuthRepositoryAbs repository;

  RegisterUseCase(this.repository);

  @override
  Future<ApiResponse<AuthEntity>> call(RegisterEntity params) async {
    // Additional business validation (e.g. password strength) can go here
    return await repository.register(params);
  }
}

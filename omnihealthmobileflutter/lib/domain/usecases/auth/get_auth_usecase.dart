import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth_entity.dart';
import '../base_usecase.dart';

class GetAuthUseCase implements UseCase<ApiResponse<UserAuth>, NoParams> {
  final AuthRepositoryAbs repository;

  GetAuthUseCase(this.repository);

  @override
  Future<ApiResponse<UserAuth>> call(NoParams params) async {
    return await repository.getAuth();
  }
}

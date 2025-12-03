import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/user_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

class ToggleDataSharingUseCase
    implements UseCase<ApiResponse<UserEntity>, NoParams> {
  final AuthRepositoryAbs repository;

  ToggleDataSharingUseCase(this.repository);

  @override
  Future<ApiResponse<UserEntity>> call(NoParams params) async {
    return await repository.toggleDataSharing();
  }
}

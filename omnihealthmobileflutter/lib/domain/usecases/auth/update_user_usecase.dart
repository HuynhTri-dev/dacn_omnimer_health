import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/user_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';

class UpdateUserParams extends Equatable {
  final String id;
  final UserEntity user;

  const UpdateUserParams({required this.id, required this.user});

  @override
  List<Object?> get props => [id, user];
}

class UpdateUserUseCase
    extends UseCase<ApiResponse<UserEntity>, UpdateUserParams> {
  final AuthRepositoryAbs repository;

  UpdateUserUseCase(this.repository);

  @override
  Future<ApiResponse<UserEntity>> call(UpdateUserParams params) async {
    return await repository.updateUser(params.id, params.user);
  }
}

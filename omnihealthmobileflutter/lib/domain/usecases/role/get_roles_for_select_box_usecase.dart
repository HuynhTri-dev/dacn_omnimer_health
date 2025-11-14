import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/role_repositoy_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/role_entity.dart';
import '../base_usecase.dart';

class GetRolesForSelectBoxUseCase
    implements UseCase<ApiResponse<List<RoleSelectBoxEntity>>, NoParams> {
  final RoleRepositoryAbs repository;

  GetRolesForSelectBoxUseCase(this.repository);

  @override
  Future<ApiResponse<List<RoleSelectBoxEntity>>> call(NoParams params) async {
    return await repository.getRolesForSelectBox();
  }
}

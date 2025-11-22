import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/body_part_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/body_part_entity.dart';
import '../base_usecase.dart';

class GetAllBodyPartsUseCase
    implements UseCase<ApiResponse<List<BodyPartEntity>>, NoParams> {
  final BodyPartRepositoryAbs repository;

  GetAllBodyPartsUseCase(this.repository);

  @override
  Future<ApiResponse<List<BodyPartEntity>>> call(NoParams params) async {
    return await repository.getAllBodyParts();
  }
}

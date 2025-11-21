import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/equipment_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/equipment_entity.dart';
import '../base_usecase.dart';

class GetAllEquipmentsUseCase
    implements UseCase<ApiResponse<List<EquipmentEntity>>, NoParams> {
  final EquipmentRepositoryAbs repository;

  GetAllEquipmentsUseCase(this.repository);

  @override
  Future<ApiResponse<List<EquipmentEntity>>> call(NoParams params) async {
    return await repository.getAllEquipments();
  }
}

import 'package:omnihealthmobileflutter/data/datasources/health_profile_remote_datasource.dart';
import 'package:omnihealthmobileflutter/data/models/health_profile/health_profile_model.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';


class HealthProfileRepositoryImpl implements HealthProfileRepository {
  final HealthProfileRemoteDataSource remoteDataSource;

  HealthProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HealthProfile>> getHealthProfiles() async {
    final models = await remoteDataSource.getHealthProfiles();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<HealthProfile> getHealthProfileById(String id) async {
    final model = await remoteDataSource.getHealthProfileById(id);
    return model.toEntity();
  }

  @override
  Future<HealthProfile> getLatestHealthProfile() async {
    final model = await remoteDataSource.getLatestHealthProfile();
    return model.toEntity();
  }

  @override
  Future<List<HealthProfile>> getHealthProfilesByUserId(String userId) async {
    final models = await remoteDataSource.getHealthProfilesByUserId(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<HealthProfile> createHealthProfile(HealthProfile profile) async {
    final model = HealthProfileModel.fromEntity(profile);
    final result = await remoteDataSource.createHealthProfile(model);
    return result.toEntity();
  }

  @override
  Future<HealthProfile> updateHealthProfile(String id, HealthProfile profile) async {
    final model = HealthProfileModel.fromEntity(profile);
    final result = await remoteDataSource.updateHealthProfile(id, model);
    return result.toEntity();
  }

  @override
  Future<void> deleteHealthProfile(String id) async {
    await remoteDataSource.deleteHealthProfile(id);
  }
}
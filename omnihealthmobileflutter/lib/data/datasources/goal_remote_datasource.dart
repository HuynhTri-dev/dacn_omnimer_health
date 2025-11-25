import 'package:dio/dio.dart';
import 'package:omnihealthmobileflutter/data/models/health_profile/goal/goal_model.dart';

abstract class GoalRemoteDataSource {
  Future<List<GoalModel>> getGoalsByUserId(String userId);
  Future<GoalModel> createGoal(GoalModel goal);
  Future<GoalModel> updateGoal(GoalModel goal);
  Future<void> deleteGoal(String goalId);
}

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  final Dio _dio;

  GoalRemoteDataSourceImpl(this._dio);

  @override
  Future<List<GoalModel>> getGoalsByUserId(String userId) async {
    final response = await _dio.get('/goals', queryParameters: {'userId': userId});
    final List data = response.data['data'] as List;
    return data.map((json) => GoalModel.fromJson(json)).toList();
  }

  @override
  Future<GoalModel> createGoal(GoalModel goal) async {
    final response = await _dio.post('/goals', data: goal.toJson());
    return GoalModel.fromJson(response.data['data']);
  }

  @override
  Future<GoalModel> updateGoal(GoalModel goal) async {
    final response = await _dio.put('/goals/${goal.id}', data: goal.toJson());
    return GoalModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await _dio.delete('/goals/$goalId');
  }
}
import 'package:dio/dio.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_model.dart';
import 'package:omnihealthmobileflutter/data/models/muscle/muscle_model.dart';

class ExerciseRepository {
  final Dio dio;

  ExerciseRepository(this.dio);

  Future<List<ExerciseModel>> getExercises() async {
    final res = await dio.get('/v1/exercise');

    final body = res.data as Map<String, dynamic>;
    final list = body['data'] as List<dynamic>;

    return list
        .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MuscleModel>> getMuscles() async {
    final res = await dio.get('/v1/muscle');

    final body = res.data as Map<String, dynamic>;
    final list = body['data'] as List<dynamic>;

    return list
        .map((e) => MuscleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> rateExercise({
    required String exerciseId,
    required double score,
  }) async {
    // Với baseUrl = API_BASE_URL + "/api",
    // '/v1/exercise-rating' => gọi tới /api/v1/exercise-rating ✅
    await dio.post(
      '/v1/exercise-rating',
      data: {'exerciseId': exerciseId, 'score': score},
    );
  }
}

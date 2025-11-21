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
    await dio.post(
      '/v1/exercise-rating',
      data: {'exerciseId': exerciseId, 'score': score},
    );
  }

  Future<double?> getExerciseRatingFromServer(String exerciseId) async {
    final res = await dio.get(
      '/v1/exercise-rating',
      queryParameters: {'filter': 'exerciseId:$exerciseId'},
    );

    final body = res.data as Map<String, dynamic>;
    final list = body['data'] as List<dynamic>;

    if (list.isEmpty) return null;

    final ratings = list
        .whereType<Map<String, dynamic>>()
        .where((e) => e['exerciseId'] == exerciseId)
        .toList();

    if (ratings.isEmpty) return null;

    double total = 0;
    int count = 0;

    for (final item in ratings) {
      final score = item['score'];
      if (score != null) {
        total += (score as num).toDouble();
        count++;
      }
    }

    if (count == 0) return null;

    final avg = total / count;
    return avg;
  }
}

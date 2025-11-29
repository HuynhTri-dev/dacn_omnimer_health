import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_log_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/active_workout_session_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_entity.dart';

/// Use case to save completed workout session as a workout log
class SaveWorkoutLogUseCase {
  final WorkoutLogRepositoryAbs repository;

  SaveWorkoutLogUseCase({required this.repository});

  Future<ApiResponse<WorkoutLogEntity>> call(
    ActiveWorkoutSessionEntity session,
    Duration elapsedTime,
  ) async {
    // Convert active session to workout log data (matching server schema)
    final data = _convertSessionToLogData(session, elapsedTime);
    return repository.createWorkoutLog(data);
  }

  Map<String, dynamic> _convertSessionToLogData(
    ActiveWorkoutSessionEntity session,
    Duration elapsedTime,
  ) {
    // Calculate summary
    int totalSets = 0;
    int totalReps = 0;
    double totalWeight = 0;

    for (final exercise in session.exercises) {
      for (final set in exercise.sets) {
        if (set.isCompleted) {
          totalSets++;
          totalReps += set.actualReps ?? 0;
          totalWeight += (set.actualWeight ?? 0) * (set.actualReps ?? 0);
        }
      }
    }

    return {
      if (session.templateId != null) 'workoutTemplateId': session.templateId,
      'timeStart': session.startedAt.toIso8601String(),
      'notes': 'Completed via app',
      // Format workoutDetail according to server schema
      'workoutDetail': session.exercises.map((exercise) {
        return {
          'exerciseId': exercise.exerciseId,
          'type': exercise.type,
          'sets': exercise.sets.map((set) {
            return {
              'setOrder': set.setOrder,
              if (set.actualReps != null) 'reps': set.actualReps,
              if (set.actualWeight != null) 'weight': set.actualWeight,
              if (set.actualDuration != null) 'duration': set.actualDuration,
              if (set.actualDistance != null) 'distance': set.actualDistance,
              if (set.restAfterSetSeconds != null)
                'restAfterSetSeconds': set.restAfterSetSeconds,
              'done': set.isCompleted,
            };
          }).toList(),
        };
      }).toList(),
      'summary': {
        'totalSets': totalSets,
        'totalReps': totalReps,
        'totalWeight': totalWeight.round(),
        'totalDuration': elapsedTime.inSeconds,
      },
    };
  }
}

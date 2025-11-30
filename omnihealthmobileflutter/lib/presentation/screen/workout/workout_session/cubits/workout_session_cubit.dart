import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/active_workout_session_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_connect_repository.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_log_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/save_workout_log_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_session/cubits/workout_session_state.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

class WorkoutSessionCubit extends Cubit<WorkoutSessionState> {
  Timer? _timer;
  Timer? _restTimer;
  final SaveWorkoutLogUseCase? saveWorkoutLogUseCase;
  final WorkoutLogRepositoryAbs? workoutLogRepository;
  final HealthConnectRepository? healthConnectRepository;

  WorkoutSessionCubit({
    this.saveWorkoutLogUseCase,
    this.workoutLogRepository,
    this.healthConnectRepository,
  }) : super(const WorkoutSessionState());

  /// Start a workout session from a template
  Future<void> startWorkout(WorkoutTemplateEntity template) async {
    var session = ActiveWorkoutSessionEntity.fromTemplate(template);

    // Create workout on server if repository is available
    if (workoutLogRepository != null) {
      try {
        final response = await workoutLogRepository!.createWorkoutFromTemplate(
          template.id,
        );
        if (response.success && response.data != null) {
          final createdWorkout = response.data!;

          // Map server IDs to local session exercises
          // We assume the order is preserved
          List<ActiveExerciseEntity> updatedExercises = [];

          if (createdWorkout.exercises.length == session.exercises.length) {
            for (int i = 0; i < session.exercises.length; i++) {
              final localEx = session.exercises[i];
              final serverEx = createdWorkout.exercises[i];

              // Verify matching exerciseId to be safe
              if (localEx.exerciseId == serverEx.exerciseId) {
                // Map sets IDs
                List<ActiveSetEntity> updatedSets = [];
                if (localEx.sets.length == serverEx.sets.length) {
                  for (int j = 0; j < localEx.sets.length; j++) {
                    updatedSets.add(
                      localEx.sets[j].copyWith(id: serverEx.sets[j].id),
                    );
                  }
                } else {
                  updatedSets = localEx.sets;
                  logger.w(
                    '[WorkoutSessionCubit] Set count mismatch at exercise $i',
                  );
                }

                updatedExercises.add(
                  localEx.copyWith(id: serverEx.id, sets: updatedSets),
                );
              } else {
                updatedExercises.add(localEx);
                logger.w('[WorkoutSessionCubit] Exercise mismatch at index $i');
              }
            }
          } else {
            updatedExercises = session.exercises;
            logger.w('[WorkoutSessionCubit] Exercise count mismatch');
          }

          session = session.copyWith(
            workoutId: createdWorkout.id,
            exercises: updatedExercises,
          );

          logger.i(
            '[WorkoutSessionCubit] Created workout on server: ${createdWorkout.id}',
          );

          // Call Start Workout API
          if (createdWorkout.id != null) {
            await workoutLogRepository!.startWorkout(createdWorkout.id!);
            logger.i('[WorkoutSessionCubit] Started workout on server');
          }
        } else {
          logger.e(
            '[WorkoutSessionCubit] Failed to create workout on server: ${response.message}',
          );
        }
      } catch (e) {
        logger.e('[WorkoutSessionCubit] Error creating workout on server: $e');
      }
    }

    // Find the first uncompleted set
    final (exerciseIndex, setIndex) = _findFirstUncompletedSet(session);

    // Start Health Connect Session
    if (healthConnectRepository != null) {
      try {
        await healthConnectRepository!.startWorkoutSession(
          workoutType: template.name,
        );
      } catch (e) {
        logger.e(
          '[WorkoutSessionCubit] Error starting Health Connect session: $e',
        );
      }
    }

    emit(
      state.copyWith(
        status: WorkoutSessionStatus.active,
        session: session,
        currentExerciseIndex: exerciseIndex,
        currentSetIndex: setIndex,
        elapsedTime: Duration.zero,
        isTimerRunning: true,
        exerciseStartTime: DateTime.now(), // Track start time of first exercise
      ),
    );

    _startTimer();
  }

  /// Find the first uncompleted set
  (int?, int?) _findFirstUncompletedSet(ActiveWorkoutSessionEntity session) {
    for (int i = 0; i < session.exercises.length; i++) {
      final exercise = session.exercises[i];
      for (int j = 0; j < exercise.sets.length; j++) {
        if (!exercise.sets[j].isCompleted) {
          return (i, j);
        }
      }
    }
    return (null, null); // All sets completed
  }

  /// Update current set indicator
  void _updateCurrentSet() {
    if (state.session == null) return;

    final oldExerciseIndex = state.currentExerciseIndex;
    final (newExerciseIndex, newSetIndex) = _findFirstUncompletedSet(
      state.session!,
    );

    // Check if we finished an exercise (moved to next or all done)
    if (oldExerciseIndex != null &&
        (newExerciseIndex == null || newExerciseIndex != oldExerciseIndex)) {
      // Check if the old exercise is actually completed
      final oldExercise = state.session!.exercises[oldExerciseIndex];

      // User Request: When done all reps of an exerciseId, run completeExercise and health connect data
      if (oldExercise.isCompleted) {
        logger.i(
          '[WorkoutSessionCubit] Exercise ${oldExercise.exerciseId} completed (all reps done). Triggering sync and completion.',
        );
        _finishExercise(oldExerciseIndex);
      }
    }

    // Check if all sets are completed
    if (newExerciseIndex == null && newSetIndex == null) {
      // All sets completed - stop the timer
      emit(
        state.copyWith(
          currentExerciseIndex: null,
          currentSetIndex: null,
          isTimerRunning: false,
          clearCurrentSet: true,
        ),
      );
    } else {
      // If starting a new exercise, update start time
      DateTime? newStartTime = state.exerciseStartTime;
      if (newExerciseIndex != oldExerciseIndex) {
        newStartTime = DateTime.now();
        logger.i(
          '[WorkoutSessionCubit] Starting new exercise index: $newExerciseIndex at $newStartTime',
        );
      }

      emit(
        state.copyWith(
          currentExerciseIndex: newExerciseIndex,
          currentSetIndex: newSetIndex,
          exerciseStartTime: newStartTime,
        ),
      );
    }
  }

  /// Start the elapsed time timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isTimerRunning) {
        emit(
          state.copyWith(
            elapsedTime: state.elapsedTime + const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  /// Pause the workout
  void pauseWorkout() {
    emit(
      state.copyWith(
        status: WorkoutSessionStatus.paused,
        isTimerRunning: false,
      ),
    );
  }

  /// Resume the workout
  void resumeWorkout() {
    emit(
      state.copyWith(status: WorkoutSessionStatus.active, isTimerRunning: true),
    );
  }

  /// Toggle exercise expansion
  void toggleExerciseExpansion(int exerciseIndex) {
    if (state.session == null) return;

    final exercises = List<ActiveExerciseEntity>.from(state.session!.exercises);
    exercises[exerciseIndex] = exercises[exerciseIndex].copyWith(
      isExpanded: !exercises[exerciseIndex].isExpanded,
    );

    emit(
      state.copyWith(session: state.session!.copyWith(exercises: exercises)),
    );
  }

  /// Toggle set completion
  void toggleSetCompletion(int exerciseIndex, int setIndex) {
    if (state.session == null) return;

    final exercises = List<ActiveExerciseEntity>.from(state.session!.exercises);
    final exercise = exercises[exerciseIndex];
    final sets = List<ActiveSetEntity>.from(exercise.sets);
    final currentSet = sets[setIndex];
    final isCompleting = !currentSet.isCompleted;

    sets[setIndex] = currentSet.copyWith(
      isCompleted: isCompleting,
      completedAt: isCompleting ? DateTime.now() : null,
    );

    exercises[exerciseIndex] = exercise.copyWith(sets: sets);

    emit(
      state.copyWith(session: state.session!.copyWith(exercises: exercises)),
    );

    // Start rest timer if completing a set with rest time
    if (isCompleting &&
        currentSet.restAfterSetSeconds != null &&
        currentSet.restAfterSetSeconds! > 0) {
      // Check if there's a next set (not the last set of all exercises)
      final hasNextSet = _hasNextUncompletedSet(exerciseIndex, setIndex);
      if (hasNextSet) {
        _startRestTimer(
          exerciseIndex,
          setIndex,
          currentSet.restAfterSetSeconds!,
        );
      }
    } else if (!isCompleting) {
      // If uncompleting a set, cancel rest timer if active for this set
      if (state.isResting &&
          state.restExerciseIndex == exerciseIndex &&
          state.restSetIndex == setIndex) {
        skipRestTimer();
      }
    }

    // Update current set indicator
    _updateCurrentSet();

    // Call API to complete set if completing
    if (isCompleting &&
        workoutLogRepository != null &&
        state.session?.workoutId != null) {
      final exerciseId = exercise.id;
      final setId = currentSet.id;

      if (exerciseId != null && setId != null) {
        workoutLogRepository!.completeSet(state.session!.workoutId!, {
          'workoutDetailId': exerciseId,
          'workoutSetId': setId,
        });
      } else {
        logger.w(
          '[WorkoutSessionCubit] Cannot complete set on server: Missing IDs (detail: $exerciseId, set: $setId)',
        );
      }
    }
  }

  /// Check if there's a next uncompleted set after the given position
  bool _hasNextUncompletedSet(int exerciseIndex, int setIndex) {
    if (state.session == null) return false;

    // Check remaining sets in current exercise
    final exercise = state.session!.exercises[exerciseIndex];
    for (int j = setIndex + 1; j < exercise.sets.length; j++) {
      if (!exercise.sets[j].isCompleted) return true;
    }

    // Check next exercises
    for (int i = exerciseIndex + 1; i < state.session!.exercises.length; i++) {
      for (int j = 0; j < state.session!.exercises[i].sets.length; j++) {
        if (!state.session!.exercises[i].sets[j].isCompleted) return true;
      }
    }

    return false;
  }

  /// Start rest timer
  void _startRestTimer(int exerciseIndex, int setIndex, int seconds) {
    _restTimer?.cancel();

    emit(
      state.copyWith(
        isResting: true,
        restTimeRemaining: seconds,
        restExerciseIndex: exerciseIndex,
        restSetIndex: setIndex,
      ),
    );

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.restTimeRemaining > 0) {
        emit(state.copyWith(restTimeRemaining: state.restTimeRemaining - 1));
      } else {
        // Rest complete
        _restTimer?.cancel();
        emit(state.copyWith(clearRest: true));
      }
    });
  }

  /// Skip rest timer
  void skipRestTimer() {
    _restTimer?.cancel();
    emit(state.copyWith(clearRest: true));
  }

  /// Add time to rest timer
  void addRestTime(int seconds) {
    if (state.isResting) {
      emit(
        state.copyWith(restTimeRemaining: state.restTimeRemaining + seconds),
      );
    }
  }

  /// Update set weight
  void updateSetWeight(int exerciseIndex, int setIndex, double weight) {
    if (state.session == null) return;

    final exercises = List<ActiveExerciseEntity>.from(state.session!.exercises);
    final exercise = exercises[exerciseIndex];
    final sets = List<ActiveSetEntity>.from(exercise.sets);

    sets[setIndex] = sets[setIndex].copyWith(actualWeight: weight);
    exercises[exerciseIndex] = exercise.copyWith(sets: sets);

    emit(
      state.copyWith(session: state.session!.copyWith(exercises: exercises)),
    );
  }

  /// Update set reps
  void updateSetReps(int exerciseIndex, int setIndex, int reps) {
    if (state.session == null) return;

    final exercises = List<ActiveExerciseEntity>.from(state.session!.exercises);
    final exercise = exercises[exerciseIndex];
    final sets = List<ActiveSetEntity>.from(exercise.sets);

    sets[setIndex] = sets[setIndex].copyWith(actualReps: reps);
    exercises[exerciseIndex] = exercise.copyWith(sets: sets);

    emit(
      state.copyWith(session: state.session!.copyWith(exercises: exercises)),
    );
  }

  /// Add a new set to an exercise
  void addSet(int exerciseIndex) {
    if (state.session == null) return;

    final exercises = List<ActiveExerciseEntity>.from(state.session!.exercises);
    final exercise = exercises[exerciseIndex];
    final sets = List<ActiveSetEntity>.from(exercise.sets);

    // Copy values from the last set if available
    final lastSet = sets.isNotEmpty ? sets.last : null;

    sets.add(
      ActiveSetEntity(
        setOrder: sets.length + 1,
        targetReps: lastSet?.targetReps,
        targetWeight: lastSet?.targetWeight,
        actualReps: lastSet?.actualReps,
        actualWeight: lastSet?.actualWeight,
      ),
    );

    exercises[exerciseIndex] = exercise.copyWith(sets: sets);

    emit(
      state.copyWith(session: state.session!.copyWith(exercises: exercises)),
    );

    // Update current set indicator (in case timer was stopped)
    _updateCurrentSet();
  }

  /// Remove a set from an exercise
  void removeSet(int exerciseIndex, int setIndex) {
    if (state.session == null) return;

    final exercises = List<ActiveExerciseEntity>.from(state.session!.exercises);
    final exercise = exercises[exerciseIndex];
    final sets = List<ActiveSetEntity>.from(exercise.sets);

    if (sets.length <= 1) return; // Keep at least one set

    sets.removeAt(setIndex);

    // Reorder set numbers
    for (int i = 0; i < sets.length; i++) {
      sets[i] = sets[i].copyWith(setOrder: i + 1);
    }

    exercises[exerciseIndex] = exercise.copyWith(sets: sets);

    emit(
      state.copyWith(session: state.session!.copyWith(exercises: exercises)),
    );
  }

  /// Log the next uncompleted set
  void logNextSet() {
    if (state.session == null) return;

    // Find the first uncompleted set
    for (int i = 0; i < state.session!.exercises.length; i++) {
      final exercise = state.session!.exercises[i];
      for (int j = 0; j < exercise.sets.length; j++) {
        if (!exercise.sets[j].isCompleted) {
          toggleSetCompletion(i, j);
          return;
        }
      }
    }
  }

  /// Complete all sets
  void completeAllSets() {
    if (state.session == null) return;

    final exercises = state.session!.exercises.map((exercise) {
      final sets = exercise.sets.map((set) {
        return set.copyWith(isCompleted: true, completedAt: DateTime.now());
      }).toList();
      return exercise.copyWith(sets: sets);
    }).toList();

    emit(
      state.copyWith(
        session: state.session!.copyWith(exercises: exercises),
        currentExerciseIndex: null,
        currentSetIndex: null,
        isTimerRunning: false,
        clearCurrentSet: true,
      ),
    );
  }

  /// Finish the workout and save to database
  Future<void> finishWorkout() async {
    _timer?.cancel();
    _restTimer?.cancel();

    // Stop Health Connect Session
    if (healthConnectRepository != null && state.session?.workoutId != null) {
      try {
        await healthConnectRepository!.stopWorkoutSession(
          state.session!.workoutId!,
        );
      } catch (e) {
        logger.e(
          '[WorkoutSessionCubit] Error stopping Health Connect session: $e',
        );
      }
    }

    // Save workout log to database
    if (state.session != null) {
      try {
        if (state.session!.workoutId != null && workoutLogRepository != null) {
          // Online flow: Finish existing workout
          logger.i(
            '[WorkoutSessionCubit] Finishing workout ${state.session!.workoutId} on server...',
          );
          final response = await workoutLogRepository!.finishWorkout(
            state.session!.workoutId!,
            {}, // Summary is calculated on server now
          );

          if (response.success) {
            logger.i('[WorkoutSessionCubit] Workout finished successfully');
          } else {
            logger.e(
              '[WorkoutSessionCubit] Failed to finish workout: ${response.message}',
            );
          }
        } else if (saveWorkoutLogUseCase != null) {
          // Offline/Legacy flow: Create new log
          logger.i('[WorkoutSessionCubit] Saving workout log (legacy)...');
          final response = await saveWorkoutLogUseCase!(
            state.session!,
            state.elapsedTime,
          );

          if (response.success) {
            logger.i('[WorkoutSessionCubit] Workout log saved successfully');
          } else {
            logger.e(
              '[WorkoutSessionCubit] Failed to save workout log: ${response.message}',
            );
          }
        }
      } catch (e) {
        logger.e('[WorkoutSessionCubit] Error saving/finishing workout: $e');
      }
    }

    emit(
      state.copyWith(
        status: WorkoutSessionStatus.completed,
        isTimerRunning: false,
        clearRest: true,
        session: state.session?.copyWith(
          finishedAt: DateTime.now(),
          elapsedTime: state.elapsedTime,
        ),
      ),
    );
  }

  /// Update workout name
  void updateWorkoutName(String name) {
    if (state.session == null) return;

    emit(state.copyWith(session: state.session!.copyWith(workoutName: name)));
  }

  /// Finish an exercise: Sync health data and call API
  Future<void> _finishExercise(int exerciseIndex) async {
    if (state.session == null || state.session!.workoutId == null) return;

    final exercise = state.session!.exercises[exerciseIndex];
    final startTime = state.exerciseStartTime;
    final endTime = DateTime.now();

    if (startTime == null) {
      logger.w(
        '[WorkoutSessionCubit] Exercise start time is null, skipping sync',
      );
      return;
    }

    // 1. Force Sync Health Data
    if (healthConnectRepository != null) {
      try {
        logger.i(
          '[WorkoutSessionCubit] Syncing health data for range: $startTime - $endTime',
        );

        // --- SIMULATION: Write Mock Data for Testing ---
        // TODO: Remove this in production or put behind a debug flag
        await healthConnectRepository!.writeMockData(startTime, endTime);
        // -----------------------------------------------

        await healthConnectRepository!.syncHealthDataForRange(
          startTime,
          endTime,
        );
      } catch (e) {
        logger.e('[WorkoutSessionCubit] Error syncing health data: $e');
      }
    }

    // 2. Call API to complete exercise
    if (workoutLogRepository != null) {
      try {
        logger.i(
          '[WorkoutSessionCubit] Completing exercise ${exercise.exerciseId} on server',
        );

        if (exercise.id == null) {
          logger.w(
            '[WorkoutSessionCubit] Exercise ID (workoutDetailId) is missing, cannot complete on server',
          );
          return;
        }

        await workoutLogRepository!
            .completeExercise(state.session!.workoutId!, {
              'workoutDetailId': exercise.id,
              'startTime': startTime.toIso8601String(),
              'endTime': endTime.toIso8601String(),
            });
      } catch (e) {
        logger.e(
          '[WorkoutSessionCubit] Error completing exercise on server: $e',
        );
      }
    }

    // Reset start time for next exercise (will be set when next set starts or implicitly now)
    // Actually, _updateCurrentSet handles moving to next, so we should update startTime there.
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _restTimer?.cancel();
    return super.close();
  }
}

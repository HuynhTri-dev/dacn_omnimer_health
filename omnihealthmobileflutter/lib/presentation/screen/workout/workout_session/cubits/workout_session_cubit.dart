import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/active_workout_session_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/save_workout_log_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_session/cubits/workout_session_state.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

class WorkoutSessionCubit extends Cubit<WorkoutSessionState> {
  Timer? _timer;
  Timer? _restTimer;
  final SaveWorkoutLogUseCase? saveWorkoutLogUseCase;

  WorkoutSessionCubit({this.saveWorkoutLogUseCase})
    : super(const WorkoutSessionState());

  /// Start a workout session from a template
  void startWorkout(WorkoutTemplateEntity template) {
    final session = ActiveWorkoutSessionEntity.fromTemplate(template);

    // Find the first uncompleted set
    final (exerciseIndex, setIndex) = _findFirstUncompletedSet(session);

    emit(
      state.copyWith(
        status: WorkoutSessionStatus.active,
        session: session,
        currentExerciseIndex: exerciseIndex,
        currentSetIndex: setIndex,
        elapsedTime: Duration.zero,
        isTimerRunning: true,
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

    final (exerciseIndex, setIndex) = _findFirstUncompletedSet(state.session!);

    // Check if all sets are completed
    if (exerciseIndex == null && setIndex == null) {
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
      emit(
        state.copyWith(
          currentExerciseIndex: exerciseIndex,
          currentSetIndex: setIndex,
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

    // Save workout log to database
    if (state.session != null && saveWorkoutLogUseCase != null) {
      try {
        logger.i('[WorkoutSessionCubit] Saving workout log...');
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
      } catch (e) {
        logger.e('[WorkoutSessionCubit] Error saving workout log: $e');
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

  @override
  Future<void> close() {
    _timer?.cancel();
    _restTimer?.cancel();
    return super.close();
  }
}

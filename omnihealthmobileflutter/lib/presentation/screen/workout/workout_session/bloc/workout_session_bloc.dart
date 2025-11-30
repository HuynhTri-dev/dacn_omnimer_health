import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/active_workout_session_entity.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_connect_repository.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_log_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/save_workout_log_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/create_workout_feedback_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_session/bloc/workout_session_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_session/bloc/workout_session_event.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_feedback_entity.dart';

class WorkoutSessionBloc
    extends Bloc<WorkoutSessionEvent, WorkoutSessionState> {
  Timer? _timer;
  Timer? _restTimer;
  final SaveWorkoutLogUseCase? saveWorkoutLogUseCase;
  final WorkoutLogRepositoryAbs? workoutLogRepository;
  final HealthConnectRepository? healthConnectRepository;
  final CreateWorkoutFeedbackUseCase? createWorkoutFeedbackUseCase;

  WorkoutSessionBloc({
    this.saveWorkoutLogUseCase,
    this.workoutLogRepository,
    this.healthConnectRepository,
    this.createWorkoutFeedbackUseCase,
  }) : super(const WorkoutSessionState()) {
    on<StartWorkoutEvent>(_onStartWorkout);
    on<PauseWorkoutEvent>(_onPauseWorkout);
    on<ResumeWorkoutEvent>(_onResumeWorkout);
    on<ToggleExerciseExpansionEvent>(_onToggleExerciseExpansion);
    on<ToggleSetCompletionEvent>(_onToggleSetCompletion);
    on<SkipRestTimerEvent>(_onSkipRestTimer);
    on<AddRestTimeEvent>(_onAddRestTime);
    on<UpdateSetWeightEvent>(_onUpdateSetWeight);
    on<UpdateSetRepsEvent>(_onUpdateSetReps);
    on<AddSetEvent>(_onAddSet);
    on<RemoveSetEvent>(_onRemoveSet);
    on<LogNextSetEvent>(_onLogNextSet);
    on<CompleteAllSetsEvent>(_onCompleteAllSets);
    on<FinishWorkoutEvent>(_onFinishWorkout);
    on<UpdateWorkoutNameEvent>(_onUpdateWorkoutName);
    on<TickEvent>(_onTick);
    on<RestTickEvent>(_onRestTick);
    on<CreateWorkoutFeedbackEvent>(_onCreateWorkoutFeedback);
    on<ResetFeedbackStatusEvent>(_onResetFeedbackStatus);
  }

  Future<void> _onStartWorkout(
    StartWorkoutEvent event,
    Emitter<WorkoutSessionState> emit,
  ) async {
    emit(state.copyWith(status: WorkoutSessionStatus.loading));

    var session = ActiveWorkoutSessionEntity.fromTemplate(event.template);

    // Create workout on server if repository is available
    if (workoutLogRepository != null) {
      try {
        final response = await workoutLogRepository!.createWorkoutFromTemplate(
          event.template.id,
        );
        if (response.success && response.data != null) {
          final createdWorkout = response.data!;

          // Map server IDs to local session exercises
          List<ActiveExerciseEntity> updatedExercises = [];

          if (createdWorkout.exercises.length == session.exercises.length) {
            for (int i = 0; i < session.exercises.length; i++) {
              final localEx = session.exercises[i];
              final serverEx = createdWorkout.exercises[i];

              if (localEx.exerciseId == serverEx.exerciseId) {
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
                    '[WorkoutSessionBloc] Set count mismatch at exercise $i',
                  );
                }

                updatedExercises.add(
                  localEx.copyWith(id: serverEx.id, sets: updatedSets),
                );
              } else {
                updatedExercises.add(localEx);
                logger.w('[WorkoutSessionBloc] Exercise mismatch at index $i');
              }
            }
          } else {
            updatedExercises = session.exercises;
            logger.w('[WorkoutSessionBloc] Exercise count mismatch');
          }

          session = session.copyWith(
            workoutId: createdWorkout.id,
            exercises: updatedExercises,
          );

          logger.i(
            '[WorkoutSessionBloc] Created workout on server: ${createdWorkout.id}',
          );

          if (createdWorkout.id != null) {
            await workoutLogRepository!.startWorkout(createdWorkout.id!);
            logger.i('[WorkoutSessionBloc] Started workout on server');
          }
        } else {
          // Server returned an error - check for health profile issue
          String errorMessage = response.message;
          if (errorMessage.toLowerCase().contains('health profile') ||
              errorMessage.toLowerCase().contains('không thể tạo buổi tập')) {
            errorMessage =
                'Please create your Health Profile first before starting a workout. Go to Health tab to set up your profile.';
          }

          logger.e(
            '[WorkoutSessionBloc] Failed to create workout on server: ${response.message}',
          );

          emit(
            state.copyWith(
              status: WorkoutSessionStatus.error,
              errorMessage: errorMessage,
            ),
          );
          return; // Stop - don't start workout locally
        }
      } catch (e) {
        logger.e('[WorkoutSessionBloc] Error creating workout on server: $e');

        // Check if error message contains health profile info
        String errorMessage = e.toString();
        if (errorMessage.toLowerCase().contains('health profile')) {
          errorMessage =
              'Please create your Health Profile first before starting a workout. Go to Health tab to set up your profile.';
        }

        emit(
          state.copyWith(
            status: WorkoutSessionStatus.error,
            errorMessage: errorMessage,
          ),
        );
        return; // Stop - don't start workout locally
      }
    }

    // Initial state setup before timer starts
    final (exerciseIndex, setIndex) = _findFirstUncompletedSet(session);

    if (healthConnectRepository != null) {
      try {
        await healthConnectRepository!.startWorkoutSession(
          workoutType: event.template.name,
        );
      } catch (e) {
        logger.e(
          '[WorkoutSessionBloc] Error starting Health Connect session: $e',
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
        exerciseStartTime: DateTime.now(),
      ),
    );

    _startTimer();
  }

  void _onPauseWorkout(
    PauseWorkoutEvent event,
    Emitter<WorkoutSessionState> emit,
  ) {
    emit(
      state.copyWith(
        status: WorkoutSessionStatus.paused,
        isTimerRunning: false,
      ),
    );
  }

  void _onResumeWorkout(
    ResumeWorkoutEvent event,
    Emitter<WorkoutSessionState> emit,
  ) {
    emit(
      state.copyWith(status: WorkoutSessionStatus.active, isTimerRunning: true),
    );
  }

  void _onToggleExerciseExpansion(
    ToggleExerciseExpansionEvent event,
    Emitter<WorkoutSessionState> emit,
  ) {
    if (state.session == null) return;

    final exercises = List<ActiveExerciseEntity>.from(state.session!.exercises);
    exercises[event.exerciseIndex] = exercises[event.exerciseIndex].copyWith(
      isExpanded: !exercises[event.exerciseIndex].isExpanded,
    );

    emit(
      state.copyWith(session: state.session!.copyWith(exercises: exercises)),
    );
  }

  Future<void> _onToggleSetCompletion(
    ToggleSetCompletionEvent event,
    Emitter<WorkoutSessionState> emit,
  ) async {
    if (state.session == null) return;

    final exercises = List<ActiveExerciseEntity>.from(state.session!.exercises);
    final exercise = exercises[event.exerciseIndex];
    final sets = List<ActiveSetEntity>.from(exercise.sets);
    final currentSet = sets[event.setIndex];
    final isCompleting = !currentSet.isCompleted;

    sets[event.setIndex] = currentSet.copyWith(
      isCompleted: isCompleting,
      completedAt: isCompleting ? DateTime.now() : null,
    );

    exercises[event.exerciseIndex] = exercise.copyWith(sets: sets);

    emit(
      state.copyWith(session: state.session!.copyWith(exercises: exercises)),
    );

    if (isCompleting &&
        currentSet.restAfterSetSeconds != null &&
        currentSet.restAfterSetSeconds! > 0) {
      final hasNextSet = _hasNextUncompletedSet(
        event.exerciseIndex,
        event.setIndex,
      );
      if (hasNextSet) {
        _startRestTimer(
          event.exerciseIndex,
          event.setIndex,
          currentSet.restAfterSetSeconds!,
          emit,
        );
      }
    } else if (!isCompleting) {
      if (state.isResting &&
          state.restExerciseIndex == event.exerciseIndex &&
          state.restSetIndex == event.setIndex) {
        add(SkipRestTimerEvent());
      }
    }

    _updateCurrentSet(emit);

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
          '[WorkoutSessionBloc] Cannot complete set on server: Missing IDs (detail: $exerciseId, set: $setId)',
        );
      }
    }
  }

  void _onSkipRestTimer(
    SkipRestTimerEvent event,
    Emitter<WorkoutSessionState> emit,
  ) {
    _restTimer?.cancel();
    emit(state.copyWith(clearRest: true));
  }

  void _onAddRestTime(
    AddRestTimeEvent event,
    Emitter<WorkoutSessionState> emit,
  ) {
    if (state.isResting) {
      emit(
        state.copyWith(
          restTimeRemaining: state.restTimeRemaining + event.seconds,
        ),
      );
    }
  }

  void _onUpdateSetWeight(
    UpdateSetWeightEvent event,
    Emitter<WorkoutSessionState> emit,
  ) {
    if (state.session == null) return;

    final exercises = List<ActiveExerciseEntity>.from(state.session!.exercises);
    final exercise = exercises[event.exerciseIndex];
    final sets = List<ActiveSetEntity>.from(exercise.sets);

    sets[event.setIndex] = sets[event.setIndex].copyWith(
      actualWeight: event.weight,
    );
    exercises[event.exerciseIndex] = exercise.copyWith(sets: sets);

    emit(
      state.copyWith(session: state.session!.copyWith(exercises: exercises)),
    );
  }

  void _onUpdateSetReps(
    UpdateSetRepsEvent event,
    Emitter<WorkoutSessionState> emit,
  ) {
    if (state.session == null) return;

    final exercises = List<ActiveExerciseEntity>.from(state.session!.exercises);
    final exercise = exercises[event.exerciseIndex];
    final sets = List<ActiveSetEntity>.from(exercise.sets);

    sets[event.setIndex] = sets[event.setIndex].copyWith(
      actualReps: event.reps,
    );
    exercises[event.exerciseIndex] = exercise.copyWith(sets: sets);

    emit(
      state.copyWith(session: state.session!.copyWith(exercises: exercises)),
    );
  }

  void _onAddSet(AddSetEvent event, Emitter<WorkoutSessionState> emit) {
    if (state.session == null) return;

    final exercises = List<ActiveExerciseEntity>.from(state.session!.exercises);
    final exercise = exercises[event.exerciseIndex];
    final sets = List<ActiveSetEntity>.from(exercise.sets);

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

    exercises[event.exerciseIndex] = exercise.copyWith(sets: sets);

    emit(
      state.copyWith(session: state.session!.copyWith(exercises: exercises)),
    );

    _updateCurrentSet(emit);
  }

  void _onRemoveSet(RemoveSetEvent event, Emitter<WorkoutSessionState> emit) {
    if (state.session == null) return;

    final exercises = List<ActiveExerciseEntity>.from(state.session!.exercises);
    final exercise = exercises[event.exerciseIndex];
    final sets = List<ActiveSetEntity>.from(exercise.sets);

    if (sets.length <= 1) return;

    sets.removeAt(event.setIndex);

    for (int i = 0; i < sets.length; i++) {
      sets[i] = sets[i].copyWith(setOrder: i + 1);
    }

    exercises[event.exerciseIndex] = exercise.copyWith(sets: sets);

    emit(
      state.copyWith(session: state.session!.copyWith(exercises: exercises)),
    );
  }

  void _onLogNextSet(LogNextSetEvent event, Emitter<WorkoutSessionState> emit) {
    if (state.session == null) return;

    for (int i = 0; i < state.session!.exercises.length; i++) {
      final exercise = state.session!.exercises[i];
      for (int j = 0; j < exercise.sets.length; j++) {
        if (!exercise.sets[j].isCompleted) {
          add(ToggleSetCompletionEvent(i, j));
          return;
        }
      }
    }
  }

  void _onCompleteAllSets(
    CompleteAllSetsEvent event,
    Emitter<WorkoutSessionState> emit,
  ) {
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

  Future<void> _onFinishWorkout(
    FinishWorkoutEvent event,
    Emitter<WorkoutSessionState> emit,
  ) async {
    _timer?.cancel();
    _restTimer?.cancel();

    if (healthConnectRepository != null && state.session?.workoutId != null) {
      try {
        await healthConnectRepository!.stopWorkoutSession(
          state.session!.workoutId!,
        );
      } catch (e) {
        logger.e(
          '[WorkoutSessionBloc] Error stopping Health Connect session: $e',
        );
      }
    }

    if (state.session != null) {
      try {
        if (state.session!.workoutId != null && workoutLogRepository != null) {
          logger.i(
            '[WorkoutSessionBloc] Finishing workout ${state.session!.workoutId} on server...',
          );
          final response = await workoutLogRepository!.finishWorkout(
            state.session!.workoutId!,
            {},
          );

          if (response.success) {
            logger.i('[WorkoutSessionBloc] Workout finished successfully');
          } else {
            logger.e(
              '[WorkoutSessionBloc] Failed to finish workout: ${response.message}',
            );
          }
        } else if (saveWorkoutLogUseCase != null) {
          logger.i('[WorkoutSessionBloc] Saving workout log (legacy)...');
          final response = await saveWorkoutLogUseCase!(
            state.session!,
            state.elapsedTime,
          );

          if (response.success) {
            logger.i('[WorkoutSessionBloc] Workout log saved successfully');
          } else {
            logger.e(
              '[WorkoutSessionBloc] Failed to save workout log: ${response.message}',
            );
          }
        }
      } catch (e) {
        logger.e('[WorkoutSessionBloc] Error saving/finishing workout: $e');
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

  void _onUpdateWorkoutName(
    UpdateWorkoutNameEvent event,
    Emitter<WorkoutSessionState> emit,
  ) {
    if (state.session == null) return;
    emit(
      state.copyWith(session: state.session!.copyWith(workoutName: event.name)),
    );
  }

  void _onTick(TickEvent event, Emitter<WorkoutSessionState> emit) {
    if (state.isTimerRunning) {
      emit(
        state.copyWith(
          elapsedTime: state.elapsedTime + const Duration(seconds: 1),
        ),
      );
    }
  }

  void _onRestTick(RestTickEvent event, Emitter<WorkoutSessionState> emit) {
    if (state.restTimeRemaining > 0) {
      emit(state.copyWith(restTimeRemaining: state.restTimeRemaining - 1));
    } else {
      _restTimer?.cancel();
      emit(state.copyWith(clearRest: true));
    }
  }

  Future<void> _onCreateWorkoutFeedback(
    CreateWorkoutFeedbackEvent event,
    Emitter<WorkoutSessionState> emit,
  ) async {
    if (state.session?.workoutId == null) {
      logger.w(
        '[WorkoutSessionBloc] Workout ID is null, skipping feedback submission and completing locally.',
      );
      emit(state.copyWith(feedbackStatus: FeedbackSubmissionStatus.success));
      return;
    }

    if (createWorkoutFeedbackUseCase == null) {
      logger.e('[WorkoutSessionBloc] CreateWorkoutFeedbackUseCase is null');
      emit(state.copyWith(feedbackStatus: FeedbackSubmissionStatus.failure));
      return;
    }

    emit(state.copyWith(feedbackStatus: FeedbackSubmissionStatus.submitting));

    try {
      final feedback = WorkoutFeedbackEntity(
        workoutId: state.session!.workoutId!,
        suitability: event.suitability,
        workoutGoalAchieved: event.workoutGoalAchieved,
        targetMuscleFelt: event.targetMuscleFelt,
        injuryOrPainNotes: event.injuryOrPainNotes,
        exerciseNotSuitable: event.exerciseNotSuitable,
        additionalNotes: event.additionalNotes,
      );

      await createWorkoutFeedbackUseCase!(feedback);
      logger.i('[WorkoutSessionBloc] Feedback submitted successfully');
      emit(state.copyWith(feedbackStatus: FeedbackSubmissionStatus.success));
    } catch (e) {
      logger.e('[WorkoutSessionBloc] Error submitting feedback: $e');
      emit(state.copyWith(feedbackStatus: FeedbackSubmissionStatus.failure));
    }
  }

  void _onResetFeedbackStatus(
    ResetFeedbackStatusEvent event,
    Emitter<WorkoutSessionState> emit,
  ) {
    emit(state.copyWith(feedbackStatus: FeedbackSubmissionStatus.initial));
  }

  // --- Helpers ---

  (int?, int?) _findFirstUncompletedSet(ActiveWorkoutSessionEntity session) {
    for (int i = 0; i < session.exercises.length; i++) {
      final exercise = session.exercises[i];
      for (int j = 0; j < exercise.sets.length; j++) {
        if (!exercise.sets[j].isCompleted) {
          return (i, j);
        }
      }
    }
    return (null, null);
  }

  void _updateCurrentSet(Emitter<WorkoutSessionState> emit) {
    if (state.session == null) return;

    final oldExerciseIndex = state.currentExerciseIndex;
    final (newExerciseIndex, newSetIndex) = _findFirstUncompletedSet(
      state.session!,
    );

    if (oldExerciseIndex != null &&
        (newExerciseIndex == null || newExerciseIndex != oldExerciseIndex)) {
      final oldExercise = state.session!.exercises[oldExerciseIndex];

      if (oldExercise.isCompleted) {
        logger.i(
          '[WorkoutSessionBloc] Exercise ${oldExercise.exerciseId} completed (all reps done). Triggering sync and completion.',
        );
        _finishExercise(oldExerciseIndex);
      }
    }

    if (newExerciseIndex == null && newSetIndex == null) {
      add(FinishWorkoutEvent());
      emit(
        state.copyWith(
          currentExerciseIndex: null,
          currentSetIndex: null,
          isTimerRunning: false,
          clearCurrentSet: true,
        ),
      );
    } else {
      DateTime? newStartTime = state.exerciseStartTime;
      if (newExerciseIndex != oldExerciseIndex) {
        newStartTime = DateTime.now();
        logger.i(
          '[WorkoutSessionBloc] Starting new exercise index: $newExerciseIndex at $newStartTime',
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

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(const TickEvent());
    });
  }

  void _startRestTimer(
    int exerciseIndex,
    int setIndex,
    int seconds,
    Emitter<WorkoutSessionState> emit,
  ) {
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
      add(const RestTickEvent());
    });
  }

  bool _hasNextUncompletedSet(int exerciseIndex, int setIndex) {
    if (state.session == null) return false;

    final exercise = state.session!.exercises[exerciseIndex];
    for (int j = setIndex + 1; j < exercise.sets.length; j++) {
      if (!exercise.sets[j].isCompleted) return true;
    }

    for (int i = exerciseIndex + 1; i < state.session!.exercises.length; i++) {
      for (int j = 0; j < state.session!.exercises[i].sets.length; j++) {
        if (!state.session!.exercises[i].sets[j].isCompleted) return true;
      }
    }

    return false;
  }

  Future<void> _finishExercise(int exerciseIndex) async {
    if (state.session == null || state.session!.workoutId == null) return;

    final exercise = state.session!.exercises[exerciseIndex];
    final startTime = state.exerciseStartTime;
    final endTime = DateTime.now();

    if (startTime == null) {
      logger.w(
        '[WorkoutSessionBloc] Exercise start time is null, skipping sync',
      );
      return;
    }

    if (healthConnectRepository != null) {
      try {
        logger.i(
          '[WorkoutSessionBloc] Syncing health data for range: $startTime - $endTime',
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
        logger.e('[WorkoutSessionBloc] Error syncing health data: $e');
      }
    }

    if (workoutLogRepository != null) {
      try {
        logger.i(
          '[WorkoutSessionBloc] Completing exercise ${exercise.exerciseId} on server',
        );

        if (exercise.id == null) {
          logger.w(
            '[WorkoutSessionBloc] Exercise ID (workoutDetailId) is missing, cannot complete on server',
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
          '[WorkoutSessionBloc] Error completing exercise on server: $e',
        );
      }
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _restTimer?.cancel();
    return super.close();
  }
}

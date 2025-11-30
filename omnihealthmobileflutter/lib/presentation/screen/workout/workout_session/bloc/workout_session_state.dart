import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/active_workout_session_entity.dart';

enum WorkoutSessionStatus { initial, loading, active, paused, completed, error }

enum FeedbackSubmissionStatus { initial, submitting, success, failure }

class WorkoutSessionState extends Equatable {
  final WorkoutSessionStatus status;
  final FeedbackSubmissionStatus feedbackStatus;
  final ActiveWorkoutSessionEntity? session;
  final String? errorMessage;
  final int? currentExerciseIndex;
  final int? currentSetIndex;
  final Duration elapsedTime;
  final bool isTimerRunning;

  final DateTime? exerciseStartTime;
  // Rest timer state
  final bool isResting;
  final int restTimeRemaining; // in seconds
  final int? restExerciseIndex;
  final int? restSetIndex;

  const WorkoutSessionState({
    this.status = WorkoutSessionStatus.initial,
    this.feedbackStatus = FeedbackSubmissionStatus.initial,
    this.session,
    this.errorMessage,
    this.currentExerciseIndex,
    this.currentSetIndex,
    this.elapsedTime = Duration.zero,
    this.isTimerRunning = false,
    this.exerciseStartTime,
    this.isResting = false,
    this.restTimeRemaining = 0,
    this.restExerciseIndex,
    this.restSetIndex,
  });

  WorkoutSessionState copyWith({
    WorkoutSessionStatus? status,
    FeedbackSubmissionStatus? feedbackStatus,
    ActiveWorkoutSessionEntity? session,
    String? errorMessage,
    int? currentExerciseIndex,
    int? currentSetIndex,
    Duration? elapsedTime,
    bool? isTimerRunning,
    bool clearCurrentSet = false,
    DateTime? exerciseStartTime,
    bool? isResting,
    int? restTimeRemaining,
    int? restExerciseIndex,
    int? restSetIndex,
    bool clearRest = false,
  }) {
    return WorkoutSessionState(
      status: status ?? this.status,
      feedbackStatus: feedbackStatus ?? this.feedbackStatus,
      session: session ?? this.session,
      errorMessage: errorMessage,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentSetIndex: clearCurrentSet
          ? null
          : (currentSetIndex ?? this.currentSetIndex),
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      exerciseStartTime: exerciseStartTime ?? this.exerciseStartTime,
      isResting: clearRest ? false : (isResting ?? this.isResting),
      restTimeRemaining: clearRest
          ? 0
          : (restTimeRemaining ?? this.restTimeRemaining),
      restExerciseIndex: clearRest
          ? null
          : (restExerciseIndex ?? this.restExerciseIndex),
      restSetIndex: clearRest ? null : (restSetIndex ?? this.restSetIndex),
    );
  }

  /// Check if this is the current active set
  bool isCurrentSet(int exerciseIndex, int setIndex) {
    return currentExerciseIndex == exerciseIndex && currentSetIndex == setIndex;
  }

  /// Check if this set is in rest mode
  bool isSetResting(int exerciseIndex, int setIndex) {
    return isResting &&
        restExerciseIndex == exerciseIndex &&
        restSetIndex == setIndex;
  }

  /// Format rest time as MM:SS
  String get formattedRestTime {
    final minutes = (restTimeRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (restTimeRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Format elapsed time as MM:SS
  String get formattedTime {
    final minutes = elapsedTime.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = elapsedTime.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Format elapsed time as HH:MM:SS (for long workouts)
  String get formattedTimeLong {
    final hours = elapsedTime.inHours.toString().padLeft(2, '0');
    final minutes = elapsedTime.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = elapsedTime.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  List<Object?> get props => [
    status,
    feedbackStatus,
    session,
    errorMessage,
    currentExerciseIndex,
    currentSetIndex,
    elapsedTime,
    isTimerRunning,
    exerciseStartTime,
    isResting,
    restTimeRemaining,
    restExerciseIndex,
    restSetIndex,
  ];
}

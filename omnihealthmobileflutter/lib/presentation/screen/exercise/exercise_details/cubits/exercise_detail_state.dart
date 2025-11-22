import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_detail_entity.dart';

enum ExerciseDetailStatus { initial, loading, loaded, error, rating, rated }

class ExerciseDetailState extends Equatable {
  final ExerciseDetailStatus status;
  final ExerciseDetailEntity? exercise;
  final double? userRating;
  final String? errorMessage;

  const ExerciseDetailState({
    this.status = ExerciseDetailStatus.initial,
    this.exercise,
    this.userRating,
    this.errorMessage,
  });

  ExerciseDetailState copyWith({
    ExerciseDetailStatus? status,
    ExerciseDetailEntity? exercise,
    double? userRating,
    String? errorMessage,
  }) {
    return ExerciseDetailState(
      status: status ?? this.status,
      exercise: exercise ?? this.exercise,
      userRating: userRating ?? this.userRating,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, exercise, userRating, errorMessage];
}

import 'package:equatable/equatable.dart';

class ExerciseDetailState extends Equatable {
  final bool loading;
  final double currentRating;
  final String? error;

  const ExerciseDetailState({
    this.loading = false,
    this.currentRating = 0.0,
    this.error,
  });

  ExerciseDetailState copyWith({
    bool? loading,
    double? currentRating,
    String? error,
  }) {
    return ExerciseDetailState(
      loading: loading ?? this.loading,
      currentRating: currentRating ?? this.currentRating,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, currentRating, error];
}

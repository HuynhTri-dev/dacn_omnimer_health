import 'package:equatable/equatable.dart';

class WorkoutFrequencyEntity extends Equatable {
  final String period;
  final int count;

  const WorkoutFrequencyEntity({required this.period, required this.count});

  @override
  List<Object?> get props => [period, count];
}

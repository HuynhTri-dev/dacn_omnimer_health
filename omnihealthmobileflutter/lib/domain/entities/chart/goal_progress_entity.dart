import 'package:equatable/equatable.dart';

class GoalProgressEntity extends Equatable {
  final String status;
  final int count;

  const GoalProgressEntity({required this.status, required this.count});

  @override
  List<Object?> get props => [status, count];
}

import 'package:equatable/equatable.dart';

class CaloriesBurnedEntity extends Equatable {
  final DateTime date;
  final double calories;

  const CaloriesBurnedEntity({required this.date, required this.calories});

  @override
  List<Object?> get props => [date, calories];
}

import 'package:equatable/equatable.dart';

class WeightProgressEntity extends Equatable {
  final DateTime date;
  final double weight;

  const WeightProgressEntity({required this.date, required this.weight});

  @override
  List<Object?> get props => [date, weight];
}

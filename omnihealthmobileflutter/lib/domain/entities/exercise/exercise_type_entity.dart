import 'package:equatable/equatable.dart';

class ExerciseTypeEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final List<String> suitableGoals;

  const ExerciseTypeEntity({
    required this.id,
    required this.name,
    this.description,
    required this.suitableGoals,
  });

  @override
  List<Object?> get props => [id, name, description, suitableGoals];
}

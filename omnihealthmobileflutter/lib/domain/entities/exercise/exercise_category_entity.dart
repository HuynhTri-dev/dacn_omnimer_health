import 'package:equatable/equatable.dart';

class ExerciseCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? description;

  const ExerciseCategoryEntity({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}

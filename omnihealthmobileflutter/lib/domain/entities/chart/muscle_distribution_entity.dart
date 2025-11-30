import 'package:equatable/equatable.dart';

class MuscleDistributionEntity extends Equatable {
  final String muscleName;
  final int count;

  const MuscleDistributionEntity({
    required this.muscleName,
    required this.count,
  });

  @override
  List<Object?> get props => [muscleName, count];
}

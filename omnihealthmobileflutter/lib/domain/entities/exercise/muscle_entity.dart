import 'package:equatable/equatable.dart';

class MuscleEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<String>? bodyPartNames;

  const MuscleEntity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.bodyPartNames,
  });

  @override
  List<Object?> get props => [id, name, description, imageUrl, bodyPartNames];
}

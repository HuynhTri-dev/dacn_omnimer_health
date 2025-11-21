import 'package:equatable/equatable.dart';

class BodyPartEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;

  const BodyPartEntity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, description, imageUrl];
}

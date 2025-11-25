import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

abstract class HealthProfileEvent extends Equatable {
  const HealthProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetHealthProfilesEvent extends HealthProfileEvent {
  const GetHealthProfilesEvent();
}

class GetHealthProfileByIdEvent extends HealthProfileEvent {
  final String id;

  const GetHealthProfileByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class GetLatestHealthProfileEvent extends HealthProfileEvent {
  const GetLatestHealthProfileEvent();
}

class GetHealthProfilesByUserIdEvent extends HealthProfileEvent {
  final String userId;

  const GetHealthProfilesByUserIdEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateHealthProfileEvent extends HealthProfileEvent {
  final HealthProfile profile;

  const CreateHealthProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

class UpdateHealthProfileEvent extends HealthProfileEvent {
  final String id;
  final HealthProfile profile;

  const UpdateHealthProfileEvent(this.id, this.profile);

  @override
  List<Object?> get props => [id, profile];
}

class DeleteHealthProfileEvent extends HealthProfileEvent {
  final String id;

  const DeleteHealthProfileEvent(this.id);

  @override
  List<Object?> get props => [id];
}
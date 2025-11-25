import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

abstract class HealthProfileState extends Equatable {
  const HealthProfileState();

  @override
  List<Object?> get props => [];
}

class HealthProfileInitial extends HealthProfileState {
  const HealthProfileInitial();
}

class HealthProfileLoading extends HealthProfileState {
  const HealthProfileLoading();
}

class HealthProfilesLoaded extends HealthProfileState {
  final List<HealthProfile> profiles;

  const HealthProfilesLoaded(this.profiles);

  @override
  List<Object?> get props => [profiles];
}

class HealthProfileLoaded extends HealthProfileState {
  final HealthProfile profile;

  const HealthProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class HealthProfileError extends HealthProfileState {
  final String message;

  const HealthProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class HealthProfileCreateSuccess extends HealthProfileState {
  final HealthProfile profile;

  const HealthProfileCreateSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class HealthProfileUpdateSuccess extends HealthProfileState {
  final HealthProfile profile;

  const HealthProfileUpdateSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class HealthProfileDeleteSuccess extends HealthProfileState {
  const HealthProfileDeleteSuccess();
}
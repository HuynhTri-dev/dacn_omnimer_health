import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';

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
  final List<GoalEntity> goals;

  const HealthProfileLoaded(this.profile, {this.goals = const []});

  @override
  List<Object?> get props => [profile, goals];

  HealthProfileLoaded copyWith({
    HealthProfile? profile,
    List<GoalEntity>? goals,
  }) {
    return HealthProfileLoaded(
      profile ?? this.profile,
      goals: goals ?? this.goals,
    );
  }
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

class HealthProfileEmpty extends HealthProfileState {
  final List<GoalEntity> goals;

  const HealthProfileEmpty({this.goals = const []});

  @override
  List<Object?> get props => [goals];
}

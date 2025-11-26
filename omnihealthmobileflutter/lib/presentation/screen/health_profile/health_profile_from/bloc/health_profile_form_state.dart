import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

abstract class HealthProfileFormState extends Equatable {
  const HealthProfileFormState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HealthProfileFormInitial extends HealthProfileFormState {}

/// Loading state khi đang load profile để update
class HealthProfileFormLoading extends HealthProfileFormState {}

/// Loaded state - profile có thể null (create mode) hoặc có data (update mode)
class HealthProfileFormLoaded extends HealthProfileFormState {
  final HealthProfile? profile;

  const HealthProfileFormLoaded({this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Submitting state khi đang submit form
class HealthProfileFormSubmitting extends HealthProfileFormState {}

/// Success state sau khi submit thành công
class HealthProfileFormSuccess extends HealthProfileFormState {
  final HealthProfile profile;
  final bool isUpdate;

  const HealthProfileFormSuccess({
    required this.profile,
    required this.isUpdate,
  });

  @override
  List<Object?> get props => [profile, isUpdate];
}

/// Error state
class HealthProfileFormError extends HealthProfileFormState {
  final String message;

  const HealthProfileFormError({required this.message});

  @override
  List<Object?> get props => [message];
}

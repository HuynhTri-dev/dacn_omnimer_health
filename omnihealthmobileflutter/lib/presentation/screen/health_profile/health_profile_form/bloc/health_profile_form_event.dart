import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

abstract class HealthProfileFormEvent extends Equatable {
  const HealthProfileFormEvent();

  @override
  List<Object?> get props => [];
}

/// Event để load profile (nếu có ID) hoặc khởi tạo form mới
class LoadHealthProfileFormEvent extends HealthProfileFormEvent {
  final String? profileId;

  const LoadHealthProfileFormEvent({this.profileId});

  @override
  List<Object?> get props => [profileId];
}

/// Event để submit form (create hoặc update)
class SubmitHealthProfileFormEvent extends HealthProfileFormEvent {
  final HealthProfile profile;

  const SubmitHealthProfileFormEvent({required this.profile});

  @override
  List<Object?> get props => [profile];
}

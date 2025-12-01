import 'package:equatable/equatable.dart';

/// Events for Privacy & LOD Bloc
abstract class PrivacyLodEvent extends Equatable {
  const PrivacyLodEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial settings
class LoadPrivacySettings extends PrivacyLodEvent {
  const LoadPrivacySettings();
}

/// Toggle data visibility for a specific data type
class ToggleDataVisibility extends PrivacyLodEvent {
  final String dataType;
  final bool isVisible;

  const ToggleDataVisibility({
    required this.dataType,
    required this.isVisible,
  });

  @override
  List<Object?> get props => [dataType, isVisible];
}

/// Toggle anonymize data option
class ToggleAnonymizeData extends PrivacyLodEvent {
  final bool isAnonymized;

  const ToggleAnonymizeData({required this.isAnonymized});

  @override
  List<Object?> get props => [isAnonymized];
}

/// Accept Privacy Policy
class AcceptPrivacyPolicy extends PrivacyLodEvent {
  final bool isAccepted;

  const AcceptPrivacyPolicy({required this.isAccepted});

  @override
  List<Object?> get props => [isAccepted];
}

/// Accept Terms of Service
class AcceptTermsOfService extends PrivacyLodEvent {
  final bool isAccepted;

  const AcceptTermsOfService({required this.isAccepted});

  @override
  List<Object?> get props => [isAccepted];
}

/// Save all privacy settings
class SavePrivacySettings extends PrivacyLodEvent {
  const SavePrivacySettings();
}


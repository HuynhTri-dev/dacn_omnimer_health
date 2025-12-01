import 'package:equatable/equatable.dart';

/// Data visibility settings model
class DataVisibilitySettings extends Equatable {
  final bool stepsVisible;
  final bool heartRateVisible;
  final bool caloriesVisible;
  final bool sleepVisible;
  final bool workoutsVisible;
  final bool weightVisible;

  const DataVisibilitySettings({
    this.stepsVisible = true,
    this.heartRateVisible = true,
    this.caloriesVisible = true,
    this.sleepVisible = true,
    this.workoutsVisible = true,
    this.weightVisible = false,
  });

  DataVisibilitySettings copyWith({
    bool? stepsVisible,
    bool? heartRateVisible,
    bool? caloriesVisible,
    bool? sleepVisible,
    bool? workoutsVisible,
    bool? weightVisible,
  }) {
    return DataVisibilitySettings(
      stepsVisible: stepsVisible ?? this.stepsVisible,
      heartRateVisible: heartRateVisible ?? this.heartRateVisible,
      caloriesVisible: caloriesVisible ?? this.caloriesVisible,
      sleepVisible: sleepVisible ?? this.sleepVisible,
      workoutsVisible: workoutsVisible ?? this.workoutsVisible,
      weightVisible: weightVisible ?? this.weightVisible,
    );
  }

  @override
  List<Object?> get props => [
        stepsVisible,
        heartRateVisible,
        caloriesVisible,
        sleepVisible,
        workoutsVisible,
        weightVisible,
      ];
}

/// States for Privacy & LOD Bloc
abstract class PrivacyLodState extends Equatable {
  const PrivacyLodState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PrivacyLodInitial extends PrivacyLodState {
  const PrivacyLodInitial();
}

/// Loading state
class PrivacyLodLoading extends PrivacyLodState {
  const PrivacyLodLoading();
}

/// Loaded state with all settings
class PrivacyLodLoaded extends PrivacyLodState {
  final DataVisibilitySettings dataVisibility;
  final bool isAnonymizeEnabled;
  final bool isPrivacyPolicyAccepted;
  final bool isTermsAccepted;
  final String? lodEndpointUrl;

  const PrivacyLodLoaded({
    required this.dataVisibility,
    this.isAnonymizeEnabled = false,
    this.isPrivacyPolicyAccepted = false,
    this.isTermsAccepted = false,
    this.lodEndpointUrl,
  });

  PrivacyLodLoaded copyWith({
    DataVisibilitySettings? dataVisibility,
    bool? isAnonymizeEnabled,
    bool? isPrivacyPolicyAccepted,
    bool? isTermsAccepted,
    String? lodEndpointUrl,
  }) {
    return PrivacyLodLoaded(
      dataVisibility: dataVisibility ?? this.dataVisibility,
      isAnonymizeEnabled: isAnonymizeEnabled ?? this.isAnonymizeEnabled,
      isPrivacyPolicyAccepted:
          isPrivacyPolicyAccepted ?? this.isPrivacyPolicyAccepted,
      isTermsAccepted: isTermsAccepted ?? this.isTermsAccepted,
      lodEndpointUrl: lodEndpointUrl ?? this.lodEndpointUrl,
    );
  }

  @override
  List<Object?> get props => [
        dataVisibility,
        isAnonymizeEnabled,
        isPrivacyPolicyAccepted,
        isTermsAccepted,
        lodEndpointUrl,
      ];
}

/// Error state
class PrivacyLodError extends PrivacyLodState {
  final String message;

  const PrivacyLodError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Settings saved successfully
class PrivacyLodSaved extends PrivacyLodState {
  const PrivacyLodSaved();
}


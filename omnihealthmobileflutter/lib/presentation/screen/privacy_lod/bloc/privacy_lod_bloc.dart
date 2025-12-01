import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'privacy_lod_event.dart';
import 'privacy_lod_state.dart';

/// Bloc for managing Privacy & LOD settings
class PrivacyLodBloc extends Bloc<PrivacyLodEvent, PrivacyLodState> {
  static const String _keyStepsVisible = 'privacy_steps_visible';
  static const String _keyHeartRateVisible = 'privacy_heart_rate_visible';
  static const String _keyCaloriesVisible = 'privacy_calories_visible';
  static const String _keySleepVisible = 'privacy_sleep_visible';
  static const String _keyWorkoutsVisible = 'privacy_workouts_visible';
  static const String _keyWeightVisible = 'privacy_weight_visible';
  static const String _keyAnonymize = 'privacy_anonymize';
  static const String _keyPrivacyAccepted = 'privacy_policy_accepted';
  static const String _keyTermsAccepted = 'terms_accepted';

  PrivacyLodBloc() : super(const PrivacyLodInitial()) {
    on<LoadPrivacySettings>(_onLoadSettings);
    on<ToggleDataVisibility>(_onToggleDataVisibility);
    on<ToggleAnonymizeData>(_onToggleAnonymize);
    on<AcceptPrivacyPolicy>(_onAcceptPrivacy);
    on<AcceptTermsOfService>(_onAcceptTerms);
    on<SavePrivacySettings>(_onSaveSettings);
  }

  Future<void> _onLoadSettings(
    LoadPrivacySettings event,
    Emitter<PrivacyLodState> emit,
  ) async {
    emit(const PrivacyLodLoading());

    try {
      final prefs = await SharedPreferences.getInstance();

      final dataVisibility = DataVisibilitySettings(
        stepsVisible: prefs.getBool(_keyStepsVisible) ?? true,
        heartRateVisible: prefs.getBool(_keyHeartRateVisible) ?? true,
        caloriesVisible: prefs.getBool(_keyCaloriesVisible) ?? true,
        sleepVisible: prefs.getBool(_keySleepVisible) ?? true,
        workoutsVisible: prefs.getBool(_keyWorkoutsVisible) ?? true,
        weightVisible: prefs.getBool(_keyWeightVisible) ?? false,
      );

      emit(PrivacyLodLoaded(
        dataVisibility: dataVisibility,
        isAnonymizeEnabled: prefs.getBool(_keyAnonymize) ?? false,
        isPrivacyPolicyAccepted: prefs.getBool(_keyPrivacyAccepted) ?? false,
        isTermsAccepted: prefs.getBool(_keyTermsAccepted) ?? false,
        lodEndpointUrl: null, // Will be implemented with backend
      ));
    } catch (e) {
      emit(PrivacyLodError(message: 'Failed to load settings: $e'));
    }
  }

  Future<void> _onToggleDataVisibility(
    ToggleDataVisibility event,
    Emitter<PrivacyLodState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PrivacyLodLoaded) return;

    DataVisibilitySettings newVisibility;
    String prefKey;

    switch (event.dataType) {
      case 'steps':
        newVisibility =
            currentState.dataVisibility.copyWith(stepsVisible: event.isVisible);
        prefKey = _keyStepsVisible;
        break;
      case 'heartRate':
        newVisibility = currentState.dataVisibility
            .copyWith(heartRateVisible: event.isVisible);
        prefKey = _keyHeartRateVisible;
        break;
      case 'calories':
        newVisibility = currentState.dataVisibility
            .copyWith(caloriesVisible: event.isVisible);
        prefKey = _keyCaloriesVisible;
        break;
      case 'sleep':
        newVisibility =
            currentState.dataVisibility.copyWith(sleepVisible: event.isVisible);
        prefKey = _keySleepVisible;
        break;
      case 'workouts':
        newVisibility = currentState.dataVisibility
            .copyWith(workoutsVisible: event.isVisible);
        prefKey = _keyWorkoutsVisible;
        break;
      case 'weight':
        newVisibility = currentState.dataVisibility
            .copyWith(weightVisible: event.isVisible);
        prefKey = _keyWeightVisible;
        break;
      default:
        return;
    }

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, event.isVisible);

    emit(currentState.copyWith(dataVisibility: newVisibility));
  }

  Future<void> _onToggleAnonymize(
    ToggleAnonymizeData event,
    Emitter<PrivacyLodState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PrivacyLodLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAnonymize, event.isAnonymized);

    emit(currentState.copyWith(isAnonymizeEnabled: event.isAnonymized));
  }

  Future<void> _onAcceptPrivacy(
    AcceptPrivacyPolicy event,
    Emitter<PrivacyLodState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PrivacyLodLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPrivacyAccepted, event.isAccepted);

    emit(currentState.copyWith(isPrivacyPolicyAccepted: event.isAccepted));
  }

  Future<void> _onAcceptTerms(
    AcceptTermsOfService event,
    Emitter<PrivacyLodState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PrivacyLodLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTermsAccepted, event.isAccepted);

    emit(currentState.copyWith(isTermsAccepted: event.isAccepted));
  }

  Future<void> _onSaveSettings(
    SavePrivacySettings event,
    Emitter<PrivacyLodState> emit,
  ) async {
    // All settings are already saved individually
    // This can be used for batch save or sync with backend in the future
    emit(const PrivacyLodSaved());
  }
}


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/create_health_profile.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/delete_health_profile.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_health_profile_by_id.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_health_profiles.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_health_profiles_by_user_id.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_latest_health_profile.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/update_health_profile.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_health_profile_by_date.dart';
import 'package:omnihealthmobileflutter/domain/usecases/goal/get_goals_usecase.dart';
import 'health_profile_event.dart';
import 'health_profile_state.dart';

class HealthProfileBloc extends Bloc<HealthProfileEvent, HealthProfileState> {
  final GetHealthProfilesUseCase _getHealthProfilesUseCase;
  final GetHealthProfileByIdUseCase _getHealthProfileByIdUseCase;
  final GetLatestHealthProfileUseCase _getLatestHealthProfileUseCase;
  final GetHealthProfileByDateUseCase _getHealthProfileByDateUseCase;
  final GetHealthProfilesByUserIdUseCase _getHealthProfilesByUserIdUseCase;
  final CreateHealthProfileUseCase _createHealthProfileUseCase;
  final UpdateHealthProfileUseCase _updateHealthProfileUseCase;
  final DeleteHealthProfileUseCase _deleteHealthProfileUseCase;
  final GetGoalsUseCase _getGoalsUseCase;

  HealthProfileBloc({
    required GetHealthProfilesUseCase getHealthProfilesUseCase,
    required GetHealthProfileByIdUseCase getHealthProfileByIdUseCase,
    required GetLatestHealthProfileUseCase getLatestHealthProfileUseCase,
    required GetHealthProfileByDateUseCase getHealthProfileByDateUseCase,
    required GetHealthProfilesByUserIdUseCase getHealthProfilesByUserIdUseCase,
    required CreateHealthProfileUseCase createHealthProfileUseCase,
    required UpdateHealthProfileUseCase updateHealthProfileUseCase,
    required DeleteHealthProfileUseCase deleteHealthProfileUseCase,
    required GetGoalsUseCase getGoalsUseCase,
  }) : _getHealthProfilesUseCase = getHealthProfilesUseCase,
       _getHealthProfileByIdUseCase = getHealthProfileByIdUseCase,
       _getLatestHealthProfileUseCase = getLatestHealthProfileUseCase,
       _getHealthProfileByDateUseCase = getHealthProfileByDateUseCase,
       _getHealthProfilesByUserIdUseCase = getHealthProfilesByUserIdUseCase,
       _createHealthProfileUseCase = createHealthProfileUseCase,
       _updateHealthProfileUseCase = updateHealthProfileUseCase,
       _deleteHealthProfileUseCase = deleteHealthProfileUseCase,
       _getGoalsUseCase = getGoalsUseCase,
       super(const HealthProfileInitial()) {
    on<GetHealthProfilesEvent>(_onGetHealthProfiles);
    on<GetHealthProfileByIdEvent>(_onGetHealthProfileById);
    on<GetLatestHealthProfileEvent>(_onGetLatestHealthProfile);
    on<GetHealthProfileByDateEvent>(_onGetHealthProfileByDate);
    on<GetHealthProfilesByUserIdEvent>(_onGetHealthProfilesByUserId);
    on<CreateHealthProfileEvent>(_onCreateHealthProfile);
    on<UpdateHealthProfileEvent>(_onUpdateHealthProfile);
    on<DeleteHealthProfileEvent>(_onDeleteHealthProfile);
    on<GetHealthProfileGoalsEvent>(_onGetHealthProfileGoals);
  }

  Future<void> _onGetHealthProfileGoals(
    GetHealthProfileGoalsEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    try {
      final response = await _getGoalsUseCase(event.userId);

      if (response.success && response.data != null) {
        // If we already have a loaded profile, update it with goals
        if (state is HealthProfileLoaded) {
          final currentState = state as HealthProfileLoaded;
          emit(currentState.copyWith(goals: response.data));
        } else {
          // If no profile loaded yet, we need to wait or emit a different state
          // For now, we'll just silently succeed - the goals will be loaded
          // when the profile loads via the listener in health_profile_page.dart
        }
      }
    } catch (e) {
      // Silently fail for goals - don't interrupt the main flow
    }
  }

  Future<void> _onGetHealthProfileByDate(
    GetHealthProfileByDateEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    await _executeUseCase<HealthProfile>(
      () => _getHealthProfileByDateUseCase(event.date),
      emit,
      (data) => HealthProfileLoaded(data),
    );
  }

  Future<void> _onGetHealthProfiles(
    GetHealthProfilesEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    await _executeUseCase<List<HealthProfile>>(
      () => _getHealthProfilesUseCase(NoParams()),
      emit,
      (data) => HealthProfilesLoaded(data),
    );
  }

  Future<void> _onGetHealthProfileById(
    GetHealthProfileByIdEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    await _executeUseCase<HealthProfile>(
      () => _getHealthProfileByIdUseCase(event.id),
      emit,
      (data) => HealthProfileLoaded(data),
    );
  }

  Future<void> _onGetLatestHealthProfile(
    GetLatestHealthProfileEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    await _executeUseCase<HealthProfile>(
      () => _getLatestHealthProfileUseCase(NoParams()),
      emit,
      (data) => HealthProfileLoaded(data),
    );
  }

  Future<void> _onGetHealthProfilesByUserId(
    GetHealthProfilesByUserIdEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    await _executeUseCase<List<HealthProfile>>(
      () => _getHealthProfilesByUserIdUseCase(event.userId),
      emit,
      (data) => HealthProfilesLoaded(data),
    );
  }

  Future<void> _onCreateHealthProfile(
    CreateHealthProfileEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    await _executeUseCase<HealthProfile>(
      () => _createHealthProfileUseCase(event.profile),
      emit,
      (data) => HealthProfileCreateSuccess(data),
    );
  }

  Future<void> _onUpdateHealthProfile(
    UpdateHealthProfileEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    await _executeUseCase<HealthProfile>(
      () => _updateHealthProfileUseCase(
        UpdateHealthProfileParams(id: event.id, profile: event.profile),
      ),
      emit,
      (data) => HealthProfileUpdateSuccess(data),
    );
  }

  Future<void> _onDeleteHealthProfile(
    DeleteHealthProfileEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    emit(const HealthProfileLoading());
    try {
      final response = await _deleteHealthProfileUseCase(event.id);
      if (response.success) {
        emit(const HealthProfileDeleteSuccess());
      } else {
        emit(HealthProfileError(response.message));
      }
    } catch (e) {
      emit(HealthProfileError(_extractErrorMessage(e)));
    }
  }

  Future<void> _executeUseCase<T>(
    Future<dynamic> Function() useCaseCall,
    Emitter<HealthProfileState> emit,
    HealthProfileState Function(T data) onSuccess,
  ) async {
    emit(const HealthProfileLoading());
    try {
      final response = await useCaseCall();
      if (response.success && response.data != null) {
        emit(onSuccess(response.data as T));
      } else {
        emit(HealthProfileError(response.message));
      }
    } catch (e) {
      emit(HealthProfileError(_extractErrorMessage(e)));
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error.toString().contains('Exception:')) {
      return error.toString().replaceAll('Exception:', '').trim();
    }
    return error.toString();
  }
}

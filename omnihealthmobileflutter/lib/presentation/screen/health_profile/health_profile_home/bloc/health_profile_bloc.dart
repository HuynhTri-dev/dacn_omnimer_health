import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/create_health_profile.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/delete_health_profile.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_health_profile_by_id.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_health_profiles.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_health_profiles_by_user_id.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_latest_health_profile.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/update_health_profile.dart';
import 'health_profile_event.dart';
import 'health_profile_state.dart';

class HealthProfileBloc extends Bloc<HealthProfileEvent, HealthProfileState> {
  final GetHealthProfilesUseCase _getHealthProfilesUseCase;
  final GetHealthProfileByIdUseCase _getHealthProfileByIdUseCase;
  final GetLatestHealthProfileUseCase _getLatestHealthProfileUseCase;
  final GetHealthProfilesByUserIdUseCase _getHealthProfilesByUserIdUseCase;
  final CreateHealthProfileUseCase _createHealthProfileUseCase;
  final UpdateHealthProfileUseCase _updateHealthProfileUseCase;
  final DeleteHealthProfileUseCase _deleteHealthProfileUseCase;

  HealthProfileBloc({
    required GetHealthProfilesUseCase getHealthProfilesUseCase,
    required GetHealthProfileByIdUseCase getHealthProfileByIdUseCase,
    required GetLatestHealthProfileUseCase getLatestHealthProfileUseCase,
    required GetHealthProfilesByUserIdUseCase getHealthProfilesByUserIdUseCase,
    required CreateHealthProfileUseCase createHealthProfileUseCase,
    required UpdateHealthProfileUseCase updateHealthProfileUseCase,
    required DeleteHealthProfileUseCase deleteHealthProfileUseCase,
  })  : _getHealthProfilesUseCase = getHealthProfilesUseCase,
        _getHealthProfileByIdUseCase = getHealthProfileByIdUseCase,
        _getLatestHealthProfileUseCase = getLatestHealthProfileUseCase,
        _getHealthProfilesByUserIdUseCase = getHealthProfilesByUserIdUseCase,
        _createHealthProfileUseCase = createHealthProfileUseCase,
        _updateHealthProfileUseCase = updateHealthProfileUseCase,
        _deleteHealthProfileUseCase = deleteHealthProfileUseCase,
        super(const HealthProfileInitial()) {
    on<GetHealthProfilesEvent>(_onGetHealthProfiles);
    on<GetHealthProfileByIdEvent>(_onGetHealthProfileById);
    on<GetLatestHealthProfileEvent>(_onGetLatestHealthProfile);
    on<GetHealthProfilesByUserIdEvent>(_onGetHealthProfilesByUserId);
    on<CreateHealthProfileEvent>(_onCreateHealthProfile);
    on<UpdateHealthProfileEvent>(_onUpdateHealthProfile);
    on<DeleteHealthProfileEvent>(_onDeleteHealthProfile);
  }

  Future<void> _onGetHealthProfiles(
    GetHealthProfilesEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    emit(const HealthProfileLoading());
    try {
      final profiles = await _getHealthProfilesUseCase();
      emit(HealthProfilesLoaded(profiles));
    } catch (e) {
      emit(HealthProfileError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onGetHealthProfileById(
    GetHealthProfileByIdEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    emit(const HealthProfileLoading());
    try {
      final profile = await _getHealthProfileByIdUseCase(event.id);
      emit(HealthProfileLoaded(profile));
    } catch (e) {
      emit(HealthProfileError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onGetLatestHealthProfile(
    GetLatestHealthProfileEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    emit(const HealthProfileLoading());
    try {
      final profile = await _getLatestHealthProfileUseCase();
      emit(HealthProfileLoaded(profile));
    } catch (e) {
      emit(HealthProfileError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onGetHealthProfilesByUserId(
    GetHealthProfilesByUserIdEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    emit(const HealthProfileLoading());
    try {
      final profiles = await _getHealthProfilesByUserIdUseCase(event.userId);
      emit(HealthProfilesLoaded(profiles));
    } catch (e) {
      emit(HealthProfileError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onCreateHealthProfile(
    CreateHealthProfileEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    emit(const HealthProfileLoading());
    try {
      final profile = await _createHealthProfileUseCase(event.profile);
      emit(HealthProfileCreateSuccess(profile));
    } catch (e) {
      emit(HealthProfileError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onUpdateHealthProfile(
    UpdateHealthProfileEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    emit(const HealthProfileLoading());
    try {
      final profile = await _updateHealthProfileUseCase(event.id, event.profile);
      emit(HealthProfileUpdateSuccess(profile));
    } catch (e) {
      emit(HealthProfileError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onDeleteHealthProfile(
    DeleteHealthProfileEvent event,
    Emitter<HealthProfileState> emit,
  ) async {
    emit(const HealthProfileLoading());
    try {
      await _deleteHealthProfileUseCase(event.id);
      emit(const HealthProfileDeleteSuccess());
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
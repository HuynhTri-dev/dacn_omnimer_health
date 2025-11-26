import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/create_health_profile.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_health_profile_by_id.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/update_health_profile.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_from/bloc/health_profile_form_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_from/bloc/health_profile_form_state.dart';

/// BLoC quản lý form tạo/cập nhật Health Profile
/// - Nếu có profileId: Load profile và cho phép update
/// - Nếu không có profileId: Tạo profile mới
class HealthProfileFormBloc
    extends Bloc<HealthProfileFormEvent, HealthProfileFormState> {
  final GetHealthProfileByIdUseCase getHealthProfileByIdUseCase;
  final CreateHealthProfileUseCase createHealthProfileUseCase;
  final UpdateHealthProfileUseCase updateHealthProfileUseCase;

  HealthProfileFormBloc({
    required this.getHealthProfileByIdUseCase,
    required this.createHealthProfileUseCase,
    required this.updateHealthProfileUseCase,
  }) : super(HealthProfileFormInitial()) {
    on<LoadHealthProfileFormEvent>(_onLoadHealthProfileForm);
    on<SubmitHealthProfileFormEvent>(_onSubmitHealthProfileForm);
  }

  /// Load profile nếu có ID (update mode)
  Future<void> _onLoadHealthProfileForm(
    LoadHealthProfileFormEvent event,
    Emitter<HealthProfileFormState> emit,
  ) async {
    if (event.profileId == null) {
      // Create mode
      emit(HealthProfileFormLoaded(profile: null));
      return;
    }

    // Update mode - load existing profile
    emit(HealthProfileFormLoading());

    final response = await getHealthProfileByIdUseCase(event.profileId!);

    if (response.success && response.data != null) {
      emit(HealthProfileFormLoaded(profile: response.data));
    } else {
      emit(HealthProfileFormError(message: response.message));
    }
  }

  /// Submit form (create hoặc update)
  Future<void> _onSubmitHealthProfileForm(
    SubmitHealthProfileFormEvent event,
    Emitter<HealthProfileFormState> emit,
  ) async {
    emit(HealthProfileFormSubmitting());

    final profile = event.profile;

    // Nếu có ID => Update, không có ID => Create
    if (profile.id != null) {
      final response = await updateHealthProfileUseCase(
        UpdateHealthProfileParams(id: profile.id!, profile: profile),
      );

      if (response.success) {
        emit(HealthProfileFormSuccess(profile: response.data!, isUpdate: true));
      } else {
        emit(HealthProfileFormError(message: response.message));
      }
    } else {
      final response = await createHealthProfileUseCase(profile);

      if (response.success) {
        emit(
          HealthProfileFormSuccess(profile: response.data!, isUpdate: false),
        );
      } else {
        emit(HealthProfileFormError(message: response.message));
      }
    }
  }
}

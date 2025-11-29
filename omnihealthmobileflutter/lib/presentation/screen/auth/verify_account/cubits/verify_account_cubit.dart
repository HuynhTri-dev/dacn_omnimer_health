import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/verification_status_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/get_verification_status_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/request_change_email_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/resend_verification_email_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/send_verification_email_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/verify_account/cubits/verify_account_state.dart';

/// Cubit for managing verify account screen state
class VerifyAccountCubit extends Cubit<VerifyAccountState> {
  final GetVerificationStatusUseCase getVerificationStatusUseCase;
  final SendVerificationEmailUseCase sendVerificationEmailUseCase;
  final ResendVerificationEmailUseCase resendVerificationEmailUseCase;
  final RequestChangeEmailUseCase requestChangeEmailUseCase;

  VerificationStatusEntity? _currentStatus;

  VerifyAccountCubit({
    required this.getVerificationStatusUseCase,
    required this.sendVerificationEmailUseCase,
    required this.resendVerificationEmailUseCase,
    required this.requestChangeEmailUseCase,
  }) : super(const VerifyAccountInitial());

  /// Get current verification status from cache
  VerificationStatusEntity? get currentStatus => _currentStatus;

  /// Load verification status from API
  Future<void> loadVerificationStatus() async {
    emit(const VerifyAccountLoading(loadingMessage: 'Đang tải...'));

    final response = await getVerificationStatusUseCase(NoParams());

    if (response.success && response.data != null) {
      _currentStatus = response.data;
      emit(VerifyAccountLoaded(status: response.data!));
    } else {
      emit(VerifyAccountError(
        message: response.message.isNotEmpty
            ? response.message
            : 'Không thể tải trạng thái xác thực',
      ));
    }
  }

  /// Send verification email
  Future<void> sendVerificationEmail() async {
    emit(const VerifyAccountEmailSending());

    final response = await sendVerificationEmailUseCase(NoParams());

    if (response.success) {
      emit(VerifyAccountEmailSent(
        message: response.data?.isNotEmpty == true
            ? response.data!
            : 'Email xác thực đã được gửi!',
        status: _currentStatus,
      ));

      // Reload status after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      await loadVerificationStatus();
    } else {
      emit(VerifyAccountError(
        message: response.message.isNotEmpty
            ? response.message
            : 'Không thể gửi email xác thực',
        previousStatus: _currentStatus,
      ));
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    emit(const VerifyAccountEmailSending());

    final response = await resendVerificationEmailUseCase(NoParams());

    if (response.success) {
      emit(VerifyAccountEmailSent(
        message: response.data?.isNotEmpty == true
            ? response.data!
            : 'Email xác thực đã được gửi lại!',
        status: _currentStatus,
      ));

      // Reload status after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      await loadVerificationStatus();
    } else {
      emit(VerifyAccountError(
        message: response.message.isNotEmpty
            ? response.message
            : 'Không thể gửi lại email xác thực',
        previousStatus: _currentStatus,
      ));
    }
  }

  /// Request change email
  Future<void> requestChangeEmail(String newEmail) async {
    // Validate email
    if (newEmail.isEmpty) {
      emit(VerifyAccountError(
        message: 'Vui lòng nhập địa chỉ email mới',
        previousStatus: _currentStatus,
      ));
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(newEmail)) {
      emit(VerifyAccountError(
        message: 'Địa chỉ email không hợp lệ',
        previousStatus: _currentStatus,
      ));
      return;
    }

    emit(const VerifyAccountChangeEmailSending());

    final response = await requestChangeEmailUseCase(
      RequestChangeEmailParams(newEmail: newEmail),
    );

    if (response.success) {
      emit(VerifyAccountChangeEmailSent(
        message: response.data?.isNotEmpty == true
            ? response.data!
            : 'Yêu cầu đổi email đã được gửi!',
      ));

      // Reload status after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      await loadVerificationStatus();
    } else {
      emit(VerifyAccountError(
        message: response.message.isNotEmpty
            ? response.message
            : 'Không thể gửi yêu cầu đổi email',
        previousStatus: _currentStatus,
      ));
    }
  }

  /// Reset to loaded state with current status
  void resetToLoaded() {
    if (_currentStatus != null) {
      emit(VerifyAccountLoaded(status: _currentStatus!));
    } else {
      emit(const VerifyAccountInitial());
    }
  }
}


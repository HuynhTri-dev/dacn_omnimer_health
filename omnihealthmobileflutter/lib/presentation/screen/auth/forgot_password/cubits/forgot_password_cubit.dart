import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/request_password_reset_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/verify_reset_code_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/reset_password_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/resend_reset_code_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/forgot_password/cubits/forgot_password_state.dart';

/// Cubit for managing forgot password flow
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final RequestPasswordResetUseCase requestPasswordResetUseCase;
  final VerifyResetCodeUseCase verifyResetCodeUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final ResendResetCodeUseCase resendResetCodeUseCase;

  String? _currentEmail;
  String? _resetToken;

  ForgotPasswordCubit({
    required this.requestPasswordResetUseCase,
    required this.verifyResetCodeUseCase,
    required this.resetPasswordUseCase,
    required this.resendResetCodeUseCase,
  }) : super(const ForgotPasswordInitial());

  /// Get current email
  String? get currentEmail => _currentEmail;

  /// Get reset token
  String? get resetToken => _resetToken;

  /// Step 1: Request password reset
  Future<void> requestPasswordReset(String email) async {
    emit(const ForgotPasswordLoading(step: ForgotPasswordStep.enterEmail));

    try {
      final response = await requestPasswordResetUseCase.call(email);

      if (response.success && response.data != null) {
        if (response.data!.requireEmailVerification) {
          emit(ForgotPasswordError(
            message: response.message.isNotEmpty
                ? response.message
                : 'Email chưa được xác thực. Vui lòng xác thực email trước.',
            step: ForgotPasswordStep.enterEmail,
            requireEmailVerification: true,
          ));
        } else if (response.data!.success) {
          _currentEmail = email;
          emit(ForgotPasswordCodeSent(
            email: email,
            message: response.message.isNotEmpty
                ? response.message
                : 'Mã khôi phục đã được gửi đến email của bạn.',
          ));
        } else {
          emit(ForgotPasswordError(
            message: response.message.isNotEmpty
                ? response.message
                : 'Có lỗi xảy ra',
            step: ForgotPasswordStep.enterEmail,
          ));
        }
      } else {
        // Even if user not found, show generic success message for security
        _currentEmail = email;
        emit(ForgotPasswordCodeSent(
          email: email,
          message: response.message.isNotEmpty
              ? response.message
              : 'Nếu email tồn tại trong hệ thống, bạn sẽ nhận được mã khôi phục.',
        ));
      }
    } catch (e) {
      emit(ForgotPasswordError(
        message: 'Có lỗi xảy ra: ${e.toString()}',
        step: ForgotPasswordStep.enterEmail,
      ));
    }
  }

  /// Step 2: Verify reset code
  Future<void> verifyResetCode(String code) async {
    if (_currentEmail == null) {
      emit(const ForgotPasswordError(
        message: 'Vui lòng nhập email trước',
        step: ForgotPasswordStep.enterEmail,
      ));
      return;
    }

    emit(const ForgotPasswordLoading(step: ForgotPasswordStep.enterCode));

    try {
      final response =
          await verifyResetCodeUseCase.call(_currentEmail!, code);

      if (response.success && response.data != null) {
        _resetToken = response.data;
        emit(ForgotPasswordCodeVerified(
          email: _currentEmail!,
          resetToken: response.data!,
        ));
      } else {
        emit(ForgotPasswordError(
          message: response.message.isNotEmpty
              ? response.message
              : 'Mã xác thực không hợp lệ',
          step: ForgotPasswordStep.enterCode,
        ));
      }
    } catch (e) {
      emit(ForgotPasswordError(
        message: 'Có lỗi xảy ra: ${e.toString()}',
        step: ForgotPasswordStep.enterCode,
      ));
    }
  }

  /// Step 3: Reset password
  Future<void> resetPassword(String newPassword) async {
    if (_resetToken == null) {
      emit(const ForgotPasswordError(
        message: 'Token không hợp lệ. Vui lòng thử lại từ đầu.',
        step: ForgotPasswordStep.enterNewPassword,
      ));
      return;
    }

    emit(const ForgotPasswordLoading(step: ForgotPasswordStep.enterNewPassword));

    try {
      final response =
          await resetPasswordUseCase.call(_resetToken!, newPassword);

      if (response.success) {
        _currentEmail = null;
        _resetToken = null;
        emit(ForgotPasswordSuccess(
          message: response.message.isNotEmpty
              ? response.message
              : 'Mật khẩu đã được đặt lại thành công.',
        ));
      } else {
        emit(ForgotPasswordError(
          message: response.message.isNotEmpty
              ? response.message
              : 'Không thể đặt lại mật khẩu',
          step: ForgotPasswordStep.enterNewPassword,
        ));
      }
    } catch (e) {
      emit(ForgotPasswordError(
        message: 'Có lỗi xảy ra: ${e.toString()}',
        step: ForgotPasswordStep.enterNewPassword,
      ));
    }
  }

  /// Resend reset code
  Future<void> resendResetCode() async {
    if (_currentEmail == null) {
      emit(const ForgotPasswordError(
        message: 'Vui lòng nhập email trước',
        step: ForgotPasswordStep.enterEmail,
      ));
      return;
    }

    emit(const ForgotPasswordLoading(step: ForgotPasswordStep.enterCode));

    try {
      final response = await resendResetCodeUseCase.call(_currentEmail!);

      if (response.success && response.data != null) {
        if (response.data!.requireEmailVerification) {
          emit(ForgotPasswordError(
            message: response.message.isNotEmpty
                ? response.message
                : 'Email chưa được xác thực. Vui lòng xác thực email trước.',
            step: ForgotPasswordStep.enterCode,
            requireEmailVerification: true,
          ));
        } else if (response.data!.success) {
          emit(ForgotPasswordCodeResent(
            email: _currentEmail!,
            message: response.message.isNotEmpty
                ? response.message
                : 'Mã mới đã được gửi đến email của bạn.',
          ));
        }
      } else {
        emit(ForgotPasswordError(
          message: response.message.isNotEmpty
              ? response.message
              : 'Không thể gửi lại mã',
          step: ForgotPasswordStep.enterCode,
        ));
      }
    } catch (e) {
      emit(ForgotPasswordError(
        message: 'Có lỗi xảy ra: ${e.toString()}',
        step: ForgotPasswordStep.enterCode,
      ));
    }
  }

  /// Reset to initial state
  void reset() {
    _currentEmail = null;
    _resetToken = null;
    emit(const ForgotPasswordInitial());
  }

  /// Go back to email step
  void goBackToEmail() {
    _resetToken = null;
    emit(const ForgotPasswordInitial());
  }

  /// Go back to code step
  void goBackToCode() {
    if (_currentEmail != null) {
      _resetToken = null;
      emit(ForgotPasswordCodeSent(
        email: _currentEmail!,
        message: 'Nhập lại mã xác thực',
      ));
    } else {
      emit(const ForgotPasswordInitial());
    }
  }
}

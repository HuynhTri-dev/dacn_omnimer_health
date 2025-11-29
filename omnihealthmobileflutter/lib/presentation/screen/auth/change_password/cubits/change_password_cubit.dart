import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/change_password_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/change_password/cubits/change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePasswordUseCase changePasswordUseCase;

  ChangePasswordCubit({required this.changePasswordUseCase})
      : super(ChangePasswordInitial());

  /// Change password with current and new password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(ChangePasswordLoading());

    try {
      final response = await changePasswordUseCase.call(
        ChangePasswordParams(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );

      if (response.success) {
        emit(ChangePasswordSuccess(
          message: response.message.isNotEmpty
              ? response.message
              : 'Thay đổi mật khẩu thành công',
        ));
      } else {
        emit(ChangePasswordError(
          message: response.message.isNotEmpty
              ? response.message
              : 'Thay đổi mật khẩu thất bại',
        ));
      }
    } catch (e) {
      emit(ChangePasswordError(
        message: 'Đã có lỗi xảy ra: ${e.toString()}',
      ));
    }
  }

  /// Reset state to initial
  void reset() {
    emit(ChangePasswordInitial());
  }
}


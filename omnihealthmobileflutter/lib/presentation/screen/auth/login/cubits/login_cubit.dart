import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/login_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/login/cubits/login_state.dart';

// ==================== CUBIT ====================
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;
  final AuthenticationBloc authenticationBloc;

  LoginCubit({required this.loginUseCase, required this.authenticationBloc})
    : super(LoginInitial());

  Future<void> login({
    required String email,
    required String password,
    bool rememberPassword = false,
  }) async {
    emit(LoginLoading());

    try {
      final loginEntity = LoginEntity(email: email, password: password);

      final response = await loginUseCase.call(loginEntity);

      if (response.success && response.data != null) {
        // TODO: Implement remember password logic
        // if (rememberPassword) {
        //   await _saveCredentials(email, password);
        // } else {
        //   await _clearSavedCredentials();
        // }

        // Cập nhật authentication bloc
        authenticationBloc.add(AuthenticationLoggedIn(response.data!.user));

        emit(LoginSuccess(response.data!));
      } else {
        emit(LoginFailure(response.message));
      }
    } catch (e) {
      emit(LoginFailure('Có lỗi xảy ra: ${e.toString()}'));
    }
  }

  // TODO: Implement remember password functions
  // Future<void> _saveCredentials(String email, String password) async {
  //   // Save to secure storage
  // }
  //
  // Future<void> _clearSavedCredentials() async {
  //   // Clear from secure storage
  // }
  //
  // Future<Map<String, String>?> getSavedCredentials() async {
  //   // Get from secure storage
  //   return null;
  // }

  void reset() {
    emit(LoginInitial());
  }
}

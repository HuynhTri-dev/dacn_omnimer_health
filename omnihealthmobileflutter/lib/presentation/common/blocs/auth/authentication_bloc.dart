import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/get_auth_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/logout_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_event.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_state.dart';

// ==================== BLOC ====================
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final GetAuthUseCase getAuthUseCase;
  final LogoutUseCase logoutUseCase;

  AuthenticationBloc({
    required this.getAuthUseCase,
    required this.logoutUseCase,
  }) : super(AuthenticationInitial()) {
    on<AuthenticationStarted>(_onAuthenticationStarted);
    on<AuthenticationLoggedIn>(_onAuthenticationLoggedIn);
    on<AuthenticationLoggedOut>(_onAuthenticationLoggedOut);
  }

  Future<void> _onAuthenticationStarted(
    AuthenticationStarted event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());

    try {
      // Kiểm tra xem user đã login chưa bằng cách gọi getAuth
      final response = await getAuthUseCase.call(NoParams());

      if (response.success && response.data != null) {
        emit(AuthenticationAuthenticated(response.data!));
      } else {
        emit(AuthenticationUnauthenticated());
      }
    } catch (e) {
      emit(AuthenticationUnauthenticated());
    }
  }

  Future<void> _onAuthenticationLoggedIn(
    AuthenticationLoggedIn event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationAuthenticated(event.authEntity));
  }

  Future<void> _onAuthenticationLoggedOut(
    AuthenticationLoggedOut event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      await logoutUseCase.call(NoParams());
      emit(AuthenticationUnauthenticated());
    } catch (e) {
      emit(AuthenticationError('Đăng xuất thất bại: ${e.toString()}'));
    }
  }
}

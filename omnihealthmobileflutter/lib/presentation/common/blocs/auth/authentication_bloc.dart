import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/get_auth_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/logout_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_event.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  // Giả định GetAuthUseCase.call() trả về Future<ApiResponse<UserAuth>>
  final GetAuthUseCase getAuthUseCase;
  final LogoutUseCase logoutUseCase;

  AuthenticationBloc({
    required this.getAuthUseCase,
    required this.logoutUseCase,
  }) : super(AuthenticationInitial()) {
    on<AuthenticationStarted>(_onAuthenticationStarted);
    on<AuthenticationLoggedIn>(_onAuthenticationLoggedIn);
    on<AuthenticationLoggedOut>(_onAuthenticationLoggedOut);
    on<AuthenticationUserUpdated>(_onAuthenticationUserUpdated);
  }

  Future<void> _onAuthenticationStarted(
    AuthenticationStarted event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());

    try {
      // response.data sẽ là UserAuth (Entity)
      final response = await getAuthUseCase.call(NoParams());

      if (response.success && response.data != null) {
        // ĐÃ SỬA: response.data là UserAuth Entity
        emit(AuthenticationAuthenticated(response.data!));
      } else {
        emit(AuthenticationUnauthenticated());
      }
    } catch (e) {
      // Nếu có lỗi xảy ra (ví dụ: mất kết nối, token hết hạn), chuyển sang trạng thái Unauthenticated
      emit(AuthenticationUnauthenticated());
    }
  }

  Future<void> _onAuthenticationLoggedIn(
    AuthenticationLoggedIn event,
    Emitter<AuthenticationState> emit,
  ) async {
    // ĐÃ SỬA: event.user là UserAuth Entity
    emit(AuthenticationAuthenticated(event.user));
  }

  Future<void> _onAuthenticationLoggedOut(
    AuthenticationLoggedOut event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      await logoutUseCase.call(NoParams());
      emit(AuthenticationUnauthenticated());
    } catch (e) {
      // Thông báo lỗi nếu việc logout trên server/data source thất bại
      emit(AuthenticationError('Đăng xuất thất bại: ${e.toString()}'));
    }
  }

  Future<void> _onAuthenticationUserUpdated(
    AuthenticationUserUpdated event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationAuthenticated(event.user));
  }
}

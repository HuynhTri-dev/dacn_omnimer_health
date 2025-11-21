import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/auth_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/register_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/role/get_roles_for_select_box_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/cubits/register_state.dart';

// ==================== CUBIT ====================
class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase registerUseCase;
  final AuthenticationBloc authenticationBloc;
  final GetRolesForSelectBoxUseCase getRolesForSelectBoxUseCase;

  RegisterCubit({
    required this.registerUseCase,
    required this.authenticationBloc,
    required this.getRolesForSelectBoxUseCase,
  }) : super(RegisterInitial());

  /// Load danh sách vai trò từ API
  Future<void> loadRoles() async {
    emit(RolesLoading());

    try {
      final response = await getRolesForSelectBoxUseCase.call(NoParams());

      if (response.success && response.data != null) {
        emit(RolesLoaded(response.data!));
      } else {
        emit(RolesLoadFailure(response.message));
      }
    } catch (e) {
      emit(RolesLoadFailure('Có lỗi xảy ra: ${e.toString()}'));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullname,
    String? birthday,
    GenderEnum? gender,
    List<String>? roleIds,
    File? image,
  }) async {
    emit(RegisterLoading());

    try {
      final registerEntity = RegisterEntity(
        email: email,
        password: password,
        fullname: fullname,
        birthday: birthday,
        gender: gender,
        roleIds: roleIds,
        image: image,
      );

      final response = await registerUseCase.call(registerEntity);

      if (response.success && response.data != null) {
        // Cập nhật authentication bloc để tự động đăng nhập
        authenticationBloc.add(AuthenticationLoggedIn(response.data!.user));

        emit(RegisterSuccess(response.data!));
      } else {
        emit(RegisterFailure(response.message));
      }
    } catch (e) {
      emit(RegisterFailure('Có lỗi xảy ra: ${e.toString()}'));
    }
  }

  void reset() {
    emit(RegisterInitial());
  }
}

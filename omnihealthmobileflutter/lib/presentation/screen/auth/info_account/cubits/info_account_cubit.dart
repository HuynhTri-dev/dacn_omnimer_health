import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/core/constants/storage_constant.dart';
import 'package:omnihealthmobileflutter/data/models/auth/auth_model.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/auth_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/user_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/update_user_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/info_account/cubits/info_account_state.dart';
import 'package:omnihealthmobileflutter/services/shared_preferences_service.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

class InfoAccountCubit extends Cubit<InfoAccountState> {
  final SharedPreferencesService _sharedPreferencesService;
  final UpdateUserUseCase _updateUserUseCase;
  final AuthenticationBloc _authenticationBloc;

  InfoAccountCubit({
    required SharedPreferencesService sharedPreferencesService,
    required UpdateUserUseCase updateUserUseCase,
    required AuthenticationBloc authenticationBloc,
  }) : _sharedPreferencesService = sharedPreferencesService,
       _updateUserUseCase = updateUserUseCase,
       _authenticationBloc = authenticationBloc,
       super(InfoAccountInitial());

  Future<void> loadUserInfo() async {
    emit(InfoAccountLoading());
    try {
      final userJson = await _sharedPreferencesService.get<String>(
        StorageConstant.kUserInfoKey,
      );

      logger.i("User Json form Storage: ${userJson}");

      if (userJson != null) {
        // Check for corrupted data (common mistake: saving .toString() instead of jsonEncode)
        if (userJson.startsWith("Instance of")) {
          logger.e("Corrupt user data found in storage: $userJson");
          emit(
            const InfoAccountError(
              "Dữ liệu lỗi. Vui lòng đăng xuất và đăng nhập lại.",
            ),
          );
          return;
        }

        try {
          final userMap = jsonDecode(userJson);

          // Use UserAuthModel to parse data from storage
          final userAuthModel = UserAuthModel.fromJson(userMap);

          // Convert UserAuthModel to UserEntity for the state
          final userEntity = UserEntity(
            id: userAuthModel.id,
            fullname: userAuthModel.fullname,
            email: userAuthModel.email,
            imageUrl: userAuthModel.imageUrl,
            gender: userAuthModel.gender,
            birthday: userAuthModel.birthday != null
                ? DateTime.tryParse(userAuthModel.birthday!)?.toIso8601String()
                : null,
            roleNames: userAuthModel.roleName,
          );

          emit(InfoAccountLoaded(userEntity));
        } catch (e) {
          logger.e("JSON decode error: $e");
          emit(
            const InfoAccountError(
              "Lỗi đọc dữ liệu người dùng. Vui lòng đăng nhập lại.",
            ),
          );
        }
      } else {
        emit(const InfoAccountError("Không tìm thấy thông tin người dùng"));
      }
    } catch (e) {
      emit(InfoAccountError("Lỗi tải thông tin: ${e.toString()}"));
    }
  }

  Future<void> updateUserInfo({
    required String id,
    String? fullname,
    String? birthday,
    GenderEnum? gender,
    String? imageUrl,
    File? image,
  }) async {
    emit(InfoAccountUpdating());

    // Create a UserEntity with ONLY the allowed fields
    // We explicitly do not set email or roleNames to ensure they are not updated
    final userToUpdate = UserEntity(
      id: id,
      fullname: fullname,
      birthday: birthday,
      gender: gender,
      imageUrl: imageUrl,
      image: image,
    );

    final result = await _updateUserUseCase.call(
      UpdateUserParams(id: id, user: userToUpdate),
    );

    if (result.success && result.data != null) {
      final updatedUser = result.data!;
      logger.i(
        "Updated User from API: id=${updatedUser.id}, imageUrl=${updatedUser.imageUrl}, fullname=${updatedUser.fullname}",
      );

      // Get current user from storage to preserve fields not returned by API (email, roles)
      final currentUserJson = await _sharedPreferencesService.get<String>(
        StorageConstant.kUserInfoKey,
      );
      UserAuthModel? currentUser;
      if (currentUserJson != null) {
        try {
          currentUser = UserAuthModel.fromJson(jsonDecode(currentUserJson));
        } catch (_) {}
      }

      // Merge updated data with current data
      // API returns: id, fullname, birthday, gender, imageUrl
      // API does NOT return: email, roleName (filtered out)
      final userAuthModel = UserAuthModel(
        id: updatedUser.id ?? currentUser?.id ?? id,
        fullname: updatedUser.fullname ?? currentUser?.fullname ?? "",
        email: currentUser?.email, // Preserve email
        imageUrl: updatedUser.imageUrl ?? currentUser?.imageUrl,
        gender: updatedUser.gender ?? currentUser?.gender,
        birthday: updatedUser.birthday ?? currentUser?.birthday,
        roleName: currentUser?.roleName ?? [], // Preserve roles
      );

      logger.i(
        "Saving to SharedPreferences: ${jsonEncode(userAuthModel.toJson())}",
      );
      await _sharedPreferencesService.update(
        StorageConstant.kUserInfoKey,
        jsonEncode(userAuthModel.toJson()),
      );

      // Notify AuthenticationBloc
      // Convert UserEntity to UserAuth
      // Note: UserEntity birthday is String, UserAuth birthday is DateTime
      DateTime? birthdayDt;
      if (userAuthModel.birthday != null) {
        try {
          birthdayDt = DateTime.parse(userAuthModel.birthday!);
        } catch (_) {}
      }

      final userAuth = UserAuth(
        id: userAuthModel.id,
        fullname: userAuthModel.fullname,
        email: userAuthModel.email,
        imageUrl: userAuthModel.imageUrl,
        gender: userAuthModel.gender,
        birthday: birthdayDt,
        roleName: userAuthModel.roleName,
      );

      logger.i(
        "Notifying AuthenticationBloc with UserAuth: imageUrl=${userAuth.imageUrl}",
      );
      _authenticationBloc.add(AuthenticationUserUpdated(userAuth));

      // Update UI with the merged data
      emit(InfoAccountSuccess(userAuthModel.toUserEntity()));
    } else {
      emit(InfoAccountError(result.message));
      // Reload old data to reset UI state
      loadUserInfo();
    }
  }
}

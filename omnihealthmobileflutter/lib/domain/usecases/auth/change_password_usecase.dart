import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import '../base_usecase.dart';

/// Parameters for changing password
class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;

  ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}

/// Handles user password change business logic
class ChangePasswordUseCase
    implements UseCase<ApiResponse<void>, ChangePasswordParams> {
  final AuthRepositoryAbs repository;

  ChangePasswordUseCase(this.repository);

  @override
  Future<ApiResponse<void>> call(ChangePasswordParams params) async {
    // Validate password length
    if (params.newPassword.length < 8) {
      return ApiResponse<void>.error('Mật khẩu mới phải có ít nhất 8 ký tự');
    }

    // Validate passwords are different
    if (params.currentPassword == params.newPassword) {
      return ApiResponse<void>.error(
        'Mật khẩu mới không được trùng với mật khẩu hiện tại',
      );
    }

    return await repository.changePassword(
      params.currentPassword,
      params.newPassword,
    );
  }
}

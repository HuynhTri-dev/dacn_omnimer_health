import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/data/datasources/verification_datasource.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/verification_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/verification_status_entity.dart';

/// Implementation of [VerificationRepositoryAbs]
class VerificationRepositoryImpl implements VerificationRepositoryAbs {
  final VerificationDataSource dataSource;

  VerificationRepositoryImpl({required this.dataSource});

  @override
  Future<ApiResponse<VerificationStatusEntity>> getVerificationStatus() async {
    final response = await dataSource.getVerificationStatus();

    if (response.success && response.data != null) {
      return ApiResponse<VerificationStatusEntity>.success(
        response.data!.toEntity(),
        message: response.message,
      );
    }

    return ApiResponse<VerificationStatusEntity>.error(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to get verification status',
    );
  }

  @override
  Future<ApiResponse<String>> sendVerificationEmail() async {
    final response = await dataSource.sendVerificationEmail();

    if (response.success && response.data != null) {
      return ApiResponse<String>.success(
        response.data!.message,
        message: response.message,
      );
    }

    return ApiResponse<String>.error(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to send verification email',
    );
  }

  @override
  Future<ApiResponse<String>> resendVerificationEmail() async {
    final response = await dataSource.resendVerificationEmail();

    if (response.success && response.data != null) {
      return ApiResponse<String>.success(
        response.data!.message,
        message: response.message,
      );
    }

    return ApiResponse<String>.error(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to resend verification email',
    );
  }

  @override
  Future<ApiResponse<String>> requestChangeEmail(String newEmail) async {
    final response = await dataSource.requestChangeEmail(newEmail);

    if (response.success && response.data != null) {
      return ApiResponse<String>.success(
        response.data!.message,
        message: response.message,
      );
    }

    return ApiResponse<String>.error(
      response.message.isNotEmpty
          ? response.message
          : 'Failed to request email change',
    );
  }
}


import 'package:omnihealthmobileflutter/domain/entities/auth/verification_status_entity.dart';

/// Model for verification status response from API
class VerificationStatusModel extends VerificationStatusEntity {
  const VerificationStatusModel({
    required super.isEmailVerified,
    required super.isPhoneVerified,
    required super.email,
    super.phoneNumber,
  });

  /// Create from JSON response
  factory VerificationStatusModel.fromJson(Map<String, dynamic> json) {
    return VerificationStatusModel(
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  /// Convert to Entity
  VerificationStatusEntity toEntity() {
    return VerificationStatusEntity(
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
      email: email,
      phoneNumber: phoneNumber,
    );
  }

  /// Create a copy with updated fields
  VerificationStatusModel copyWith({
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? email,
    String? phoneNumber,
  }) {
    return VerificationStatusModel(
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

/// Model for send verification email request
class SendVerificationEmailRequest {
  // No parameters needed - userId is taken from auth token

  Map<String, dynamic> toJson() => {};
}

/// Model for request change email
class RequestChangeEmailModel {
  final String newEmail;

  const RequestChangeEmailModel({required this.newEmail});

  Map<String, dynamic> toJson() {
    return {
      'newEmail': newEmail,
    };
  }
}

/// Model for verification action response (send email, resend, etc.)
class VerificationActionResponse {
  final String message;
  final bool success;

  const VerificationActionResponse({
    required this.message,
    this.success = true,
  });

  factory VerificationActionResponse.fromJson(Map<String, dynamic> json) {
    return VerificationActionResponse(
      message: json['message'] as String? ?? '',
      success: true,
    );
  }
}


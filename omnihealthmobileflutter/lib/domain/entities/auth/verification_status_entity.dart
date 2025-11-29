/// Entity representing the verification status of a user account
class VerificationStatusEntity {
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String email;
  final String? phoneNumber;

  const VerificationStatusEntity({
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.email,
    this.phoneNumber,
  });

  /// Check if the account is fully verified
  bool get isFullyVerified => isEmailVerified && isPhoneVerified;

  /// Check if the account has any verification
  bool get hasAnyVerification => isEmailVerified || isPhoneVerified;

  /// Get masked email for display (e.g., "u***@gmail.com")
  String get maskedEmail {
    if (email.isEmpty) return '';
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) {
      return '$username***@$domain';
    }
    
    return '${username[0]}***${username[username.length - 1]}@$domain';
  }

  /// Get masked phone for display (e.g., "***456789")
  String? get maskedPhone {
    if (phoneNumber == null || phoneNumber!.isEmpty) return null;
    if (phoneNumber!.length <= 3) return phoneNumber;
    
    return '***${phoneNumber!.substring(phoneNumber!.length - 6)}';
  }

  @override
  String toString() {
    return 'VerificationStatusEntity(isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, email: $email, phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationStatusEntity &&
        other.isEmailVerified == isEmailVerified &&
        other.isPhoneVerified == isPhoneVerified &&
        other.email == email &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return isEmailVerified.hashCode ^
        isPhoneVerified.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode;
  }
}


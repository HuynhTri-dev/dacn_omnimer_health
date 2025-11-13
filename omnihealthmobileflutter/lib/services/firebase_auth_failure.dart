class FirebaseAuthFailure implements Exception {
  final String message;
  const FirebaseAuthFailure([this.message = "Đã xảy ra lỗi không xác định"]);

  factory FirebaseAuthFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const FirebaseAuthFailure("Email không hợp lệ.");
      case 'user-disabled':
        return const FirebaseAuthFailure("Tài khoản này đã bị khóa.");
      case 'user-not-found':
        return const FirebaseAuthFailure(
          "Không tìm thấy người dùng.",
        ); // nhưng có thể bị Firebase ẩn
      case 'wrong-password':
        return const FirebaseAuthFailure("Sai mật khẩu, vui lòng thử lại.");
      case 'invalid-credentials':
        // Dùng khi Firebase ẩn mã lỗi cụ thể để bảo vệ email enumeration
        return const FirebaseAuthFailure(
          "Mật khoản hoặc tài khoản email không đúng.",
        );
      case 'too-many-requests':
        return const FirebaseAuthFailure(
          "Quá nhiều yêu cầu. Vui lòng thử lại sau.",
        );
      case 'email-already-in-use':
        return const FirebaseAuthFailure("Email này đã được đăng ký.");
      case 'weak-password':
        return const FirebaseAuthFailure(
          "Mật khẩu quá yếu, vui lòng dùng mật khẩu mạnh hơn.",
        );
      case 'operation-not-allowed':
        return const FirebaseAuthFailure(
          "Tính năng chưa được bật. Liên hệ quản trị viên.",
        );
      case 'account-exists-with-different-credential':
        return const FirebaseAuthFailure(
          "Tài khoản đã tồn tại với provider khác.",
        );
      case 'invalid-credential':
        return const FirebaseAuthFailure(
          "Mật khoản hoặc tài khoản email không đúng.",
        );
      case 'invalid-verification-code':
        return const FirebaseAuthFailure("Mã xác thực không hợp lệ.");
      case 'invalid-verification-id':
        return const FirebaseAuthFailure("ID xác thực không hợp lệ.");
      default:
        return const FirebaseAuthFailure();
    }
  }

  @override
  String toString() => message;
}

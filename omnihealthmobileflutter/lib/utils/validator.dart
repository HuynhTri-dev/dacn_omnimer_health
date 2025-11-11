class Validators {
  static String? requiredField<T>(T? v, {String name = 'Trường'}) {
    if (v == null) return '$name không được để trống';

    if (v is String && v.trim().isEmpty) {
      return '$name không được để trống';
    }

    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email không được để trống';
    final r = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!r.hasMatch(v)) return 'Email không hợp lệ';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Mật khẩu là bắt buộc';

    // Ít nhất 8 ký tự
    if (value.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';

    // Regex tương đương Zod strongPasswordRegex
    final pattern = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );

    if (!pattern.hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất một chữ hoa, một chữ thường, một số và một ký tự đặc biệt';
    }

    return null; // hợp lệ
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (v != original) return 'Mật khẩu không khớp';
    return null;
  }

  /// Kiểm tra số học sinh tối đa
  static String? maxStudents(String? value) {
    final required = requiredField(value, name: 'Số học sinh tối đa');
    if (required != null) return required;

    final number = int.tryParse(value!.trim());
    if (number == null || number <= 0)
      return 'Số học sinh phải là số nguyên dương';
    return null;
  }

  /// Kiểm tra học phí cơ bản (optional)
  static String? baseFee(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Optional

    final fee = int.tryParse(value.trim());
    if (fee == null || fee < 0) return 'Học phí phải là số nguyên không âm';
    return null;
  }

  /// Kiểm tra địa chỉ: optional nhưng nếu nhập thì >= 10 ký tự
  static String? address(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    if (value.length > 500) return 'Địa chỉ không được vượt quá 500 ký tự';
    return null;
  }

  /// Kiểm tra số điện thoại: optional nhưng nếu nhập phải 10-11 chữ số
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional

    final pattern = RegExp(r'^\+?[0-9]{8,15}$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  /// Kiểm tra mô tả: optional nhưng nếu nhập >= 10 ký tự
  static String? description(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    if (value.length > 1000) return 'Mô tả không được vượt quá 1000 ký tự';
    return null;
  }

  /// Kiểm tra tên
  static String? name(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    if (value.length > 100) return 'Tên không được vượt quá 100 ký tự';
    return null;
  }

  /// Kiểm tra chức vụ
  static String? position(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    if (value.length > 100) return 'Chức vụ không được vượt quá 100 ký tự';
    return null;
  }

  static String? grade(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Khối lớp không được để trống';
    }

    final v = value.trim();

    // Danh sách các giá trị hợp lệ
    const validGrades = [
      'Mầm non',
      'Lớp lá',
      'Tiểu học',
      'THCS',
      'THPT',
      'Sinh viên',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
    ];

    if (!validGrades.contains(v)) {
      return 'Khối lớp không hợp lệ';
    }

    return null; // hợp lệ
  }
}

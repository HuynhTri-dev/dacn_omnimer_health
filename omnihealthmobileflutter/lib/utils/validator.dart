typedef ValidationFunction<T> = String? Function(T value, {String? name});

/// Class đại diện cho 1 rule xác thực
class ValidationRule<T> {
  final ValidationFunction<T> validator;
  final String? name;

  const ValidationRule(this.validator, {this.name});

  String? validate(T value) => validator(value, name: name);
}

/// Bộ Validators dùng chung
class Validators {
  /// Hàm chạy danh sách rule
  static String? run<T>(T value, List<ValidationRule<T>> validators) {
    for (final rule in validators) {
      final result = rule.validate(value);
      if (result != null) return result;
    }
    return null;
  }

  static String? requiredField<T>(T? v, {String? name}) {
    final fieldName = name ?? 'Trường';
    if (v == null) return '$fieldName không được để trống';
    if (v is String && v.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  static String? email(String? v, {String? name}) {
    final fieldName = name ?? 'Email';
    if (v == null || v.trim().isEmpty) return '$fieldName không được để trống';
    final r = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!r.hasMatch(v)) return '$fieldName không hợp lệ';
    return null;
  }

  static String? password(String? value, {String? name}) {
    final fieldName = name ?? 'Mật khẩu';
    if (value == null || value.isEmpty) return '$fieldName là bắt buộc';
    if (value.length < 8) return '$fieldName phải có ít nhất 8 ký tự';

    final pattern = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );

    if (!pattern.hasMatch(value)) {
      return '$fieldName phải chứa ít nhất một chữ hoa, một chữ thường, một số và một ký tự đặc biệt';
    }
    return null;
  }

  static String? confirmPassword(String? v, String original, {String? name}) {
    final fieldName = name ?? 'Xác nhận mật khẩu';
    if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (v != original) return '$fieldName không khớp';
    return null;
  }

  static String? address(String? value, {String? name}) {
    final fieldName = name ?? 'Địa chỉ';
    if (value == null || value.isEmpty) return null;
    if (value.length > 500) return '$fieldName không được vượt quá 500 ký tự';
    return null;
  }

  static String? phone(String? value, {String? name}) {
    final fieldName = name ?? 'Số điện thoại';
    if (value == null || value.trim().isEmpty) return null;
    final pattern = RegExp(r'^\+?[0-9]{8,15}$');
    if (!pattern.hasMatch(value.trim())) {
      return '$fieldName không hợp lệ';
    }
    return null;
  }

  static String? fullname(String? value, {String? name}) {
    final fieldName = name ?? 'Tên';
    if (value == null || value.isEmpty) return null;
    if (value.length > 100) return '$fieldName không được vượt quá 100 ký tự';
    return null;
  }
}

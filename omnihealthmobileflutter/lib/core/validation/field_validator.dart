/// Hệ thống validation chung cho tất cả các field components
library field_validator;

/// Function signature cho validation
typedef ValidatorFunction<T> = String? Function(T? value);

/// Class đại diện cho một validation rule
class FieldValidator<T> {
  final ValidatorFunction<T> validator;
  final String? fieldName;

  const FieldValidator(this.validator, {this.fieldName});

  /// Thực hiện validation
  String? call(T? value) => validator(value);
}

/// Bộ validators dựng sẵn
class FieldValidators {
  // ==================== VALIDATORS CHUNG ====================

  /// Kiểm tra field bắt buộc
  static FieldValidator<T> required<T>({String? fieldName}) {
    return FieldValidator<T>((value) {
      final name = fieldName ?? 'Trường';
      if (value == null) return '$name không được để trống';

      if (value is String && value.trim().isEmpty) {
        return '$name không được để trống';
      }

      if (value is List && value.isEmpty) {
        return '$name phải có ít nhất một lựa chọn';
      }

      return null;
    }, fieldName: fieldName);
  }

  /// Kiểm tra độ dài tối thiểu (cho String)
  static FieldValidator<String> minLength(int min, {String? fieldName}) {
    return FieldValidator<String>((value) {
      final name = fieldName ?? 'Trường';
      if (value == null || value.isEmpty) return null;
      if (value.length < min) {
        return '$name phải có ít nhất $min ký tự';
      }
      return null;
    }, fieldName: fieldName);
  }

  /// Kiểm tra độ dài tối đa (cho String)
  static FieldValidator<String> maxLength(int max, {String? fieldName}) {
    return FieldValidator<String>((value) {
      final name = fieldName ?? 'Trường';
      if (value == null || value.isEmpty) return null;
      if (value.length > max) {
        return '$name không được vượt quá $max ký tự';
      }
      return null;
    }, fieldName: fieldName);
  }

  /// Kiểm tra pattern regex
  static FieldValidator<String> pattern(
    RegExp regex,
    String message, {
    String? fieldName,
  }) {
    return FieldValidator<String>((value) {
      if (value == null || value.isEmpty) return null;
      if (!regex.hasMatch(value)) return message;
      return null;
    }, fieldName: fieldName);
  }

  // ==================== VALIDATORS CỤ THỂ ====================

  /// Validator cho email
  static FieldValidator<String> email({String? fieldName}) {
    return FieldValidator<String>((value) {
      final name = fieldName ?? 'Email';
      if (value == null || value.trim().isEmpty) return null;

      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(value)) {
        return '$name không hợp lệ';
      }
      return null;
    }, fieldName: fieldName);
  }

  /// Validator cho mật khẩu
  static FieldValidator<String> password({String? fieldName}) {
    return FieldValidator<String>((value) {
      final name = fieldName ?? 'Mật khẩu';
      if (value == null || value.isEmpty) return null;

      if (value.length < 8) {
        return '$name phải có ít nhất 8 ký tự';
      }

      final pattern = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
      );

      if (!pattern.hasMatch(value)) {
        return '$name phải chứa ít nhất một chữ hoa, một chữ thường, một số và một ký tự đặc biệt';
      }
      return null;
    }, fieldName: fieldName);
  }

  /// Validator cho xác nhận mật khẩu
  static FieldValidator<String> confirmPassword(
    String originalPassword, {
    String? fieldName,
  }) {
    return FieldValidator<String>((value) {
      final name = fieldName ?? 'Xác nhận mật khẩu';
      if (value == null || value.isEmpty) return null;
      if (value != originalPassword) {
        return '$name không khớp';
      }
      return null;
    }, fieldName: fieldName);
  }

  /// Validator cho số điện thoại
  static FieldValidator<String> phone({String? fieldName}) {
    return FieldValidator<String>((value) {
      final name = fieldName ?? 'Số điện thoại';
      if (value == null || value.trim().isEmpty) return null;

      final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
      if (!phoneRegex.hasMatch(value.trim())) {
        return '$name không hợp lệ';
      }
      return null;
    }, fieldName: fieldName);
  }

  /// Validator cho họ tên
  static FieldValidator<String> fullname({String? fieldName}) {
    return FieldValidator<String>((value) {
      final name = fieldName ?? 'Họ tên';
      if (value == null || value.isEmpty) return null;

      if (value.length < 2) {
        return '$name phải có ít nhất 2 ký tự';
      }

      if (value.length > 100) {
        return '$name không được vượt quá 100 ký tự';
      }
      return null;
    }, fieldName: fieldName);
  }

  /// Validator cho địa chỉ
  static FieldValidator<String> address({String? fieldName}) {
    return FieldValidator<String>((value) {
      final name = fieldName ?? 'Địa chỉ';
      if (value == null || value.isEmpty) return null;

      if (value.length > 500) {
        return '$name không được vượt quá 500 ký tự';
      }
      return null;
    }, fieldName: fieldName);
  }

  // ==================== VALIDATORS CHO DATE ====================

  /// Kiểm tra ngày không được trong quá khứ
  static FieldValidator<DateTime> notInPast({String? fieldName}) {
    return FieldValidator<DateTime>((value) {
      final name = fieldName ?? 'Ngày';
      if (value == null) return null;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDate = DateTime(value.year, value.month, value.day);

      if (selectedDate.isBefore(today)) {
        return '$name không được là ngày trong quá khứ';
      }
      return null;
    }, fieldName: fieldName);
  }

  /// Kiểm tra ngày không được trong tương lai
  static FieldValidator<DateTime> notInFuture({String? fieldName}) {
    return FieldValidator<DateTime>((value) {
      final name = fieldName ?? 'Ngày';
      if (value == null) return null;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDate = DateTime(value.year, value.month, value.day);

      if (selectedDate.isAfter(today)) {
        return '$name không được là ngày trong tương lai';
      }
      return null;
    }, fieldName: fieldName);
  }

  /// Kiểm tra ngày trong khoảng
  static FieldValidator<DateTime> dateRange(
    DateTime minDate,
    DateTime maxDate, {
    String? fieldName,
  }) {
    return FieldValidator<DateTime>((value) {
      final name = fieldName ?? 'Ngày';
      if (value == null) return null;

      if (value.isBefore(minDate)) {
        return '$name phải sau ${_formatDate(minDate)}';
      }

      if (value.isAfter(maxDate)) {
        return '$name phải trước ${_formatDate(maxDate)}';
      }
      return null;
    }, fieldName: fieldName);
  }

  /// Kiểm tra tuổi tối thiểu
  static FieldValidator<DateTime> minAge(int age, {String? fieldName}) {
    return FieldValidator<DateTime>((value) {
      final name = fieldName ?? 'Ngày sinh';
      if (value == null) return null;

      final now = DateTime.now();
      final minDate = DateTime(now.year - age, now.month, now.day);

      if (value.isAfter(minDate)) {
        return '$name phải từ $age tuổi trở lên';
      }
      return null;
    }, fieldName: fieldName);
  }

  /// Kiểm tra tuổi tối đa
  static FieldValidator<DateTime> maxAge(int age, {String? fieldName}) {
    return FieldValidator<DateTime>((value) {
      final name = fieldName ?? 'Ngày sinh';
      if (value == null) return null;

      final now = DateTime.now();
      final maxDate = DateTime(now.year - age, now.month, now.day);

      if (value.isBefore(maxDate)) {
        return '$name không được quá $age tuổi';
      }
      return null;
    }, fieldName: fieldName);
  }

  // ==================== VALIDATORS CHO LIST ====================

  /// Kiểm tra số lượng tối thiểu
  static FieldValidator<List<T>> minItems<T>(int min, {String? fieldName}) {
    return FieldValidator<List<T>>((value) {
      final name = fieldName ?? 'Danh sách';
      if (value == null || value.isEmpty) return null;

      if (value.length < min) {
        return '$name phải có ít nhất $min mục';
      }
      return null;
    }, fieldName: fieldName);
  }

  /// Kiểm tra số lượng tối đa
  static FieldValidator<List<T>> maxItems<T>(int max, {String? fieldName}) {
    return FieldValidator<List<T>>((value) {
      final name = fieldName ?? 'Danh sách';
      if (value == null || value.isEmpty) return null;

      if (value.length > max) {
        return '$name không được vượt quá $max mục';
      }
      return null;
    }, fieldName: fieldName);
  }

  // ==================== VALIDATORS CHO NUMBER ====================

  /// Kiểm tra giá trị tối thiểu
  static FieldValidator<num> min(num minValue, {String? fieldName}) {
    return FieldValidator<num>((value) {
      final name = fieldName ?? 'Giá trị';
      if (value == null) return null;

      if (value < minValue) {
        return '$name phải lớn hơn hoặc bằng $minValue';
      }
      return null;
    }, fieldName: fieldName);
  }

  /// Kiểm tra giá trị tối đa
  static FieldValidator<num> max(num maxValue, {String? fieldName}) {
    return FieldValidator<num>((value) {
      final name = fieldName ?? 'Giá trị';
      if (value == null) return null;

      if (value > maxValue) {
        return '$name phải nhỏ hơn hoặc bằng $maxValue';
      }
      return null;
    }, fieldName: fieldName);
  }

  /// Kiểm tra giá trị trong khoảng
  static FieldValidator<num> range(
    num minValue,
    num maxValue, {
    String? fieldName,
  }) {
    return FieldValidator<num>((value) {
      final name = fieldName ?? 'Giá trị';
      if (value == null) return null;

      if (value < minValue || value > maxValue) {
        return '$name phải trong khoảng $minValue - $maxValue';
      }
      return null;
    }, fieldName: fieldName);
  }

  // ==================== UTILITY ====================

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Tạo validator tùy chỉnh
  static FieldValidator<T> custom<T>(
    ValidatorFunction<T> validator, {
    String? fieldName,
  }) {
    return FieldValidator<T>(validator, fieldName: fieldName);
  }
}

/// Helper để chạy danh sách validators
class ValidationRunner {
  /// Chạy tất cả validators và trả về lỗi đầu tiên
  static String? validate<T>(T? value, List<FieldValidator<T>> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }

  /// Chạy tất cả validators và trả về tất cả lỗi
  static List<String> validateAll<T>(
    T? value,
    List<FieldValidator<T>> validators,
  ) {
    final errors = <String>[];
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) errors.add(error);
    }
    return errors;
  }
}

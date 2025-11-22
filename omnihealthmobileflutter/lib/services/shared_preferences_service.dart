import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferencesService
/// Quản lý lưu trữ dữ liệu cục bộ (non-sensitive) bằng SharedPreferences.
/// — Dùng để lưu: user info, settings, flags, theme, cached data,...
class SharedPreferencesService {
  // SharedPreferences instance
  SharedPreferences? _prefs;

  /// Khởi tạo trước khi sử dụng
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Tạo hoặc ghi mới dữ liệu
  Future<void> create(String key, Object value) async {
    if (_prefs == null) await init();

    if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    } else if (value is List<String>) {
      await _prefs!.setStringList(key, value);
    } else {
      throw Exception("Unsupported type for SharedPreferences");
    }
  }

  /// Lấy dữ liệu theo key
  Future<T?> get<T>(String key) async {
    if (_prefs == null) await init();
    return _prefs!.get(key) as T?;
  }

  /// Cập nhật dữ liệu (thực tế write() đã tự động ghi đè nếu key tồn tại)
  Future<void> update(String key, Object newValue) async {
    await create(key, newValue);
  }

  /// Xóa 1 key
  Future<void> delete(String key) async {
    if (_prefs == null) await init();
    await _prefs!.remove(key);
  }

  /// Xóa toàn bộ dữ liệu
  Future<void> clearAll() async {
    if (_prefs == null) await init();
    await _prefs!.clear();
  }

  /// Kiểm tra key có tồn tại không
  Future<bool> contains(String key) async {
    if (_prefs == null) await init();
    return _prefs!.containsKey(key);
  }

  /// Lấy toàn bộ key-value (dùng debug)
  Future<Map<String, Object>> getAll() async {
    if (_prefs == null) await init();
    final keys = _prefs!.getKeys();
    final map = <String, Object>{};
    for (var key in keys) {
      final value = _prefs!.get(key);
      if (value != null) map[key] = value;
    }
    return map;
  }
}

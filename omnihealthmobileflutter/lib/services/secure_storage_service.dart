import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SecureStorageService
/// Quản lý lưu trữ dữ liệu nhạy cảm an toàn bằng Flutter Secure Storage.
///
/// - Dữ liệu được mã hóa tự động bởi OS (Android Keystore / iOS Keychain)
/// - Dùng để lưu: accessToken, refreshToken, password, private keys,...
class SecureStorageService {
  // Secure Storage instance
  final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Tạo hoặc ghi mới dữ liệu
  Future<void> create(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Lấy dữ liệu theo key
  Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  /// Cập nhật dữ liệu (thực tế write() đã tự động ghi đè nếu key tồn tại)
  Future<void> update(String key, String newValue) async {
    await _storage.write(key: key, value: newValue);
  }

  /// Xóa 1 key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Xóa toàn bộ dữ liệu (cẩn thận khi dùng)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Kiểm tra key có tồn tại không
  Future<bool> contains(String key) async {
    final all = await _storage.readAll();
    return all.containsKey(key);
  }

  /// Lấy toàn bộ key-value (dùng debug)
  Future<Map<String, String>> getAll() async {
    return await _storage.readAll();
  }
}

/// Role Guard để kiểm soát quyền truy cập
class RoleGuard {
  /// Map role từ database về role chuẩn hóa
  static const Map<String, String> roleAlias = {
    'User': 'user',
    'Coach': 'coach',
    'Admin': 'admin',
  };

  /// Định nghĩa quyền truy cập cho từng route
  static const Map<String, List<String>> accessRules = {
    '/main': ['user', 'coach', 'admin'],
    '/home': ['user', 'coach', 'admin'],
    '/profile': ['user', 'coach', 'admin'],
    '/settings': ['user', 'coach', 'admin'],
    '/muscle-home': ['user', 'coach', 'admin'],
  };

  /// Kiểm tra xem người dùng (với danh sách roleName) có quyền truy cập route không
  static bool canAccess(List<String>? dbRoles, String routeName) {
    if (dbRoles == null || dbRoles.isEmpty) return false;

    // Chuẩn hóa tất cả role về key chuẩn
    final normalizedRoles = dbRoles
        .map((role) => roleAlias[role] ?? role.toLowerCase())
        .toList();

    // Lấy danh sách role được phép truy cập route
    final allowedRoles = accessRules[routeName];

    // Nếu route không có trong rules, cho phép tất cả
    if (allowedRoles == null) return true;

    // Chỉ cần có ít nhất 1 role nằm trong danh sách allowedRoles là được
    return normalizedRoles.any((role) => allowedRoles.contains(role));
  }

  /// Lấy role chuẩn hóa (nếu chỉ muốn xử lý một role đơn lẻ)
  static String? getNormalizedRole(String? dbRole) {
    if (dbRole == null) return null;
    return roleAlias[dbRole] ?? dbRole.toLowerCase();
  }
}

/// Role Guard để kiểm soát quyền truy cập
class RoleGuard {
  // Map role từ database về role chuẩn hóa
  static const Map<String, String> roleAlias = {
    'User': 'user',
    'Coach': 'coach',
    'Admin': 'admin',
  };

  // Định nghĩa quyền truy cập cho từng route
  static const Map<String, List<String>> accessRules = {
    '/main': ['user', 'coach', 'admin'],
    '/home': ['user', 'coach', 'admin'],
    '/profile': ['user', 'coach', 'admin'],
    '/settings': ['user', 'coach', 'admin'],
  };

  /// Kiểm tra xem role có quyền truy cập route không
  static bool canAccess(String? dbRole, String routeName) {
    if (dbRole == null) return false;

    // Chuẩn hóa role về key chuẩn
    final normalizedRole = roleAlias[dbRole] ?? dbRole.toLowerCase();

    // Lấy danh sách role được phép
    final allowedRoles = accessRules[routeName];

    // Nếu route không có trong rules, cho phép tất cả
    if (allowedRoles == null) return true;

    return allowedRoles.contains(normalizedRole);
  }

  /// Lấy role chuẩn hóa
  static String? getNormalizedRole(String? dbRole) {
    if (dbRole == null) return null;
    return roleAlias[dbRole] ?? dbRole.toLowerCase();
  }
}

import 'app_config.dart';

class Endpoints {
  static String get baseUrl => AppConfig.baseUrl;

  // ================== AUTH ==================
  static const String getAuth = "/v1/auth";
  static const String login = "/v1/auth/login";
  static const String register = "/v1/auth/register";
  static const String createNewAccessToken = "/v1/auth/new-access-token";

  // Roles
  static const String getRoleWithoutAdmin = "/v1/role/without-admin";

  // Muscle
  static String getMuscleById(String id) => "/v1/muscle/${id}";
}

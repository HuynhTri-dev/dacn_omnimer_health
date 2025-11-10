import 'app_config.dart';

class Endpoints {
  static String get baseUrl => AppConfig.baseUrl;

  // ================== AUTH ==================
  static const String login = "/v1/auth/login";
  static const String register = "/v1/auth/register";
  static const String createNewAccessToken = "/v1/auth/new-access-token";
}

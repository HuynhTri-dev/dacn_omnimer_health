import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'DEV';

  static String get baseUrl {
    return "${dotenv.env['API_BASE_URL']}/api";
  }

  static bool get isDev => environment.toUpperCase() == "DEV";
  static bool get isProd => environment.toUpperCase() == "PROD";
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'presentation/app.dart';

Future<void> main() async {
  // Đảm bảo Flutter bindings được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // ==================== ENVIRONMENT SETUP ====================
  const env = String.fromEnvironment("ENV", defaultValue: "DEV");
  debugPrint('🚀 Running in $env mode');

  // ==================== SYSTEM UI SETUP ====================
  // Cố định orientation (nếu cần)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Setup status bar và navigation bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // ==================== LOCALIZATION SETUP ====================
  // Initialize date formatting cho tiếng Việt
  await initializeDateFormatting('vi_VN', null);

  // ==================== FIREBASE SETUP ====================
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
  }

  // ==================== ENV FILE SETUP ====================
  try {
    await dotenv.load(fileName: env == "PROD" ? ".env.production" : ".env");
    debugPrint('✅ Environment file loaded successfully');
  } catch (e) {
    debugPrint('❌ Environment file loading failed: $e');
  }

  // ==================== DEPENDENCY INJECTION SETUP ====================
  try {
    await di.init();
    debugPrint('✅ Dependency injection initialized successfully');
  } catch (e) {
    debugPrint('❌ Dependency injection initialization failed: $e');
  }

  // ==================== ERROR HANDLING ====================
  // Catch Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('❌ Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // ==================== RUN APP ====================
  runApp(const App());
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'injection_container.dart' as di;
import 'presentation/app.dart';

Future<void> main() async {
  // Đảm bảo Flutter bindings được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // ==================== SYSTEM UI SETUP ====================
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
  await initializeDateFormatting('vi_VN', null);

  // ==================== ENV FILE SETUP ====================
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ .env file loaded successfully');
  } catch (e) {
    debugPrint('❌ .env file loading failed: $e');
  }

  // ==================== DEPENDENCY INJECTION SETUP ====================
  try {
    await di.init();
    debugPrint('✅ Dependency injection initialized successfully');
  } catch (e) {
    debugPrint('❌ Dependency injection initialization failed: $e');
  }

  // ==================== ERROR HANDLING ====================
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('❌ Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // ==================== RUN APP ====================
  runApp(const App());
}

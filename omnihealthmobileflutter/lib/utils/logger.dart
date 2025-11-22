import 'package:logger/logger.dart';

/// Logger mặc định cho toàn app
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // Không in stacktrace
    errorMethodCount: 0,
    lineLength: 100, // chiều dài tối đa 1 dòng log
    colors: true,
    printEmojis: true,
    printTime: false, // tắt giờ log nếu không cần
  ),
);

/// Logger đơn giản hơn (gọn hơn PrettyPrinter)
final simpleLogger = Logger(printer: SimplePrinter(colors: true));

import 'package:intl/intl.dart';

class AppConstants {
  // 🔹 Pagination
  static const int defaultPage = 1;
  static const int defaultLimit = 10;

  // 🔹 UI
  static const int defaultAnimationDuration = 300; // ms
  static const String defaultDateFormat = "dd/MM/yyyy";
  static const String defaultDateTimeFormat = "dd/MM/yyyy HH:mm";

  // 🔹 Default Sorts cho từng module
  static const Map<String, String> defaultSorts = {
    "class": "name:asc", // mặc định cho Class Management
    "membership": "createdAt:desc", // mặc định cho MembershipRequest
    "school": "name:asc", // mặc định cho School
  };

  // 🔹 Formatters
  static final currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
  );

  static DateTime? toVietnamTime(DateTime? utcDateTime) {
    if (utcDateTime == null) return null;
    return utcDateTime.toUtc().add(const Duration(hours: 7));
  }

  static final dateFormatter = DateFormat(defaultDateFormat, 'vi_VN');
  static final dateTimeFormatter = DateFormat(defaultDateTimeFormat, 'vi_VN');
}

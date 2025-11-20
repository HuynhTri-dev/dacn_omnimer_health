class FilterUtils {
  /// Convert Map<String,dynamic> -> "field:value|value2,field2:value"
  static String mapToString(Map<String, dynamic> filterMap) {
    return filterMap.entries
        .map((e) {
          if (e.value is List) {
            return "${e.key}:${(e.value as List).join('|')}";
          } else {
            return "${e.key}:${e.value}";
          }
        })
        .join(",");
  }

  /// Convert "field:value|value2,field2:value" -> Map<String,dynamic>
  static Map<String, dynamic> stringToMap(String filterString) {
    final result = <String, dynamic>{};
    if (filterString.isEmpty) return result;

    for (var part in filterString.split(',')) {
      final kv = part.split(':');
      if (kv.length != 2) continue;
      final key = kv[0];
      final value = kv[1];
      if (value.contains('|')) {
        result[key] = value.split('|');
      } else {
        result[key] = value;
      }
    }

    return result;
  }
}

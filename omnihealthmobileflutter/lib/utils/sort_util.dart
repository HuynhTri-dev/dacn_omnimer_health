class SortUtils {
  // 🔹 Sort Options cho Class Management
  static const Map<Map<String, String>, String> classSortOptions = {
    {'name': 'asc'}: 'Tên (A-Z)',
    {'name': 'desc'}: 'Tên (Z-A)',
    {'code': 'asc'}: 'Mã (A-Z)',
    {'code': 'desc'}: 'Mã (Z-A)',
    {'baseFee': 'asc'}: 'Học phí ↑',
    {'baseFee': 'desc'}: 'Học phí ↓',
  };

  /// Sort options cho Grade
  static const Map<Map<String, String>, String> gradeSortOptions = {
    {'name': 'asc'}: 'Tên (A-Z)',
    {'name': 'desc'}: 'Tên (Z-A)',
    {'order': 'asc'}: 'STT ↑ ',
    {'order': 'desc'}: 'STT ↓',
  };

  /// Convert List<Map<String,String>> -> "field:asc,field2:desc"
  static String listToString(List<Map<String, String>> sortList) {
    if (sortList.isEmpty) return '';
    return sortList
        .map((m) {
          final entry = m.entries.first;
          return "${entry.key}:${entry.value}";
        })
        .join(",");
  }

  /// Convert "field:asc,field2:desc" -> List<Map<String,String>>
  static List<Map<String, String>> stringToList(String sortString) {
    if (sortString.isEmpty) return [];
    return sortString.split(",").map((p) {
      final kv = p.split(":");
      if (kv.length == 2) {
        // ép kiểu rõ ràng
        return <String, String>{kv[0]: kv[1]};
      }
      return <String, String>{};
    }).toList();
  }
}

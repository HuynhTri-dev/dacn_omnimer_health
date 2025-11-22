class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final dynamic error;

  const ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.error,
  });

  /// Parse từ JSON server trả về:
  /// server format: { success: bool, data: any, message: string, error?: any }
  factory ApiResponse.fromJson(
    Map<dynamic, dynamic> json, {
    T Function(dynamic)? fromJsonT,
  }) {
    final rawData = json['data'];
    final T? parsedData = (fromJsonT != null && rawData != null)
        ? fromJsonT(rawData)
        : (rawData as T?);

    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: parsedData,
      message: (json['message'] ?? '').toString(),
      error: json['error'],
    );
  }

  /// Response thành công với data (status 200)
  factory ApiResponse.success(T? data, {String message = "Thành công"}) =>
      ApiResponse<T>(success: true, data: data, message: message);

  /// Response thành công khi tạo mới (status 201)
  factory ApiResponse.created(T? data, {String message = "Tạo thành công"}) =>
      ApiResponse<T>(success: true, data: data, message: message);

  /// Response thành công nhưng không có dữ liệu (status 204)
  factory ApiResponse.noContent({String message = "Không có dữ liệu"}) =>
      ApiResponse<T>(success: true, data: null, message: message);

  /// Response thất bại
  factory ApiResponse.error(String message, {dynamic error}) => ApiResponse<T>(
    success: false,
    data: null,
    message: message,
    error: error,
  );

  /// Response khi danh sách trống
  factory ApiResponse.empty({String message = "Danh sách trống"}) =>
      ApiResponse.success(null, message: message);
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  ApiException(this.message, {this.statusCode, this.error});

  @override
  String toString() => "ApiException: $message (code: $statusCode)";
}

class NetworkException extends ApiException {
  NetworkException([String message = "Không có kết nối internet"])
    : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException([String message = "Yêu cầu quá thời gian"]) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = "Người dùng chưa đăng nhập"])
    : super(message, statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException([String message = "Người dùng không có quyền truy cập"])
    : super(message, statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = "Không tìm thấy"])
    : super(message, statusCode: 404);
}

class BadRequestException extends ApiException {
  BadRequestException([String message = "Yêu cầu không hợp lệ"])
    : super(message, statusCode: 400);
}

class ServerException extends ApiException {
  ServerException([String message = "Lỗi hệ thống"])
    : super(message, statusCode: 500);
}

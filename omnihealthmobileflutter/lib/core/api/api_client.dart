import 'dart:io';
import 'package:dio/dio.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';
import 'package:omnihealthmobileflutter/core/constants/storage_constant.dart';
import 'package:omnihealthmobileflutter/services/secure_storage_service.dart';
import 'api_response.dart';
import 'api_exception.dart';
import 'endpoints.dart';

class ApiClient {
  final Dio dio;
  final SecureStorageService secureStorage;

  // Flag để tránh infinite loop khi refresh token
  bool _isRefreshing = false;

  // Queue để chứa các request đang chờ token mới
  final List<_RequestOptions> _requestQueue = [];

  ApiClient({required this.secureStorage})
    : dio = Dio(
        BaseOptions(
          baseUrl: Endpoints.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          responseType: ResponseType.json,
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Kiểm tra flag requiresAuth trong extra
          final requiresAuth = options.extra['requiresAuth'] ?? true;

          if (requiresAuth) {
            final accessToken = await secureStorage.get(
              StorageConstant.kAccessTokenKey,
            );
            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
          }

          // Log thông tin request
          logger.i('''
───────────────────── REQUEST ─────────────────────
[${options.method}] ${options.uri}
Headers: ${options.headers}
Query: ${options.queryParameters}
Data: ${options.data}
RequiresAuth: $requiresAuth
───────────────────────────────────────────────────
''');

          // Remove flag khỏi extra để không gửi lên server
          options.extra.remove('requiresAuth');

          return handler.next(options);
        },

        onResponse: (response, handler) {
          // Log thông tin response
          logger.i('''
───────────────────── RESPONSE ─────────────────────
[${response.requestOptions.method}] ${response.requestOptions.uri}
Status: ${response.statusCode}
Data: ${response.data}
───────────────────────────────────────────────────
''');
          return handler.next(response);
        },

        onError: (error, handler) async {
          final request = error.requestOptions;
          final requiresAuth = request.extra['requiresAuth'] ?? true;

          // Log thông tin lỗi
          logger.e('''
───────────────────── ERROR ─────────────────────
[${request.method}] ${request.uri}
Status: ${error.response?.statusCode}
Message: ${error.message}
Data: ${error.response?.data}
────────────────────────────────────────────────
''');

          // Nếu lỗi 401 (Unauthorized) và request yêu cầu auth
          if (error.response?.statusCode == 401 && requiresAuth) {
            if (_isRefreshing) {
              _requestQueue.add(
                _RequestOptions(requestOptions: request, handler: handler),
              );
              return;
            }

            _isRefreshing = true;

            try {
              final newAccessToken = await _refreshAccessToken();
              if (newAccessToken != null) {
                await secureStorage.update(
                  StorageConstant.kAccessTokenKey,
                  newAccessToken,
                );

                final options = request;
                options.headers['Authorization'] = 'Bearer $newAccessToken';
                final response = await dio.fetch(options);

                await _processQueue(newAccessToken);

                _isRefreshing = false;
                return handler.resolve(response);
              } else {
                await _clearAuthData();
                _isRefreshing = false;
                _rejectQueue(error);
                return handler.reject(error);
              }
            } catch (e) {
              logger.e("⛔ Error refreshing token: $e");
              await _clearAuthData();
              _isRefreshing = false;
              _rejectQueue(error);
              return handler.reject(error);
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Refresh access token
  Future<String?> _refreshAccessToken() async {
    try {
      final refreshToken = await secureStorage.get(
        StorageConstant.kRefreshTokenKey,
      );

      if (refreshToken == null || refreshToken.isEmpty) {
        logger.e("Refresh token not found");
        return null;
      }

      final response = await dio.post(
        Endpoints.createNewAccessToken,
        data: {'refreshToken': refreshToken},
        options: Options(
          extra: {'requiresAuth': false}, // Không cần auth cho endpoint này
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Xử lý response dựa trên format của server
        if (data is Map && data.containsKey('data')) {
          return data['data']?.toString();
        } else if (data is Map && data.containsKey('accessToken')) {
          return data['accessToken']?.toString();
        } else if (data is String) {
          return data;
        }
      }

      return null;
    } catch (e) {
      logger.e("Error in _refreshAccessToken: $e");
      return null;
    }
  }

  /// Xử lý các request trong queue sau khi có token mới
  Future<void> _processQueue(String newAccessToken) async {
    for (var item in _requestQueue) {
      try {
        item.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final response = await dio.fetch(item.requestOptions);
        item.handler.resolve(response);
      } catch (e) {
        item.handler.reject(
          DioException(requestOptions: item.requestOptions, error: e),
        );
      }
    }
    _requestQueue.clear();
  }

  /// Reject tất cả request trong queue
  void _rejectQueue(DioException error) {
    for (var item in _requestQueue) {
      item.handler.reject(error);
    }
    _requestQueue.clear();
  }

  /// Clear auth data khi logout hoặc refresh token fail
  Future<void> _clearAuthData() async {
    await secureStorage.delete(StorageConstant.kAccessTokenKey);
    await secureStorage.delete(StorageConstant.kRefreshTokenKey);
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required File file,
    String fieldName = 'file',
    Map<String, dynamic>? fields,
    Map<String, dynamic>? headers,
    T Function(dynamic)? parser,
    bool requiresAuth = true, // 👈 Thêm parameter này
  }) async {
    try {
      final formData = FormData.fromMap({
        if (fields != null) ...fields,
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.last,
        ),
      });

      final response = await dio.post(
        path,
        data: formData,
        options: Options(
          headers: {...?headers, 'Content-Type': 'multipart/form-data'},
          extra: {'requiresAuth': requiresAuth}, // 👈 Pass flag
        ),
      );

      return _handleResponse<T>(response, fromJsonT: parser);
    } on DioException catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    T Function(dynamic)? parser,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: query,
        options: Options(
          headers: headers,
          extra: {'requiresAuth': requiresAuth},
        ),
      );
      return _handleResponse<T>(response, fromJsonT: parser);
    } on DioException catch (e) {
      throw _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    T Function(dynamic)? parser,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: query,
        options: Options(
          headers: headers,
          extra: {'requiresAuth': requiresAuth},
        ),
      );
      logger.i("Response: ${response}");
      return _handleResponse<T>(response, fromJsonT: parser);
    } on DioException catch (e) {
      throw _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    T Function(dynamic)? parser,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: query,
        options: Options(
          headers: headers,
          extra: {'requiresAuth': requiresAuth},
        ),
      );
      return _handleResponse<T>(response, fromJsonT: parser);
    } on DioException catch (e) {
      throw _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    T Function(dynamic)? parser,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: query,
        options: Options(
          headers: headers,
          extra: {'requiresAuth': requiresAuth},
        ),
      );
      return _handleResponse<T>(response, fromJsonT: parser);
    } on DioException catch (e) {
      throw _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    T Function(dynamic)? parser,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await dio.delete(
        path,
        queryParameters: query,
        options: Options(
          headers: headers,
          extra: {'requiresAuth': requiresAuth},
        ),
      );
      return _handleResponse<T>(response, fromJsonT: parser);
    } on DioException catch (e) {
      throw _handleError<T>(e);
    }
  }

  ApiResponse<T> _handleResponse<T>(
    Response response, {
    T Function(dynamic)? fromJsonT,
  }) {
    final status = response.statusCode ?? 200;
    final raw = response.data;

    // ✅ Nếu 204 No Content → không có data
    if (status == 204) {
      return ApiResponse<T>.noContent();
    }

    // ✅ Nếu body null → coi như danh sách trống
    if (raw == null) {
      return ApiResponse<T>.empty();
    }

    // ✅ Nếu server trả wrapper { success, data, message }
    if (raw is Map && raw.containsKey('success')) {
      try {
        return ApiResponse<T>.fromJson(raw, fromJsonT: fromJsonT);
      } catch (e) {
        return ApiResponse.error("Lỗi xử lý dữ liệu", error: e.toString());
      }
    }

    // ✅ Nếu status code là 201 → created
    if (status == 201) {
      return ApiResponse<T>.created(raw as T?);
    }

    // ✅ Server không dùng wrapper → fallback success
    return ApiResponse<T>.success(raw as T?);
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw TimeoutException();
    }

    if (e.type == DioExceptionType.connectionError) {
      throw NetworkException();
    }

    if (e.response == null) {
      throw ServerException("Không thể kết nối đến server");
    }

    final status = e.response!.statusCode ?? 500;
    final body = e.response!.data;
    String message;
    dynamic error;

    // Nếu server trả về format chuẩn {success, message, error}
    if (body is Map && body.containsKey('success')) {
      message = body['message']?.toString() ?? "Lỗi không xác định";
      error = body['error'];
    } else if (body is Map) {
      // Fallback cho format không chuẩn
      message =
          body['message']?.toString() ??
          body['error']?.toString() ??
          "Lỗi không xác định";
      error = body;
    } else {
      message = "Lỗi không xác định";
      error = body;
    }

    switch (status) {
      case 400:
        throw BadRequestException(message);
      case 401:
        throw UnauthorizedException(message);
      case 403:
        throw ForbiddenException(message);
      case 404:
        throw NotFoundException(message);
      default:
        throw ServerException(message);
    }
  }
}

/// Helper class để lưu request đang chờ
class _RequestOptions {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _RequestOptions({required this.requestOptions, required this.handler});
}

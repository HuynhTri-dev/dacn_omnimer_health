import 'dart:io';

import 'package:dio/dio.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';
import 'api_response.dart';
import 'api_exception.dart';
import 'endpoints.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: Endpoints.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          responseType: ResponseType.json,
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required File file,
    String fieldName = 'file',
    Map<String, dynamic>? fields,
    Map<String, dynamic>? headers,
    T Function(dynamic)? parser,
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
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: query,
        options: Options(headers: headers),
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
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: query,
        options: Options(headers: headers),
      );
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
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: query,
        options: Options(headers: headers),
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
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: query,
        options: Options(headers: headers),
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
  }) async {
    try {
      final response = await dio.delete(
        path,
        queryParameters: query,
        options: Options(headers: headers),
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

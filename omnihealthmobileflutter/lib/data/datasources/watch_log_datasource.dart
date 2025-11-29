import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/core/api/api_response.dart';
import 'package:omnihealthmobileflutter/core/api/endpoints.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

abstract class WatchLogDataSource {
  Future<ApiResponse<void>> createManyWatchLog(List<Map<String, dynamic>> logs);
}

class WatchLogDataSourceImpl implements WatchLogDataSource {
  final ApiClient apiClient;

  WatchLogDataSourceImpl({required this.apiClient});

  @override
  Future<ApiResponse<void>> createManyWatchLog(
    List<Map<String, dynamic>> logs,
  ) async {
    try {
      final response = await apiClient.post<void>(
        Endpoints.createManyWatchLogs,
        data: {'logs': logs},
        requiresAuth: true,
      );
      return response;
    } catch (e) {
      logger.e('Error creating many watch logs: $e');
      return ApiResponse.error("Đồng bộ dữ liệu thất bại: ${e.toString()}");
    }
  }
}

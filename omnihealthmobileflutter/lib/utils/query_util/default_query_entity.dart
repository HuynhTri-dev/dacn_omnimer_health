import 'package:omnihealthmobileflutter/utils/query_util/query_builder.dart';
import '../../../core/constants/app_constant.dart';

class DefaultQueryEntity {
  final int page;
  final int limit;
  final List<Map<String, String>> sort;
  final Map<String, dynamic> filter;
  final String? search;

  DefaultQueryEntity({
    this.page = AppConstants.defaultPage,
    this.limit = AppConstants.defaultLimit,
    this.sort = const [],
    this.filter = const {},
    this.search,
  });

  QueryBuilder toQueryBuilder() {
    return QueryBuilder(
      page: page,
      limit: limit,
      sort: sort,
      filter: filter,
      search: search,
    );
  }

  DefaultQueryEntity copyWith({
    int? page,
    int? limit,
    List<Map<String, String>>? sort,
    Map<String, dynamic>? filter,
    String? search,
  }) {
    return DefaultQueryEntity(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sort: sort ?? this.sort,
      filter: filter ?? this.filter,
      search: search ?? this.search,
    );
  }
}

import { IQueryBuilder } from '@/app/types/queryBuilder';

/**
 * Chuyển QueryBuilder thành object chuẩn để gửi Axios
 */
export function buildQueryParams(query: IQueryBuilder): Record<string, string> {
  const params: Record<string, string> = {
    page: (query.page ?? 1).toString(),
    limit: (query.limit ?? 20).toString(),
  };

  // Multi-sort: [{ field: 'asc' }] -> "field:asc,field2:desc"
  if (query.sort && query.sort.length > 0) {
    params.sort = query.sort
      .map(obj => {
        const field = Object.keys(obj)[0];
        const direction = obj[field];
        return `${field}:${direction}`;
      })
      .join(',');
  }

  // Filter object -> JSON string (backend parse JSON)
  if (query.filter && Object.keys(query.filter).length > 0) {
    params.filter = JSON.stringify(query.filter);
  }

  // Search string
  if (query.search && query.search.trim().length > 0) {
    params.search = query.search.trim();
  }

  return params;
}

export function toQueryString(query: IQueryBuilder): string {
  const params = buildQueryParams(query);
  return Object.keys(params)
    .map(key => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
    .join('&');
}

//? Ví dụ
// import { api } from '@/config/axiosInstance';
// import { buildQueryParams, IQueryBuilder } from '@/utils/queryBuilder';

// const query: IQueryBuilder = {
//   page: 2,
//   limit: 10,
//   sort: [{ createdAt: 'desc' }],
//   filter: { status: ['active', 'pending'] },
//   search: 'health',
// };

// const params = buildQueryParams(query);

// const res = await api.get('/exercises', { params });

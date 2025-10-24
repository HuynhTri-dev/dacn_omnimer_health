export interface IQueryBuilder {
  page?: number;
  limit?: number;
  sort?: Array<Record<string, 'asc' | 'desc'>>; // Multi-sort: [{field: 'asc'}]
  filter?: Record<string, any>; // filter: {field: value} hoặc {field: [values]}
  search?: string;
}

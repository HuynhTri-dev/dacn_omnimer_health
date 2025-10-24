export interface PaginationQueryOptions {
  page: number;
  limit: number;
  sort?: Record<string, 1 | -1>;
  filter?: Record<string, any>;
  search?: string;
}

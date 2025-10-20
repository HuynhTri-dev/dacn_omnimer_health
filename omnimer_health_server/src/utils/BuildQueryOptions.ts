import { DEFAULT_LIMIT, DEFAULT_PAGE } from "../common/constants/AppConstants";
import DateUtils from "./DateUtils";

export interface PaginationQueryOptions {
  page: number;
  limit: number;
  sort?: Record<string, 1 | -1>;
  filter?: Record<string, any>;
  search?: string;
}

/**
 * Build query options (page, limit, sort, filter, search) từ request query
 * Tự động parse date → { $gte, $lte } nếu có field "date"
 */
export function buildQueryOptions(
  parsedQuery: {
    page?: number | string | null;
    limit?: number | string | null;
    sort?: string | null;
    filter?: string | null; // "gender:Male,literacy:Bachelor,subjects:Math|English"
    search?: string | null; // ?search=John
  },
  timezone: string = "Asia/Ho_Chi_Minh"
): PaginationQueryOptions {
  const page =
    parsedQuery.page && !isNaN(Number(parsedQuery.page))
      ? Math.max(Number(parsedQuery.page), 1)
      : DEFAULT_PAGE;

  const limit =
    parsedQuery.limit && !isNaN(Number(parsedQuery.limit))
      ? Math.max(Number(parsedQuery.limit), 1)
      : DEFAULT_LIMIT;

  // 🔹 Xử lý sort
  let sortObj: Record<string, 1 | -1> | undefined;
  if (parsedQuery.sort && parsedQuery.sort !== "null") {
    const fields = parsedQuery.sort.split(",");
    const obj: Record<string, 1 | -1> = {};
    fields.forEach((f) => {
      const [field, order] = f.split(":");
      if (field) obj[field] = order === "asc" ? 1 : -1;
    });
    if (Object.keys(obj).length) sortObj = obj;
  }

  // 🔹 Xử lý filter
  let filterObj: Record<string, any> | undefined;
  if (parsedQuery.filter && parsedQuery.filter !== "null") {
    const fields = parsedQuery.filter.split(",");
    const obj: Record<string, any> = {};

    fields.forEach((f) => {
      const [key, value] = f.split(":");
      if (!key || !value || value === "null") return;

      if (value.includes("|")) {
        obj[key] = { $in: value.split("|").map((v) => v.trim()) };
      } else {
        obj[key] = value.trim();
      }
    });

    // 🔹 Nếu filter có trường "date" → convert sang khoảng thời gian UTC
    if (obj.date) {
      const date = new Date(obj.date);
      const { start, end } = DateUtils.getUtcDayRange(date, timezone);
      obj.date = { $gte: start, $lte: end };
    }

    if (Object.keys(obj).length) filterObj = obj;
  }

  // 🔹 Xử lý search
  const search =
    parsedQuery.search && parsedQuery.search !== "null"
      ? parsedQuery.search.trim()
      : undefined;

  return {
    page,
    limit,
    sort: sortObj,
    filter: filterObj,
    search,
  };
}

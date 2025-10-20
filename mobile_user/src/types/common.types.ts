// types/common.types.ts
export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
}

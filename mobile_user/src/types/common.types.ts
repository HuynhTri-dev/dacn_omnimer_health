// types/common.types.ts
export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
}

// {
//   "success":
//   message:
//   data: {
//     user: ...,
//     token: ...,
//     refreshToken: ...,
//   }
// }

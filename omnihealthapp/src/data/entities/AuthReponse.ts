/**
 * Kiểu dữ liệu người dùng được trả về cho client (ẩn thông tin nhạy cảm)
 */
export interface IUserResponse {
  fullname: string;
  email?: string | null;
  imageUrl?: string;
  gender?: string;
  birthday?: Date | null;
}

/**
 * Kết quả trả về sau khi đăng nhập / đăng ký
 */
export interface IAuthResponse {
  user: IUserResponse;
  accessToken: string;
  refreshToken: string;
}

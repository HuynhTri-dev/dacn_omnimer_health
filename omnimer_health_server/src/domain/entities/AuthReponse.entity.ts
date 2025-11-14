import { Types } from "mongoose";
import { GenderEnum } from "../../common/constants/EnumConstants";

/**
 * Kiểu dữ liệu người dùng được trả về cho client (ẩn thông tin nhạy cảm)
 */
export interface IUserResponse {
  _id?: Types.ObjectId;
  fullname: string;
  email?: string | null;
  imageUrl?: string;
  gender?: GenderEnum;
  birthday?: Date | null;
  roleIds?: Types.ObjectId[];
  roleName?: string[];
}

/**
 * Kết quả trả về sau khi đăng nhập / đăng ký
 */
export interface IAuthResponse {
  user: IUserResponse;
  accessToken: string;
  refreshToken: string;
}

/**
 * Định nghĩa dữ liệu trả về để kiểm tra và gửi cho người dùng khi đăng nhập
 */
export interface IUserWithPasswordHash {
  userResponse: IUserResponse;
  passwordHashed: string;
}

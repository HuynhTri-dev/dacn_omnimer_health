import { Types } from "mongoose";
import { GenderEnum } from "../../common/constants/EnumConstants";

export interface ListUserResponse {
  _id: Types.ObjectId;
  fullname: string;
  email?: string | null;
  birthday?: Date | null;
  gender?: GenderEnum;

  roleNames: string[];

  imageUrl?: string;
}

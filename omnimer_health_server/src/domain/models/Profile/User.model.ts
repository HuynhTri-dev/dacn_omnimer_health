import mongoose, { Schema, Document, Types } from "mongoose";
import {
  GenderEnum,
  GenderTuple,
} from "../../../common/constants/EnumConstants";

export interface IUser extends Document {
  _id: Types.ObjectId;
  uid: string;
  fullname: string;

  email?: string | null;
  birthday?: Date | null;
  gender?: GenderEnum;

  roleIds: Types.ObjectId[];

  imageUrl?: string;
}

const userSchema = new Schema<IUser>(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },
    fullname: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      default: null,
      trim: true,
      lowercase: true,
      match: [/^\S+@\S+\.\S+$/, "Email không hợp lệ"],
      unique: true,
    },
    uid: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    birthday: {
      type: Date,
      default: null,
    },
    gender: {
      type: String,
      enum: GenderTuple,
      default: GenderEnum.Other,
    },
    roleIds: [{ type: Schema.Types.ObjectId, ref: "Role" }],

    imageUrl: {
      type: String,
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

// Index email và uid để tìm kiếm nhanh
userSchema.index({ email: 1, uid: 1 });

export const User = mongoose.model<IUser>("User", userSchema);

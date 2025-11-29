import mongoose, { Schema, Document, Types } from "mongoose";
import {
  GenderEnum,
  GenderTuple,
} from "../../../common/constants/EnumConstants";

export interface IUser extends Document {
  _id: Types.ObjectId;
  fullname: string;

  email: string;
  passwordHashed: string;
  birthday?: Date | null;
  gender?: GenderEnum;

  roleIds: Types.ObjectId[];

  imageUrl?: string;

  // Email Verification Fields
  isEmailVerified: boolean;
  emailVerificationToken?: string | null;
  emailVerificationExpires?: Date | null;

  // Phone Verification Fields (for future use)
  phoneNumber?: string | null;
  isPhoneVerified: boolean;
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
      trim: true,
      lowercase: true,
      match: [/^\S+@\S+\.\S+$/, "Email không hợp lệ"],
      unique: true,
    },
    passwordHashed: {
      type: String,
      required: true,
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

    // Email Verification Fields
    isEmailVerified: {
      type: Boolean,
      default: false,
    },
    emailVerificationToken: {
      type: String,
      default: null,
    },
    emailVerificationExpires: {
      type: Date,
      default: null,
    },

    // Phone Verification Fields
    phoneNumber: {
      type: String,
      trim: true,
      default: null,
    },
    isPhoneVerified: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Index email và uid để tìm kiếm nhanh
userSchema.index({ email: 1, uid: 1 });
// Index for email verification token lookup
userSchema.index({ emailVerificationToken: 1 });

export const User = mongoose.model<IUser>("User", userSchema);

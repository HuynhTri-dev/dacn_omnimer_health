import mongoose, { Schema, Types } from "mongoose";

export interface IPermission extends Document {
  _id: Types.ObjectId;
  key: string; // ví dụ: "user.read"
  description?: string;
  module: string; // nhóm chức năng: "user", "workout", "diet"
}

const permissionSchema = new Schema<IPermission>(
  {
    key: { type: String, required: true, unique: true },
    description: { type: String },
    module: { type: String, required: true },
  },
  { timestamps: true }
);

export const Permission = mongoose.model<IPermission>(
  "Permission",
  permissionSchema
);

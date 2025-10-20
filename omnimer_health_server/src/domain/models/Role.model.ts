import mongoose, { Schema, Types } from "mongoose";

export interface IRole extends Document {
  _id: Types.ObjectId;
  name: string; // "admin", "coach", "user"
  description?: string;
  permissionIds: Types.ObjectId[];
}

const roleSchema = new Schema<IRole>(
  {
    name: { type: String, required: true, unique: true },
    description: { type: String },
    permissionIds: [{ type: Schema.Types.ObjectId, ref: "Permission" }],
  },
  { timestamps: true }
);

export const Role = mongoose.model<IRole>("Role", roleSchema);

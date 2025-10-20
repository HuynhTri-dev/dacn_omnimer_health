import mongoose, { Schema, Document, Types } from "mongoose";

export interface IBodyPart extends Document {
  _id: Types.ObjectId;
  name: string;
  description?: string | null;
  imageUrl?: string | null;
}

const bodyPartSchema = new Schema<IBodyPart>(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },
    name: { type: String, required: true, unique: true },
    description: { type: String, default: null },
    imageUrl: { type: String, default: null },
  },
  {
    timestamps: true, // createdAt & updatedAt
  }
);

export const BodyPart = mongoose.model<IBodyPart>("BodyPart", bodyPartSchema);

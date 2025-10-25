import mongoose, { Schema, Document, Types } from "mongoose";

export interface IMuscle extends Document {
  _id: Types.ObjectId;
  name: string;
  bodyPartIds: Types.ObjectId[]; // có thể liên kết nhiều BodyPart
  description?: string;
  imageUrl?: string;
}

const muscleSchema = new Schema<IMuscle>(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },
    name: { type: String, required: true, unique: true },
    bodyPartIds: [{ type: Schema.Types.ObjectId, ref: "BodyPart" }],
    description: { type: String, default: null },
    imageUrl: { type: String, default: null },
  },
  { timestamps: true }
);

export const Muscle = mongoose.model<IMuscle>("Muscle", muscleSchema);

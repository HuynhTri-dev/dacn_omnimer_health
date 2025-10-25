import mongoose, { Schema, Document, Types } from "mongoose";

export interface IExerciseCategory extends Document {
  _id: Types.ObjectId;
  name: string;
  description?: string | null;
}

const exerciseCategorySchema = new Schema<IExerciseCategory>(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },
    name: { type: String, required: true },
    description: { type: String, default: null },
  },
  {
    timestamps: true, // createdAt & updatedAt
  }
);

export const ExerciseCategory = mongoose.model<IExerciseCategory>(
  "ExerciseCategory",
  exerciseCategorySchema
);

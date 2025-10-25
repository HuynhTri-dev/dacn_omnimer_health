import mongoose, { Schema, Document, Types } from "mongoose";

export interface IExerciseRating extends Document {
  _id: Types.ObjectId;
  exerciseId: Types.ObjectId; // ref: Exercise
  userId: Types.ObjectId; // ref: User
  score: number; // 1–5
}

const exerciseRatingSchema = new Schema<IExerciseRating>(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },
    exerciseId: {
      type: Schema.Types.ObjectId,
      ref: "Exercise",
      required: true,
      index: true,
    },
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    score: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
  },
  { timestamps: true }
);

// Một người chỉ có thể đánh giá 1 lần cho 1 bài tập
exerciseRatingSchema.index({ exerciseId: 1, userId: 1 }, { unique: true });

export const ExerciseRating = mongoose.model<IExerciseRating>(
  "ExerciseRating",
  exerciseRatingSchema
);

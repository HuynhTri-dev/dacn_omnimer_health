import mongoose, { Schema, Document, Types } from "mongoose";
import {
  GoalTypeEnum,
  GoalTypeTuple,
} from "../../../common/constants/EnumConstants";

export interface IExerciseType extends Document {
  _id: Types.ObjectId;
  name: string;
  description?: string | null;
  suitableGoals?: GoalTypeEnum[]; // các loại mục tiêu phù hợp
}

const exerciseTypeSchema = new Schema<IExerciseType>(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },
    name: { type: String, required: true },
    description: { type: String, default: null },
    suitableGoals: {
      type: [{ type: String, enum: GoalTypeTuple }],
      default: [],
    },
  },
  {
    timestamps: true, // createdAt & updatedAt
  }
);

export const ExerciseType = mongoose.model<IExerciseType>(
  "ExerciseType",
  exerciseTypeSchema
);

// [
//   {
//     _id: "652f8f1a2b3c4d5e6f7a8901",
//     name: "Strength Training",
//     description: "Bài tập giúp tăng sức mạnh cơ bắp, nâng tạ hoặc bodyweight.",
//     suitableGoals: ["Strength", "MuscleGain"]
//   },
// ]

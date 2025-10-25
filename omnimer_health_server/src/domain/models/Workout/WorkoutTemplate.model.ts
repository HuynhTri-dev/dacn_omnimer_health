import mongoose, { Schema, Document, Types, Model } from "mongoose";
import {
  WorkoutDetailTypeEnum,
  WorkoutDetailTypeTuple,
} from "../../../common/constants/EnumConstants";

// 🔹 Interface cho từng set trong template
export interface IWorkoutTemplateSet {
  setOrder: number;
  reps?: number;
  weight?: number;
  duration?: number; // giây
  distance?: number; // mét
  restAfterSetSeconds?: number;
  notes?: string;
}

// 🔹 Interface cho từng bài tập trong template
export interface IWorkoutTemplateDetail {
  exerciseId: Types.ObjectId;
  title?: string;
  type: WorkoutDetailTypeEnum;
  sets: IWorkoutTemplateSet[];
  createdByAI?: boolean;
}

// 🔹 Interface tổng cho Workout Template
export interface IWorkoutTemplate extends Document {
  name: string; // tên template, ví dụ "Full Body Strength"
  description?: string;
  exerciseCategory?: string; // ví dụ "strength", "cardio", "HIIT"
  bodyPartTarget?: string[];
  notes?: string;
  workOutDetail: IWorkoutTemplateDetail[];
  createdAt?: Date;
  updatedAt?: Date;
}

// 🔹 Schema cho Workout Template
const WorkoutTemplateSchema: Schema<IWorkoutTemplate> = new Schema(
  {
    name: { type: String, required: true },
    description: { type: String },
    exerciseCategory: { type: String },
    bodyPartTarget: [{ type: String }],
    notes: { type: String },

    workOutDetail: {
      type: [
        {
          exerciseId: {
            type: Schema.Types.ObjectId,
            ref: "Exercise",
            required: true,
          },
          title: { type: String },
          type: {
            type: String,
            enum: WorkoutDetailTypeTuple,
            required: true,
          },
          sets: {
            type: [
              {
                setOrder: { type: Number, required: true },
                reps: { type: Number },
                weight: { type: Number },
                duration: { type: Number },
                distance: { type: Number },
                restAfterSetSeconds: { type: Number, default: 0 },
                notes: { type: String },
              },
            ],
            default: [],
          },
          createdByAI: { type: Boolean, default: false },
        },
      ],
      default: [],
    },
  },
  {
    timestamps: true, // createdAt & updatedAt
  }
);

// 🔹 Export model
export const WorkoutTemplate: Model<IWorkoutTemplate> =
  mongoose.model<IWorkoutTemplate>("WorkoutTemplate", WorkoutTemplateSchema);

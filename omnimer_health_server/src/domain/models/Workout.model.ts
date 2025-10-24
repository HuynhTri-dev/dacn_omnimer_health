import mongoose, { Schema, Document, Types, Model } from "mongoose";
import {
  WorkoutDetailTypeEnum,
  WorkoutDetailTypeTuple,
} from "../../common/constants/EnumConstants";

// 🔹 Interface cho từng set
export interface IWorkoutSet {
  setOrder: number;
  reps?: number;
  weight?: number;
  duration?: number; // giây
  distance?: number; // mét
  restAfterSetSeconds?: number;
  notes?: string;
}

// 🔹 Interface cho từng bài tập trong buổi tập
export interface IWorkoutDetail {
  _exerciseId: Types.ObjectId;
  title?: string;
  type: WorkoutDetailTypeEnum;
  sets: IWorkoutSet[];
  summary?: {
    totalSets?: number;
    totalReps?: number;
    totalWeight?: number;
    totalDuration?: number;
    caloriesBurned?: number;
    distance?: number;
  };
  createdByAI?: boolean;
}

// 🔹 Interface cho device summary
export interface IWorkoutDeviceSummary {
  heartRateAvg?: number;
  heartRateMax?: number;
  caloriesBurned?: number;
}

// 🔹 Interface tổng cho Workout document
export interface IWorkout extends Document {
  _id: Types.ObjectId;
  _userId: Types.ObjectId;
  date: Date;
  totalDuration: number;
  exerciseCategoryWantToDo?: string;
  bodyPartTarget?: string[];
  notes?: string;
  workoutDetail: IWorkoutDetail[];
  deviceSummary?: IWorkoutDeviceSummary;
  createdAt?: Date;
  updatedAt?: Date;
}

// 🔹 Schema cho Workout
const WorkoutSchema: Schema<IWorkout> = new Schema(
  {
    _id: {
      type: Schema.Types.ObjectId,
      auto: true,
    },
    _userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    date: { type: Date, default: Date.now },
    totalDuration: { type: Number, default: 0 },
    exerciseCategoryWantToDo: { type: String },
    bodyPartTarget: [{ type: String }],
    notes: { type: String },

    workoutDetail: {
      type: [
        {
          _exerciseId: {
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
          summary: {
            totalSets: { type: Number },
            totalReps: { type: Number },
            totalWeight: { type: Number },
            totalDuration: { type: Number },
            caloriesBurned: { type: Number },
            distance: { type: Number },
          },
          createdByAI: { type: Boolean, default: false },
        },
      ],
      default: [],
    },

    deviceSummary: {
      heartRateAvg: Number,
      heartRateMax: Number,
      caloriesBurned: Number,
    },
  },
  {
    timestamps: true,
  }
);

// 🔹 Export model
export const Workout: Model<IWorkout> = mongoose.model<IWorkout>(
  "Workout",
  WorkoutSchema
);

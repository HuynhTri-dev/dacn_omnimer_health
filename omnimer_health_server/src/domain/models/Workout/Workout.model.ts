import mongoose, { Schema, Document, Types, Model } from "mongoose";
import {
  WorkoutDetailTypeEnum,
  WorkoutDetailTypeTuple,
} from "../../../common/constants/EnumConstants";

// 🔹 Interface cho từng set
export interface IWorkoutSet {
  _id: Types.ObjectId;
  setOrder: number;
  reps?: number;
  weight?: number;
  duration?: number; // giây
  distance?: number; // mét
  restAfterSetSeconds?: number;
  notes?: string;
  done: boolean;
}

// 🔹 Interface cho dữ liệu thiết bị ở từng bài tập
export interface IWorkoutDeviceData {
  _id?: Types.ObjectId;
  heartRateAvg?: number;
  heartRateMax?: number;
  caloriesBurned?: number;
}

// 🔹 Interface cho từng bài tập trong buổi tập
export interface IWorkoutDetail {
  _id: Types.ObjectId;
  exerciseId: Types.ObjectId;
  type: WorkoutDetailTypeEnum;
  sets: IWorkoutSet[];
  durationMin?: number; // tổng thời gian cho bài tập (nếu có)
  deviceData?: IWorkoutDeviceData; // dữ liệu từ thiết bị cho từng bài tập
}

// 🔹 Interface tổng hợp cuối buổi
export interface IWorkoutSummary {
  heartRateAvgAllWorkout?: number;
  heartRateMaxAllWorkout?: number;
  totalSets?: number;
  totalReps?: number;
  totalWeight?: number;
  totalDuration?: number;
  totalCalories?: number;
  totalDistance?: number;
}

// 🔹 Interface tổng cho Workout document
export interface IWorkout extends Document {
  _id: Types.ObjectId;
  userId: Types.ObjectId;
  healthProfileId?: Types.ObjectId;
  workoutTemplateId?: Types.ObjectId;
  timeStart: Date;
  notes?: string;

  workoutDetail: IWorkoutDetail[];
  summary?: IWorkoutSummary; // tổng kết toàn buổi
  createdAt?: Date;
  updatedAt?: Date;
}

// 🔹 Schema cho Workout
const WorkoutSchema: Schema<IWorkout> = new Schema(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    healthProfileId: {
      type: Schema.Types.ObjectId,
      ref: "HealthProfile",
      required: true,
      index: true,
    },
    workoutTemplateId: {
      type: Schema.Types.ObjectId,
      ref: "WorkoutTemplate",
    },

    timeStart: { type: Date, default: Date.now },
    notes: { type: String },

    workoutDetail: {
      type: [
        {
          exerciseId: {
            type: Schema.Types.ObjectId,
            ref: "Exercise",
            required: true,
          },
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
                done: { type: Boolean, default: false },
              },
            ],
            default: [],
          },
          durationMin: { type: Number },
          deviceData: {
            heartRateAvg: Number,
            heartRateMax: Number,
            caloriesBurned: Number,
          },
        },
      ],
      default: [],
    },

    summary: {
      totalSets: Number,
      totalReps: Number,
      totalWeight: Number,
      totalDuration: Number,
      totalCalories: Number,
      totalDistance: Number,
      heartRateAvgAllWorkout: Number,
      heartRateMaxAllWorkout: Number,
    },
  },
  { timestamps: true }
);

// 🔹 Export model
export const Workout: Model<IWorkout> = mongoose.model<IWorkout>(
  "Workout",
  WorkoutSchema
);

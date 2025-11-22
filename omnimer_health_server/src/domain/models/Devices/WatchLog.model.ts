import mongoose, { Schema, Document, Types } from "mongoose";
import {
  NameDeviceEnum,
  NameDeviceTuple,
} from "../../../common/constants/EnumConstants";

export interface IWatchLog extends Document {
  _id: Types.ObjectId;
  userId: Types.ObjectId; // liên kết User
  workoutId?: Types.ObjectId; // liên kết Workout
  exerciseId?: Types.ObjectId; // liên kết Exercise
  date: Date;

  nameDevice: NameDeviceEnum;
  // Vital Signs
  heartRateRest?: number; // nhịp tim nghỉ
  heartRateAvg?: number; // nhịp tim trung bình trong bài tập
  heartRateMax?: number; // nhịp tim tối đa

  // Activity Data
  steps?: number;
  distance?: number; // km
  caloriesBurned?: number; // kcal
  activeMinutes?: number; // phút hoạt động

  // Cardio Fitness
  vo2max?: number;

  // Recovery & Wellness
  sleepDuration?: number; // giờ
  sleepQuality?: number; // scale 1–5
  stressLevel?: number;
}

const watchLogSchema = new Schema<IWatchLog>(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },

    userId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    workoutId: { type: Schema.Types.ObjectId, ref: "Workout" },
    exerciseId: { type: Schema.Types.ObjectId, ref: "Exercise" },
    date: { type: Date, default: Date.now },

    nameDevice: { type: String, enum: NameDeviceTuple, required: true },
    // Vital Signs
    heartRateRest: Number,
    heartRateAvg: Number,
    heartRateMax: Number,

    // Activity Data
    steps: Number,
    distance: Number,
    caloriesBurned: Number,
    activeMinutes: Number,

    // Cardio Fitness
    vo2max: Number,

    // Recovery & Wellness
    sleepDuration: Number,
    sleepQuality: Number,
    stressLevel: Number,
  },
  {
    timestamps: true, // createdAt & updatedAt
  }
);

// Index _userId và date để query nhanh theo user và ngày
watchLogSchema.index({ _userId: 1, date: -1 });
watchLogSchema.index({ nameDevice: 1 });

export const WatchLog = mongoose.model<IWatchLog>("WatchLog", watchLogSchema);

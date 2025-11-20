import mongoose, { Schema, Document, Types } from "mongoose";
import {
  GoalTypeEnum,
  GoalTypeTuple,
} from "../../../common/constants/EnumConstants";
export interface ITargetMetric {
  metricName: string;
  value: number;
  unit?: string;
}

export interface IRepeatMetadata {
  frequency: "daily" | "weekly" | "monthly";
  interval?: number; // ví dụ mỗi 2 ngày
  daysOfWeek?: number[]; // nếu weekly: 0-6 = Sunday-Saturday
}

export interface IGoal extends Document {
  _id: Types.ObjectId; // Thêm _id
  userId: Types.ObjectId;
  goalType: GoalTypeEnum;
  startDate: Date;
  endDate: Date;
  repeat?: IRepeatMetadata;
  targetMetric: ITargetMetric[];
}

const goalSchema = new Schema<IGoal>(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    goalType: {
      type: String,
      enum: GoalTypeTuple,
      required: true,
    },
    startDate: {
      type: Date,
      required: true,
    },
    endDate: {
      type: Date,
      required: true,
    },
    repeat: {
      type: Object, // Metadata object
      default: {},
    },
    targetMetric: {
      type: [
        {
          metricName: { type: String, required: true },
          value: { type: Number, required: true },
          unit: { type: String },
        },
      ],
      default: [],
    },
  },
  {
    timestamps: true, // Tự động createdAt & updatedAt
  }
);

// Index _userId để query nhanh
goalSchema.index({ _userId: 1 });

export const Goal = mongoose.model<IGoal>("Goal", goalSchema);

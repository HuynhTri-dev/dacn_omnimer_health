import mongoose, { Schema, Document, Types, Model } from "mongoose";
import {
  LocationEnum,
  LocationTuple,
  WorkoutDetailTypeEnum,
  WorkoutDetailTypeTuple,
} from "../../../common/constants/EnumConstants";

// ================== INTERFACES ==================

/**
 * Một set trong bài tập (ví dụ: 3 hiệp, 12 reps mỗi hiệp, nghỉ 30s,...)
 */
export interface IWorkoutTemplateSet {
  setOrder: number;
  reps?: number;
  weight?: number;
  duration?: number; // Giây
  distance?: number; // Mét
  restAfterSetSeconds?: number;
  notes?: string;
}

/**
 * Một bài tập trong template
 */
export interface IWorkoutTemplateDetail {
  exerciseId: Types.ObjectId;
  type: WorkoutDetailTypeEnum;
  sets: IWorkoutTemplateSet[];
}

/**
 * Tổng thể template buổi tập
 */
export interface IWorkoutTemplate extends Document {
  _id: Types.ObjectId;

  name: string;
  description?: string;
  notes?: string;

  equipments?: Types.ObjectId[];
  bodyPartsTarget?: Types.ObjectId[];
  exerciseTypes?: Types.ObjectId[];
  exerciseCategories?: Types.ObjectId[];
  musclesTarget?: Types.ObjectId[];
  location?: LocationEnum;

  workOutDetail: IWorkoutTemplateDetail[];

  createdByAI?: boolean;
  createdForUserId?: Types.ObjectId;

  createdAt?: Date;
  updatedAt?: Date;
}

// ================== SCHEMA DEFINITION ==================

const WorkoutTemplateSchema: Schema<IWorkoutTemplate> = new Schema(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },

    name: { type: String, required: true },
    description: { type: String },
    notes: { type: String },

    equipments: [{ type: Schema.Types.ObjectId, ref: "Equipment" }],
    bodyPartsTarget: [{ type: Schema.Types.ObjectId, ref: "BodyPart" }],
    exerciseTypes: [{ type: Schema.Types.ObjectId, ref: "ExerciseType" }],
    exerciseCategories: [
      { type: Schema.Types.ObjectId, ref: "ExerciseCategory" },
    ],
    musclesTarget: [{ type: Schema.Types.ObjectId, ref: "Muscle" }],

    location: {
      type: String,
      enum: LocationTuple,
    },

    workOutDetail: {
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
              },
            ],
            default: [],
          },
        },
      ],
      default: [],
    },

    createdByAI: { type: Boolean, default: false },

    // * Nếu createdForUserId = null thì của hệ thống dành tất cả
    createdForUserId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      default: null,
      index: true,
    },
  },
  {
    timestamps: true,
  }
);

// ================== MODEL EXPORT ==================
export const WorkoutTemplate: Model<IWorkoutTemplate> =
  mongoose.model<IWorkoutTemplate>("WorkoutTemplate", WorkoutTemplateSchema);

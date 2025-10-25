import mongoose, { Schema, Document, Types } from "mongoose";
import {
  ExperienceLevelEnum,
  ExperienceLevelTuple,
} from "../../../common/constants/EnumConstants";

export interface IBloodPressure {
  systolic: number;
  diastolic: number;
}

export interface ICholesterol {
  total: number;
  ldl: number;
  hdl: number;
}

export interface IHealthStatus {
  knownConditions: string[];
  painLocations: string[];
  jointIssues: string[];
  injuries: string[];
  abnormalities: string[];
  notes?: string;
}

export interface IHealthProfile extends Document {
  _id: Types.ObjectId;
  userId: Types.ObjectId;

  height?: number;
  weight?: number;
  waist?: number;
  neck?: number;
  hip?: number;
  bmi?: number;
  bmr?: number;
  bodyFatPercentage?: number;
  muscleMass?: number;
  maxPushUps?: number;
  maxWeightLifted?: number;
  activityLevel?: number;
  restingHeartRate?: number;
  experienceLevel?: ExperienceLevelEnum;
  workoutFrequency?: number;

  bloodPressure?: IBloodPressure;
  cholesterol?: ICholesterol;
  bloodSugar?: number;

  healthStatus?: IHealthStatus;
}

const healthProfileSchema = new Schema<IHealthProfile>(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true },

    height: Number,
    weight: Number,
    waist: Number,
    neck: Number,
    hip: Number,
    bmi: Number,
    bmr: Number,
    bodyFatPercentage: Number,
    muscleMass: Number,
    maxPushUps: Number,
    maxWeightLifted: Number,
    activityLevel: Number,
    restingHeartRate: Number,
    experienceLevel: { type: String, enum: ExperienceLevelTuple },
    workoutFrequency: Number,

    bloodPressure: {
      systolic: Number,
      diastolic: Number,
    },
    cholesterol: {
      total: Number,
      ldl: Number,
      hdl: Number,
    },
    bloodSugar: Number,

    healthStatus: {
      knownConditions: { type: [String], default: [] },
      painLocations: { type: [String], default: [] },
      jointIssues: { type: [String], default: [] },
      injuries: { type: [String], default: [] },
      abnormalities: { type: [String], default: [] },
      notes: String,
    },
  },
  {
    timestamps: true, // createdAt & updatedAt
  }
);

// Index _userId để query nhanh
healthProfileSchema.index({ _userId: 1 });

export const HealthProfile = mongoose.model<IHealthProfile>(
  "HealthProfile",
  healthProfileSchema
);

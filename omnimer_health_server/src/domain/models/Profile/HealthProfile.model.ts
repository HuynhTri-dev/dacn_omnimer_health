import mongoose, { Schema, Document, Types } from "mongoose";
import {
  ExperienceLevelEnum,
  ExperienceLevelTuple,
  RiskLevelEnum,
  RiskLevelTuple,
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
  knownConditions?: string[]; // Danh sách các bệnh/chứng đã biết (ví dụ: "Tăng huyết áp", "Tiểu đường type 2")
  painLocations?: string[]; // Các vị trí đau hiện tại trên cơ thể (ví dụ: "Lưng dưới", "Gối phải")
  jointIssues?: string[]; // Vấn đề về khớp (ví dụ: "Thoái hóa khớp gối", "Viêm khớp vai")
  injuries?: string[]; // Các chấn thương (hiện tại hoặc trước đây) (ví dụ: "Gãy tay", "Trật cổ chân")
  abnormalities?: string[]; // Bất thường khác trong cơ thể (ví dụ: "Mạch nhanh", "Rối loạn nhịp tim")
  notes?: string; // Ghi chú bổ sung (tùy chọn) - ví dụ: “Đang trong quá trình phục hồi sau phẫu thuật”
}

export interface IAiEvaluation {
  summary: string; // Mô tả tổng quan (AI sinh ra)
  score?: number; // Điểm đánh giá sức khỏe (0–100)
  riskLevel?: RiskLevelEnum; // Mức rủi ro sức khỏe
  updatedAt?: Date; // Lần cập nhật gần nhất
  modelVersion?: string; // Phiên bản AI sử dụng
}

export interface IHealthProfile extends Document {
  _id: Types.ObjectId;
  userId: Types.ObjectId;
  checkupDate: Date;

  age: number;
  height?: number;
  weight?: number;
  waist?: number;
  neck?: number;
  hip?: number;
  whr?: number;
  bmi?: number;
  bmr?: number;
  bodyFatPercentage?: number;
  muscleMass?: number;
  maxPushUps?: number;
  maxWeightLifted?: number;
  activityLevel?: number;
  experienceLevel?: ExperienceLevelEnum;
  workoutFrequency?: number;

  restingHeartRate?: number;
  bloodPressure?: IBloodPressure;
  cholesterol?: ICholesterol;
  bloodSugar?: number;

  healthStatus?: IHealthStatus;

  aiEvaluation?: IAiEvaluation;
}

const healthProfileSchema = new Schema<IHealthProfile>(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    checkupDate: { type: Date, required: true, default: Date.now },

    age: { type: Number, required: true },
    height: Number,
    weight: Number,
    waist: Number,
    neck: Number,
    hip: Number,
    whr: Number,
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

    aiEvaluation: {
      summary: { type: String, default: "" },
      score: Number,
      riskLevel: { type: String, enum: RiskLevelTuple },
      updatedAt: Date,
      modelVersion: String,
    },
  },
  {
    timestamps: true, // createdAt & updatedAt
  }
);

// Index _userId để query nhanh
healthProfileSchema.index({ _userId: 1, checkupDate: -1 });

export const HealthProfile = mongoose.model<IHealthProfile>(
  "HealthProfile",
  healthProfileSchema
);

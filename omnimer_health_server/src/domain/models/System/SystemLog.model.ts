import mongoose, { Schema, Document, Types } from "mongoose";
import {
  LevelLogEnum,
  LevelLogTuple,
  StatusLogEnum,
  StatusLogTuple,
} from "../../../common/constants/AppConstants";

export interface ISystemLog extends Document {
  userId: Types.ObjectId;
  action: string;
  status: StatusLogEnum;
  level: LevelLogEnum;
  targetId?: Types.ObjectId;
  metadata?: Record<string, any>;
  errorMessage?: string;
}

const SystemLogSchema = new Schema<ISystemLog>(
  {
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    action: { type: String, required: true },
    status: { type: String, enum: StatusLogTuple, required: true },
    level: { type: String, enum: LevelLogTuple, required: true },
    targetId: Schema.Types.ObjectId,
    metadata: Schema.Types.Mixed,
    errorMessage: String,
  },
  { timestamps: true }
);

SystemLogSchema.index({ userId: 1, action: 1, timestamp: -1, level: 1 });

export const SystemLog = mongoose.model<ISystemLog>(
  "SystemLog",
  SystemLogSchema
);

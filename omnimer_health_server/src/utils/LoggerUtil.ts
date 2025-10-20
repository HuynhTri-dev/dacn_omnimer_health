import logger from "../common/configs/logger";
import { StatusLogEnum, LevelLogEnum } from "../common/constants/AppConstants";
import { SystemLogRepository } from "../domain/repositories";
import mongoose from "mongoose";

const systemLogRepo = new SystemLogRepository();

interface LogOptions {
  userId?: string;
  action: string;
  message: string;
  metadata?: Record<string, any>;
  targetId?: string;
  errorMessage?: string;
}

// =================== LOG FUNCTIONS ===================

// Hành động thành công, bình thường
export async function logInfo(options: LogOptions) {
  await log({
    ...options,
    level: LevelLogEnum.Info,
    status: StatusLogEnum.Success,
  });
}

// Cảnh báo, cần chú ý
export async function logWarn(options: LogOptions) {
  await log({
    ...options,
    level: LevelLogEnum.Warn,
    status: StatusLogEnum.Success,
  });
}

// Lỗi, exception
export async function logError(options: LogOptions) {
  await log({
    ...options,
    level: LevelLogEnum.Error,
    status: StatusLogEnum.Failure,
    errorMessage: options.errorMessage || options.message,
  });
}

// Debug thông tin chi tiết, chỉ dùng dev
export async function logDebug(options: LogOptions) {
  if (process.env.NODE_ENV === "development") {
    await log({
      ...options,
      level: LevelLogEnum.Debug,
      status: StatusLogEnum.Success,
    });
  }
}

// Audit log – ghi business outcome success/fail
export async function logAudit({
  userId,
  action,
  message,
  status,
  metadata,
  targetId,
  errorMessage,
}: LogOptions & { status: StatusLogEnum }) {
  await log({
    userId,
    action,
    message,
    status,
    level:
      status === StatusLogEnum.Success ? LevelLogEnum.Info : LevelLogEnum.Error,
    metadata,
    targetId,
    errorMessage,
  });
}

// =================== CORE LOG FUNCTION ===================
async function log({
  userId,
  action,
  status = StatusLogEnum.Success,
  level = LevelLogEnum.Info,
  message,
  metadata = {},
  targetId,
  errorMessage,
}: LogOptions & { status?: StatusLogEnum; level?: LevelLogEnum }) {
  try {
    // Log ra console/file
    logger.log(level, `[${action}] ${message}`);

    // Nếu là production thì ghi vào DB
    if (process.env.NODE_ENV === "production") {
      await systemLogRepo.create({
        userId: new mongoose.Types.ObjectId(userId),
        action,
        status,
        level,
        targetId: targetId ? new mongoose.Types.ObjectId(targetId) : undefined,
        metadata,
        errorMessage,
      });
    }
  } catch (err) {
    logger.error(`Failed to log action: ${err}`);
  }
}

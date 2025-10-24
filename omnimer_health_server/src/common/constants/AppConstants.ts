export const DEFAULT_ZONE = "Asia/Ho_Chi_Minh";
export const DEFAULT_PAGE = 1;
export const DEFAULT_LIMIT = 20;
export const DEFAULT_SORT: Record<string, 1 | -1> = { createdAt: -1 };

// =================== STATUS LOG ===================
export enum StatusLogEnum {
  Success = "success",
  Failure = "failure",
}

// Tuple tự động từ enum TS để dùng trong Mongoose enum
export const StatusLogTuple = Object.values(StatusLogEnum) as [
  StatusLogEnum,
  ...StatusLogEnum[]
];

// =================== STATUS LOG ===================
export enum LevelLogEnum {
  Info = "info",
  Warn = "warn",
  Error = "error",
  Debug = "debug",
}

// Tuple tự động từ enum TS để dùng trong Mongoose enum
export const LevelLogTuple = Object.values(LevelLogEnum) as [
  LevelLogEnum,
  ...LevelLogEnum[]
];

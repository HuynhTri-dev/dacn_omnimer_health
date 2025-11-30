import mongoose, { Document, Schema, Types } from "mongoose";
import {
  DeviceTypeEnum,
  DeviceTypeTuple,
} from "../../../common/constants/EnumConstants";

export interface IWatchLog extends Document {
  _id: Types.ObjectId;
  userId: Types.ObjectId;
  workoutId?: Types.ObjectId; // Nếu log này thuộc về 1 bài tập cụ thể
  date: Date; // Ngày ghi nhận (thường set giờ về 00:00:00 hoặc cuối ngày)

  // Device Information
  deviceType: DeviceTypeEnum; // Loại thiết bị/nguồn dữ liệu (bắt buộc)
  nameDevice?: string; // Tên tùy chỉnh của thiết bị người dùng đặt (tùy chọn)

  // --- 1. Vital Signs (Sinh hiệu) ---
  heartRateRest?: number; // Nhịp tim nghỉ (bpm)
  heartRateAvg?: number; // Nhịp tim trung bình (bpm)
  heartRateMax?: number; // Nhịp tim tối đa (bpm)
  heartRateVariability?: number; // HRV (ms) - Chỉ số Stress sinh học
  spo2Avg?: number; // Oxy máu trung bình (%)
  spo2Min?: number; // Oxy máu thấp nhất (%)
  respiratoryRate?: number; // Nhịp thở khi ngủ (lần/phút)
  skinTemperature?: number; // Nhiệt độ da (độ C)

  // Huyết áp (nếu có thiết bị hỗ trợ)
  bloodPressureSystolic?: number; // Tâm thu
  bloodPressureDiastolic?: number; // Tâm trương

  // --- 2. Activity & Mobility (Vận động) ---
  steps?: number;
  distance?: number; // mét hoặc km (nên thống nhất 1 đơn vị, khuyến nghị: mét)
  caloriesActive?: number; // Calo tiêu hao do vận động (kcal)
  caloriesBMR?: number; // Calo nghỉ/nền (kcal)
  caloriesTotal?: number; // Tổng cộng (kcal)
  activeMinutes?: number; // Số phút vận động tích cực
  floorsClimbed?: number; // Số tầng cầu thang đã leo
  standHours?: number; // Số giờ có đứng dậy vận động (Apple Ring)

  // --- 3. Sleep & Recovery (Giấc ngủ) ---
  sleepDuration?: number; // Tổng thời gian ngủ (phút hoặc giờ)
  sleepDeep?: number; // Thời gian ngủ sâu (Deep)
  sleepREM?: number; // Thời gian ngủ mơ (REM)
  sleepLight?: number; // Thời gian ngủ nông (Light)
  sleepAwake?: number; // Thời gian thức giấc giữa đêm
  sleepQuality?: number; // Điểm giấc ngủ (0-100)
  stressLevel?: number; // Điểm stress trung bình (0-100)

  // --- 4. Cardio Fitness (Hiệu suất) ---
  vo2max?: number; // (ml/kg/min)
  runningCadenceAvg?: number; // Nhịp bước chạy trung bình (spm)
  runningPowerAvg?: number; // Công suất chạy (Watts) - Garmin/Apple Watch

  // --- 5. Body Composition (Thành phần cơ thể - Galaxy Watch) ---
  bodyFatPercentage?: number; // % Mỡ
  skeletalMuscleMass?: number; // Khối lượng cơ xương (kg)
  bodyWaterMass?: number; // Khối lượng nước (kg)
  bmi?: number; // BMI

  // Metadata cho truy xuất nguồn gốc
  sourceBundleId?: string; // VD: "com.google.android.apps.fitness" hoặc "com.sec.android.app.shealth"
}

const watchLogSchema = new Schema<IWatchLog>(
  {
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    workoutId: { type: Schema.Types.ObjectId, ref: "Workout" },

    date: { type: Date, required: true },

    // Device Info
    deviceType: { type: String, enum: DeviceTypeTuple, required: true },
    nameDevice: { type: String, required: false },

    // 1. Vital Signs
    heartRateRest: Number,
    heartRateAvg: Number,
    heartRateMax: Number,
    heartRateVariability: Number,
    spo2Avg: Number,
    spo2Min: Number,
    respiratoryRate: Number,
    skinTemperature: Number,
    bloodPressureSystolic: Number,
    bloodPressureDiastolic: Number,

    // 2. Activity
    steps: { type: Number, default: 0 },
    distance: { type: Number, default: 0 },
    caloriesActive: { type: Number, default: 0 },
    caloriesBMR: { type: Number, default: 0 },
    caloriesTotal: { type: Number, default: 0 },
    activeMinutes: { type: Number, default: 0 },
    floorsClimbed: Number,
    standHours: Number,

    // 3. Sleep
    sleepDuration: Number,
    sleepDeep: Number,
    sleepREM: Number,
    sleepLight: Number,
    sleepAwake: Number,
    sleepQuality: Number,
    stressLevel: Number,

    // 4. Cardio
    vo2max: Number,
    runningCadenceAvg: Number,
    runningPowerAvg: Number,

    // 5. Body Comp
    bodyFatPercentage: Number,
    skeletalMuscleMass: Number,
    bodyWaterMass: Number,
    bmi: Number,

    sourceBundleId: String,
  },
  {
    timestamps: true, // Tự động tạo createdAt, updatedAt
  }
);

// --- INDEXING ---
// 1. Tìm kiếm log của User theo ngày (Query phổ biến nhất)
watchLogSchema.index({ userId: 1, date: -1 });
// Lưu ý: Không dùng unique: true để cho phép nhiều log trong một ngày (VD: Daily Log + Workout Logs)

// 2. Thống kê theo loại thiết bị
watchLogSchema.index({ deviceType: 1 });

export const WatchLog = mongoose.model<IWatchLog>("WatchLog", watchLogSchema);

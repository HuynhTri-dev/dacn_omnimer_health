import { GenderEnum } from "../../common/constants/EnumConstants";

export interface HealthInput {
  gender?: GenderEnum;
  height?: number; // cm
  weight?: number; // kg
  neck?: number; // cm
  waist?: number; // cm
  hip?: number; // cm
  birthday?: Date;
  raceFactor?: number;
  whr?: number;
  bmi?: number;
  bmr?: number;
  bodyFatPercentage?: number;
  muscleMass?: number;
}

export interface HealthResult {
  age: number;
  bmi: number;
  bmr: number;
  bodyFatPercentage: number;
  muscleMass: number;
  whr: number;
}

/**
 * Tính toán các chỉ số sức khỏe dựa trên thông tin người dùng.
 * Nếu user không nhập sẵn thì sẽ tự động tính theo công thức.
 */
export function calculateHealthMetrics({
  gender,
  height,
  weight,
  neck,
  waist,
  hip,
  birthday,
  raceFactor = 0,
  bmi,
  bmr,
  bodyFatPercentage,
  muscleMass,
  whr,
}: HealthInput): HealthResult {
  // Chuẩn hóa dữ liệu đầu vào
  const h = Number(height) || 0;
  const w = Number(weight) || 0;
  const n = Number(neck) || 0;
  const wa = Number(waist) || 0;
  const hi = Number(hip) || 0;

  // Tuổi
  const age =
    birthday instanceof Date
      ? Math.floor(
          (Date.now() - birthday.getTime()) / (1000 * 60 * 60 * 24 * 365.25)
        )
      : 0;

  // --- Nếu có giá trị user nhập thì giữ nguyên, nếu không thì tính ---

  // 1. BMI
  const computedBMI = h > 0 ? w / (h / 100) ** 2 : 0;
  const finalBMI = bmi ?? parseFloat(computedBMI.toFixed(2));

  // 2. BMR
  const computedBMR =
    gender === GenderEnum.Male
      ? 88.362 + 13.397 * w + 4.799 * h - 5.677 * age
      : 447.593 + 9.247 * w + 3.098 * h - 4.33 * age;
  const finalBMR = bmr ?? parseFloat(computedBMR.toFixed(2));

  // 3. Body Fat %
  let computedBodyFat = 0;
  try {
    if (gender === GenderEnum.Male) {
      computedBodyFat =
        495 /
          (1.0324 -
            0.19077 * Math.log10(Math.max(wa - n, 1)) +
            0.15456 * Math.log10(h)) -
        450;
    } else {
      computedBodyFat =
        495 /
          (1.29579 -
            0.35004 * Math.log10(Math.max(wa + hi - n, 1)) +
            0.221 * Math.log10(h)) -
        450;
    }
  } catch {
    computedBodyFat = 0;
  }
  const finalBodyFat =
    bodyFatPercentage ?? parseFloat(computedBodyFat.toFixed(2));

  // 4. Muscle Mass
  const sex = gender === GenderEnum.Male ? 1 : 0;
  const computedMuscleMass =
    0.244 * w + 7.8 * (h / 100) + 6.6 * sex - 0.098 * age + raceFactor - 3.3;
  const finalMuscleMass =
    muscleMass ?? parseFloat(computedMuscleMass.toFixed(2));

  // 5. WHR
  const computedWHR = hi > 0 ? wa / hi : 0; // sửa lại logic đúng
  const finalWHR = whr ?? parseFloat(computedWHR.toFixed(2));

  return {
    age,
    bmi: finalBMI,
    bmr: finalBMR,
    bodyFatPercentage: finalBodyFat,
    muscleMass: finalMuscleMass,
    whr: finalWHR,
  };
}

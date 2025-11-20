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

// --- Helper functions ---

function calculateBMI(weight: number, height: number): number {
  if (!weight || !height) return 0;
  return parseFloat((weight / (height / 100) ** 2).toFixed(2));
}

function calculateBMR(
  gender: GenderEnum | undefined,
  weight: number,
  height: number,
  age: number
): number {
  if (!weight || !height || age <= 0 || !gender) return 0;
  const bmr =
    gender === GenderEnum.Male
      ? 88.362 + 13.397 * weight + 4.799 * height - 5.677 * age
      : 447.593 + 9.247 * weight + 3.098 * height - 4.33 * age;
  return parseFloat(bmr.toFixed(2));
}

function calculateBodyFat(
  gender: GenderEnum | undefined,
  waist: number,
  hip: number,
  neck: number,
  height: number
): number {
  try {
    if (!gender || !height || !waist || !hip) return 0;
    let bf = 0;
    if (gender === GenderEnum.Male) {
      bf =
        495 /
          (1.0324 -
            0.19077 * Math.log10(Math.max(waist - neck, 0.1)) +
            0.15456 * Math.log10(height)) -
        450;
    } else {
      bf =
        495 /
          (1.29579 -
            0.35004 * Math.log10(Math.max(waist + hip - neck, 0.1)) +
            0.221 * Math.log10(height)) -
        450;
    }
    if (!isFinite(bf) || bf < 0) bf = 0;
    return parseFloat(bf.toFixed(2));
  } catch {
    return 0;
  }
}

function calculateMuscleMass(
  gender: GenderEnum | undefined,
  weight: number,
  height: number,
  age: number,
  raceFactor: number = 0
): number {
  if (!weight || !height || age <= 0) return 0;
  const sex = gender === GenderEnum.Male ? 1 : 0;
  const mm =
    0.244 * weight +
    7.8 * (height / 100) +
    6.6 * sex -
    0.098 * age +
    raceFactor -
    3.3;
  return parseFloat(mm.toFixed(2));
}

function calculateWHR(waist: number, hip: number): number {
  if (!waist || !hip) return 0;
  return parseFloat((waist / hip).toFixed(2));
}

function calculateAge(birthday?: Date): number {
  if (!birthday) return 0;
  return Math.floor(
    (Date.now() - birthday.getTime()) / (1000 * 60 * 60 * 24 * 365.25)
  );
}

// --- Main function ---

export function calculateHealthMetrics(input: HealthInput): HealthResult {
  const h = Number(input.height) || 0;
  const w = Number(input.weight) || 0;
  const n = Number(input.neck) || 0;
  const wa = Number(input.waist) || 0;
  const hi = Number(input.hip) || 0;
  const age = calculateAge(input.birthday);

  console.log("Input", input);

  const bmi = input.bmi && input.bmi > 0 ? input.bmi : calculateBMI(w, h);
  const bmr =
    input.bmr && input.bmr > 0
      ? input.bmr
      : calculateBMR(input.gender, w, h, age);
  const bodyFat =
    input.bodyFatPercentage !== undefined && input.bodyFatPercentage > 0
      ? input.bodyFatPercentage
      : calculateBodyFat(input.gender, wa, hi, n, h);
  const muscleMass =
    input.muscleMass !== undefined && input.muscleMass > 0
      ? input.muscleMass
      : calculateMuscleMass(input.gender, w, h, age, input.raceFactor || 0);
  const whr =
    input.whr !== undefined && input.whr > 0 ? input.whr : calculateWHR(wa, hi);

  return {
    age,
    bmi,
    bmr,
    bodyFatPercentage: bodyFat,
    muscleMass,
    whr,
  };
}

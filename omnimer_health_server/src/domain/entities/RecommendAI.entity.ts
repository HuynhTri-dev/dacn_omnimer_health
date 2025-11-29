// src/entities/rag.entity.ts
import { Types } from "mongoose";
import {
  GenderEnum,
  GoalTypeEnum,
  LocationEnum,
} from "../../common/constants/EnumConstants";
import { IHealthStatus, ITargetMetric } from "../models";

export interface IRAGGoal {
  goalType: GoalTypeEnum;
  targetMetric: ITargetMetric[];
}

export interface IRAGExercise {
  exerciseId: string;
  exerciseName: string;
}

export interface IRAGHealthProfile {
  gender: GenderEnum;
  age: number;
  height: number | null; // cm
  weight: number | null; // kg
  bmi: number | null;
  bodyFatPercentage: number | null;
  activityLevel: number | null;
  experienceLevel: string | null;
  workoutFrequency: number | null;
  restingHeartRate: number | null;
  maxWeightLifted?: number | null;
  healthStatus: IHealthStatus | null;
}

export interface IRAGUserContext {
  healthProfile: IRAGHealthProfile;
  goals: IRAGGoal[];
  exercises: IRAGExercise[];
  k: number;
}

export interface UserRAGRequest {
  equipmentIds?: Types.ObjectId[]; // ref: Equipment
  bodyPartIds?: Types.ObjectId[]; // ref: BodyPart
  muscleIds?: Types.ObjectId[]; // ref: Muscle
  exerciseTypes?: Types.ObjectId[]; // ref: ExerciseType
  exerciseCategories?: Types.ObjectId[]; // ref: ExerciseCategory
  location?: LocationEnum;
  k?: number;
}

export interface ISetDetail {
  reps: number | null;
  kg: number | null;
  distance: number | null;
  duration: number | null;
  restAfterSetSeconds: number | null;
}

export interface IRecommendedExercise {
  name: string;
  sets: ISetDetail[];
}

export interface IRAGAIResponse {
  exercises: IRecommendedExercise[];
}

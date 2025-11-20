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
  height?: number;
  weight?: number;
  whr?: number;
  bmi?: number;
  bmr?: number;
  bodyFatPercentage?: number;
  muscleMass?: number;
  maxWeightLifted?: number;
  activityLevel?: number;
  experienceLevel?: string;
  workoutFrequency?: number;
  restingHeartRate?: number;
  healthStatus?: IHealthStatus;
}

export interface IRAGUserContext {
  healthProfile: IRAGHealthProfile;
  goals?: IRAGGoal[];
  exercises?: IRAGExercise[];
}

export interface UserRAGRequest {
  equipmentIds: Types.ObjectId[]; // ref: Equipment
  bodyPartIds: Types.ObjectId[]; // ref: BodyPart
  muscleIds?: Types.ObjectId[]; // ref: Muscle
  exerciseTypes: Types.ObjectId[]; // ref: ExerciseType
  exerciseCategories: Types.ObjectId[]; // ref: ExerciseCategory
  location: LocationEnum;
}

export interface IWorkoutTemplateSet {
  reps?: number;
  kg?: number;
  km?: number;
  min?: number;
  minRest?: number;
}

export interface IWorkoutTemplateExercise {
  name: string;
  sets: IWorkoutTemplateSet[];
}

export interface IRAGAIResponse {
  exercises: IWorkoutTemplateExercise[];
  suitabilityScore: number;
  predictedAvgHR?: number;
  predictedPeakHR?: number;
}

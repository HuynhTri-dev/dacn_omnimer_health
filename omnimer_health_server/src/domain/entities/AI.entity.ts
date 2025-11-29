// src/entities/AI.entity.ts
import { Types } from "mongoose";
import {
  GenderEnum,
  GoalTypeEnum,
  WorkoutDetailTypeEnum,
  LocationEnum
} from "../../common/constants/EnumConstants";
import { IHealthStatus, ITargetMetric } from "../models";

// ============== RECOMMEND WORKFLOW ENTITIES ==============

export interface IRecommendHealthProfile {
  gender: GenderEnum;
  age: number;
  height: number;
  weight: number;
  bmi: number;
  bodyFatPercentage: number;
  activityLevel: number;
  experienceLevel: string;
  workoutFrequency: number;
  restingHeartRate: number;
  healthStatus: IHealthStatus;
}

export interface IRecommendGoal {
  goalType: GoalTypeEnum;
  targetMetric: ITargetMetric[];
}

export interface IRecommendExercise {
  exerciseId: string;
  exerciseName: string;
}

export interface IRecommendInput {
  healthProfile: IRecommendHealthProfile;
  goals: IRecommendGoal[];
  exercises: IRecommendExercise[];
  k?: number; // Number of exercises to return
}

export interface IRecommendSet {
  reps?: number;
  kg?: number;
  km?: number;
  min?: number;
  minRest?: number;
  duration?: number;
  restAfterSetSeconds?: number;
  distance?: number;
}

export interface IRecommendExercise {
  name: string;
  sets: IRecommendSet[];
}

export interface IRecommendOutput {
  exercises: IRecommendExercise[];
}

// ============== EVALUATE WORKFLOW ENTITIES ==============

export interface IEvaluateHealthProfile {
  gender: GenderEnum;
  age: number;
  height: number;
  weight: number;
  bmi: number;
  bodyFatPercentage: number;
  activityLevel: number;
  experienceLevel: string;
  workoutFrequency: number;
  restingHeartRate: number;
  healthStatus: IHealthStatus;
}

export interface IEvaluateSet {
  setOrder: number;
  reps?: number;
  weight?: number;
  duration?: number;
  distance?: number;
  restAfterSetSeconds?: number;
  notes?: string;
  done: boolean;
}

export interface IEvaluateWorkoutDetail {
  _id: string;
  exerciseId: string;
  type: WorkoutDetailTypeEnum; // "reps", "distance", "time"
  sets: IEvaluateSet[];
  durationMin: number;
  deviceData: {
    heartRateAvg: number;
    heartRateMax: number;
    caloriesBurned: number;
  };
}

export interface IEvaluateSummary {
  heartRateAvgAllWorkout: number;
  heartRateMaxAllWorkout: number;
  totalSets: number;
  totalReps: number;
  totalWeight: number;
  totalDuration: number;
  totalCalories: number;
  totalDistance: number;
}

export interface IEvaluateInput {
  healthProfile: IEvaluateHealthProfile;
  timeStart: string; // ISO datetime
  notes?: string;
  workoutDetail: IEvaluateWorkoutDetail[];
  summary?: IEvaluateSummary;
  createdAt?: string;
  updatedAt?: string;
}

export interface IEvaluateResult {
  exerciseName: string;
  intensityScore: number; // 1-5 scale
  suitability: number; // 0-1 scale
}

export interface IEvaluateOutput {
  results: IEvaluateResult[];
}

// ============== AI SERVICE REQUEST/RESPONSE ENTITIES ==============

export interface IAIServiceRequest {
  type: 'recommend' | 'evaluate';
  data: IRecommendInput | IEvaluateInput;
}

export interface IAIServiceResponse {
  type: 'recommend' | 'evaluate';
  data: IRecommendOutput | IEvaluateOutput;
  success: boolean;
  message?: string;
}

// ============== LEGACY RAG COMPATIBILITY ==============

// Keep existing RAG interfaces for backward compatibility
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

export interface UserRAGRequest {
  equipmentIds: Types.ObjectId[];
  bodyPartIds: Types.ObjectId[];
  muscleIds?: Types.ObjectId[];
  exerciseTypes: Types.ObjectId[];
  exerciseCategories: Types.ObjectId[];
  location: LocationEnum;
}
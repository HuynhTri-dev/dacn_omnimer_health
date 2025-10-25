import mongoose, { Schema, Document, Types } from "mongoose";
import {
  DifficultyLevelEnum,
  DifficultyLevelTuple,
  LocationEnum,
  LocationTuple,
} from "../../../common/constants/EnumConstants";

export interface IExercise extends Document {
  _id: Types.ObjectId;
  name: string;
  description?: string | null;
  instructions?: string;

  equipment: Types.ObjectId[]; // ref: Equipment
  bodyPart: Types.ObjectId[]; // ref: BodyPart
  mainMuscles?: Types.ObjectId[]; // ref: Muscle
  secondaryMuscles?: Types.ObjectId[]; // ref: Muscle
  exerciseTypes: Types.ObjectId[]; // ref: ExerciseType
  exerciseCategories: Types.ObjectId[]; // ref: ExerciseCategory
  location: LocationEnum;

  difficulty?: DifficultyLevelEnum;
  imageUrl?: string | null;
  videoUrl?: string | null;

  rating?: { avg: number; count: number };
}

const exerciseSchema = new Schema<IExercise>(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },

    name: { type: String, required: true },
    description: { type: String, default: null },
    instructions: { type: String, default: null },

    equipment: {
      type: [{ type: Schema.Types.ObjectId, ref: "Equipment" }],
      required: true,
    },
    bodyPart: {
      type: [{ type: Schema.Types.ObjectId, ref: "BodyPart" }],
      required: true,
    },
    mainMuscles: [{ type: Schema.Types.ObjectId, ref: "Muscle" }],
    secondaryMuscles: [{ type: Schema.Types.ObjectId, ref: "Muscle" }],
    exerciseTypes: {
      type: [{ type: Schema.Types.ObjectId, ref: "ExerciseType" }],
      required: true,
    },
    exerciseCategories: {
      type: [{ type: Schema.Types.ObjectId, ref: "ExerciseCategory" }],
      required: true,
    },

    location: {
      type: String,
      enum: LocationTuple,
      default: LocationEnum.None,
    },

    difficulty: {
      type: String,
      enum: DifficultyLevelTuple,
      default: DifficultyLevelEnum.Beginner,
    },

    imageUrl: { type: String, default: null },
    videoUrl: { type: String, default: null },

    rating: {
      type: {
        avg: { type: Number, default: 0 },
        count: { type: Number, default: 0 },
      },
      default: { avg: 0, count: 0 },
    },
  },
  { timestamps: true }
);

export const Exercise = mongoose.model<IExercise>("Exercise", exerciseSchema);

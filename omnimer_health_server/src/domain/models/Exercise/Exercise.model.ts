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

  equipments: Types.ObjectId[]; // ref: Equipment
  bodyParts: Types.ObjectId[]; // ref: BodyPart
  mainMuscles?: Types.ObjectId[]; // ref: Muscle
  secondaryMuscles?: Types.ObjectId[]; // ref: Muscle
  exerciseTypes: Types.ObjectId[]; // ref: ExerciseType
  exerciseCategories: Types.ObjectId[]; // ref: ExerciseCategory
  location: LocationEnum;

  difficulty?: DifficultyLevelEnum;
  imageUrls?: string[];
  videoUrl?: string | null;

  met?: number | null;
}

const exerciseSchema = new Schema<IExercise>(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },

    name: { type: String, required: true },
    description: { type: String, default: null },
    instructions: { type: String, default: null },

    equipments: {
      type: [{ type: Schema.Types.ObjectId, ref: "Equipment" }],
      required: true,
    },
    bodyParts: {
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

    imageUrls: { type: [String], default: [] },
    videoUrl: { type: String, default: null },

    met: { type: Number, default: null },
  },
  { timestamps: true }
);

export const Exercise = mongoose.model<IExercise>("Exercise", exerciseSchema);

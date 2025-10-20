import mongoose, { Schema, Document, Types } from "mongoose";
import { DifficultyLevelEnum } from "../../common/constants/EnumConstants";

export interface IExercise extends Document {
  _id: Types.ObjectId;
  name: string;
  description?: string | null;
  instructions?: string;
  equipment: Types.ObjectId[]; // ref: Equipment
  bodyPart: Types.ObjectId[]; // ref: BodyPart
  mainMuscles: Types.ObjectId[]; // ref: Muscle
  secondaryMuscles: Types.ObjectId[]; // ref: Muscle
  exerciseTypes: Types.ObjectId[]; // ref: ExerciseType
  difficulty?: DifficultyLevelEnum;
  imageUrl?: string | null;
  videoUrl?: string | null;
  gifUrl?: string | null;
  rating?: { avg: number; count: number }; // Thêm rating
  tags?: string[]; // Thêm tags
  contraindications?: string[]; // Thêm contraindications
  targetAudience?: string[]; // Thêm targetAudience
}

const exerciseSchema = new Schema<IExercise>(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },
    name: { type: String, required: true },
    description: { type: String },
    instructions: { type: String },

    equipment: [
      { type: Schema.Types.ObjectId, ref: "Equipment", required: true },
    ],
    bodyPart: [
      { type: Schema.Types.ObjectId, ref: "BodyPart", required: true },
    ],
    mainMuscles: [
      { type: Schema.Types.ObjectId, ref: "Muscle", required: true },
    ],
    secondaryMuscles: [
      { type: Schema.Types.ObjectId, ref: "Muscle", required: true },
    ],
    exerciseTypes: [
      { type: Schema.Types.ObjectId, ref: "ExerciseType", required: true },
    ],

    difficulty: {
      type: String,
      enum: Object.values(DifficultyLevelEnum),
      default: DifficultyLevelEnum.Beginner,
    },
    imageUrl: { type: String, default: null },
    videoUrl: { type: String, default: null },
    gifUrl: { type: String, default: null },

    // Mở rộng
    rating: {
      avg: { type: Number, default: 0 },
      count: { type: Number, default: 0 },
    },
    tags: { type: [String], default: [] },
    contraindications: { type: [String], default: [] },
    targetAudience: { type: [String], default: [] },
  },
  { timestamps: true }
);

export const Exercise = mongoose.model<IExercise>("Exercise", exerciseSchema);

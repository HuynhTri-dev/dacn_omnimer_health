import mongoose, { Schema, Document, Types, Model } from "mongoose";

// Interface cho Workout Feedback
export interface IWorkoutFeedback extends Document {
  _id: Types.ObjectId;
  workoutId: Types.ObjectId; // liên kết đến Workout
  suitability?: number; // 1-10
  workout_goal_achieved?: boolean;
  target_muscle_felt?: boolean;
  injury_or_pain_notes?: string;
  exercise_not_suitable?: Types.ObjectId[];
  additionalNotes?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

const WorkoutFeedbackSchema: Schema<IWorkoutFeedback> = new Schema(
  {
    _id: { type: Schema.Types.ObjectId, auto: true },
    workoutId: {
      type: Schema.Types.ObjectId,
      ref: "Workout",
      required: true,
    },
    suitability: { type: Number, min: 1, max: 10 },
    workout_goal_achieved: { type: Boolean },
    target_muscle_felt: { type: Boolean },
    injury_or_pain_notes: { type: String },
    exercise_not_suitable: [{ type: Types.ObjectId, ref: "Exercise" }],
    additionalNotes: { type: String },
  },
  {
    timestamps: true,
  }
);

export const WorkoutFeedback: Model<IWorkoutFeedback> =
  mongoose.model<IWorkoutFeedback>("WorkoutFeedback", WorkoutFeedbackSchema);

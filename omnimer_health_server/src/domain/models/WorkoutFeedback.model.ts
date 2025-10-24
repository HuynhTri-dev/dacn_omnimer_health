import mongoose, { Schema, Document, Types, Model } from "mongoose";

// Interface cho Workout Feedback
export interface IWorkoutFeedback extends Document {
  _workoutId: Types.ObjectId; // liên kết đến Workout
  suitability?: number; // 1-5
  workout_goal_achieved?: boolean;
  target_muscle_felt?: string;
  injury_or_pain_notes?: string;
  exercise_not_suitable?: boolean;
  additionalNotes?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

const WorkoutFeedbackSchema: Schema<IWorkoutFeedback> = new Schema(
  {
    _workoutId: {
      type: Schema.Types.ObjectId,
      ref: "Workout",
      required: true,
    },
    suitability: { type: Number, min: 1, max: 5 },
    workout_goal_achieved: { type: Boolean },
    target_muscle_felt: { type: String },
    injury_or_pain_notes: { type: String },
    exercise_not_suitable: { type: Boolean },
    additionalNotes: { type: String },
  },
  {
    timestamps: true,
  }
);

export const WorkoutFeedback: Model<IWorkoutFeedback> =
  mongoose.model<IWorkoutFeedback>("WorkoutFeedback", WorkoutFeedbackSchema);

import { Model } from "mongoose";
import { IWorkoutFeedback } from "../../models";
import { BaseRepository } from "../Base.repository";

export class WorkoutFeedbackRepository extends BaseRepository<IWorkoutFeedback> {
  constructor(model: Model<IWorkoutFeedback>) {
    super(model);
  }
}

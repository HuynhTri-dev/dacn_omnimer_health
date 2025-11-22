import { Model } from "mongoose";
import { BaseRepository } from "../Base.repository";
import { IExerciseRating } from "../../models";

export class ExerciseRatingRepository extends BaseRepository<IExerciseRating> {
  constructor(model: Model<IExerciseRating>) {
    super(model);
  }
}

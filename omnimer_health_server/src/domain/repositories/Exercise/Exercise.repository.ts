import { Model } from "mongoose";
import { IExercise } from "../../models";
import { BaseRepository } from "../Base.repository";

export class ExerciseRepository extends BaseRepository<IExercise> {
  constructor(model: Model<IExercise>) {
    super(model);
  }
}

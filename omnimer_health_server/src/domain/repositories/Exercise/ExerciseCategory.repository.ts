import { Model } from "mongoose";
import { IExerciseCategory } from "../../models";
import { BaseRepository } from "../base.repository";

export class ExerciseCategoryRepository extends BaseRepository<IExerciseCategory> {
  constructor(model: Model<IExerciseCategory>) {
    super(model);
  }
}

import { Model } from "mongoose";
import { IExerciseType } from "../../models";
import { BaseRepository } from "../base.repository";

export class ExerciseTypeRepository extends BaseRepository<IExerciseType> {
  constructor(model: Model<IExerciseType>) {
    super(model);
  }
}

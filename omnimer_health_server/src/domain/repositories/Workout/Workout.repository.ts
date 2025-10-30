import { Model } from "mongoose";
import { IWorkout } from "../../models";
import { BaseRepository } from "../Base.repository";

export class WorkoutRepository extends BaseRepository<IWorkout> {
  constructor(model: Model<IWorkout>) {
    super(model);
  }
}

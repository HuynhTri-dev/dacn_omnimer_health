import { Model } from "mongoose";
import { IWorkoutTemplate } from "../../models";
import { BaseRepository } from "../Base.repository";

export class WorkoutTemplateRepository extends BaseRepository<IWorkoutTemplate> {
  constructor(model: Model<IWorkoutTemplate>) {
    super(model);
  }
}

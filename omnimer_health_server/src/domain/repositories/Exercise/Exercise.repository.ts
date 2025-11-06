import { Model, Types } from "mongoose";
import { IExercise } from "../../models";
import { BaseRepository } from "../Base.repository";
import {
  IRAGExercise,
  IRAGHealthProfile,
  UserRAGRequest,
} from "../../entities";
import { getSuitableDifficultyLevels } from "../../../utils/ExerciseHelper";

export class ExerciseRepository extends BaseRepository<IExercise> {
  constructor(model: Model<IExercise>) {
    super(model);
  }

  /**
   * Filters exercises based on user-specific RAG conditions such as equipment, body parts, muscles, exercise types, and categories.
   * Any filter field that is empty or undefined will be ignored in the query.
   *
   * @param {UserRAGRequest} filter - Object containing optional filtering criteria.
   * @param {string[]} [filter.equipmentIds] - List of equipment IDs (e.g., Dumbbell, Barbell, Bodyweight).
   * @param {string[]} [filter.bodyPartIds] - List of body part IDs (e.g., Chest, Legs, Back).
   * @param {string[]} [filter.muscleIds] - List of muscle IDs including both main and secondary muscles.
   * @param {string[]} [filter.exerciseTypes] - List of exercise type IDs (e.g., Strength, Cardio).
   * @param {string[]} [filter.exerciseCategories] - List of exercise category IDs (e.g., Compound, Isolation).
   * @param {string} [filter.location] - Exercise location (e.g., "Gym", "Home", "Outdoor").
   *
   * @returns {Promise<IRAGExercise[]>} A promise resolving to a list of exercises that match the given filters.
   *
   * @example
   * const exercises = await exerciseRepository.filterExerciseForRAG({
   *   equipmentIds: ["66b7...", "66b8..."],
   *   muscleIds: ["66a9..."],
   *   location: "Gym"
   * });
   *
   * Example output:
   * [
   *   { exerciseId: "670c...", exerciseName: "Bench Press" },
   *   { exerciseId: "671a...", exerciseName: "Squat" }
   * ]
   */

  async filterExerciseForRAG(
    filter?: UserRAGRequest,
    profile?: IRAGHealthProfile
  ): Promise<IRAGExercise[]> {
    const query: any = {};

    if (filter) {
      // Equipment
      if (filter.equipmentIds?.length)
        query["equipments"] = {
          $in: filter.equipmentIds.map((id) => new Types.ObjectId(id)),
        };

      // BodyPart
      if (filter.bodyPartIds?.length)
        query["bodyParts"] = {
          $in: filter.bodyPartIds.map((id) => new Types.ObjectId(id)),
        };

      // Muscles (main + secondary)
      if (filter.muscleIds?.length) {
        query["$or"] = [
          {
            mainMuscles: {
              $in: filter.muscleIds.map((id) => new Types.ObjectId(id)),
            },
          },
          {
            secondaryMuscles: {
              $in: filter.muscleIds.map((id) => new Types.ObjectId(id)),
            },
          },
        ];
      }

      // Exercise Types
      if (filter.exerciseTypes?.length)
        query["exerciseTypes"] = {
          $in: filter.exerciseTypes.map((id) => new Types.ObjectId(id)),
        };

      // Exercise Categories
      if (filter.exerciseCategories?.length)
        query["exerciseCategories"] = {
          $in: filter.exerciseCategories.map((id) => new Types.ObjectId(id)),
        };

      // Location (Gym, Home, Outdoor...)
      if (filter.location) query["location"] = filter.location;
    }

    if (profile) {
      const levels = getSuitableDifficultyLevels(profile);
      query["difficulty"] = { $in: levels };
    }

    const exercises = await this.model
      .find(query)
      .select("_id name")
      .lean()
      .exec();

    return exercises.map((e) => ({
      exerciseId: e._id.toString(),
      exerciseName: e.name,
    }));
  }
}

import { Model, SortOrder, Types } from "mongoose";
import { IExercise, IExerciseRating } from "../../models";
import { BaseRepository, castArrayToObjectIds } from "../base.repository";
import {
  IRAGExercise,
  IRAGHealthProfile,
  PaginationQueryOptions,
  UserRAGRequest,
} from "../../entities";
import { getSuitableDifficultyLevels } from "../../../utils/ExerciseHelper";
import {
  DEFAULT_LIMIT,
  DEFAULT_PAGE,
} from "../../../common/constants/AppConstants";
import { HttpError } from "../../../utils/HttpError";

export class ExerciseRepository extends BaseRepository<IExercise> {
  private readonly exerciseRating: Model<IExerciseRating>;
  constructor(model: Model<IExercise>, exerciseRating: Model<IExerciseRating>) {
    super(model);
    this.exerciseRating = exerciseRating;
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

  /**
   * Query exercise list with full filtering, sorting, pagination, and population.
   *
   * @param {PaginationQueryOptions} options - Query builder config.
   * @returns {Promise<{ data: any[]; pagination: PaginationInfo }>}
   */
  async getExercises(options?: PaginationQueryOptions) {
    const page = options?.page ?? DEFAULT_PAGE;
    const limit = options?.limit ?? DEFAULT_LIMIT;
    const sort = options?.sort ?? { name: 1 };
    const filter = options?.filter;
    const search = options?.search;

    const query: any = {};

    if (search) {
      query.name = { $regex: search, $options: "i" };
    }

    if (filter) {
      if (filter.equipmentIds) {
        query.equipments = { $in: castArrayToObjectIds(filter.equipmentIds) };
      }

      if (filter.bodyPartIds) {
        query.bodyParts = { $in: castArrayToObjectIds(filter.bodyPartIds) };
      }

      if (filter.muscleIds) {
        const ids = castArrayToObjectIds(filter.muscleIds);
        query.$or = [
          { mainMuscles: { $in: ids } },
          { secondaryMuscles: { $in: ids } },
        ];
      }

      if (filter.exerciseTypes) {
        query.exerciseTypes = {
          $in: castArrayToObjectIds(filter.exerciseTypes),
        };
      }

      if (filter.exerciseCategories) {
        query.exerciseCategories = {
          $in: castArrayToObjectIds(filter.exerciseCategories),
        };
      }

      if (filter.location) {
        query.location = filter.location;
      }
    }

    const sortObj: Record<string, SortOrder> =
      sort && Object.keys(sort).length
        ? (sort as Record<string, SortOrder>)
        : { name: 1 };

    const data = await this.model
      .find(query)
      .select("name imageUrls location difficulty")
      .populate({ path: "equipments", select: "name" })
      .populate({ path: "bodyParts", select: "name" })
      .populate({ path: "mainMuscles", select: "name" })
      .populate({ path: "secondaryMuscles", select: "name" })
      .populate({ path: "exerciseTypes", select: "name" })
      .populate({ path: "exerciseCategories", select: "name" })
      .sort(sortObj)
      .skip((page - 1) * limit)
      .limit(limit)
      .lean()
      .exec();

    const processed = data.map((item: any) => ({
      ...item,
      imageUrl: item.imageUrls?.[0] || null,
      imageUrls: undefined,
    }));

    return processed;
  }

  /**
   * Get full exercise detail by ID, including populated fields and rating summary.
   *
   * Features:
   * - Populate all referenced fields (equipments, bodyParts, muscles, types, categories).
   * - If `videoUrl` is available → media = string (videoUrl).
   * - If `videoUrl` is not available → media = string[] (imageUrls list).
   * - Calculate average rating:
   *      + If no rating exists → default = 5.
   *      + Otherwise → avg = mean(score).
   *
   * @param exerciseId - ID of the exercise to retrieve
   * @returns Full exercise object with populated references + averageScore + media
   */
  async getExerciseById(exerciseId: string) {
    const id = new Types.ObjectId(exerciseId);

    const exercise = await this.model
      .findById(id)
      .populate("equipments", "name")
      .populate("bodyParts", "name")
      .populate("mainMuscles", "name")
      .populate("secondaryMuscles", "name")
      .populate("exerciseTypes", "name")
      .populate("exerciseCategories", "name")
      .lean();

    if (!exercise) {
      throw new HttpError(401, "Exercise not found");
    }

    const ratings = await this.exerciseRating.find({ exerciseId: id }).lean();

    let averageScore = 5;

    if (ratings.length > 0) {
      const total = ratings.reduce((sum, r) => sum + r.score, 0);
      averageScore = Number((total / ratings.length).toFixed(1));
    }

    return {
      ...exercise,
      averageScore,
    };
  }
}

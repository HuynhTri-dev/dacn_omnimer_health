import { FilterQuery, Model, Types } from "mongoose";
import { IWorkoutTemplate } from "../../models";
import { BaseRepository } from "../base.repository";
import { PaginationQueryOptions } from "../../entities";

export class WorkoutTemplateRepository extends BaseRepository<IWorkoutTemplate> {
  constructor(model: Model<IWorkoutTemplate>) {
    super(model);
  }

  /**
   * Lấy chi tiết WorkoutTemplate theo ID, bao gồm populate các reference.
   * @param id - ObjectId hoặc string của template
   */
  async getWorkoutTemplateById(id: string | Types.ObjectId) {
    return this.model
      .findById(id)
      .populate([
        { path: "equipments", select: "_id name" },
        { path: "bodyPartsTarget", select: "_id name" },
        { path: "exerciseTypes", select: "_id name" },
        { path: "exerciseCategories", select: "_id name" },
        { path: "musclesTarget", select: "_id name" },
        {
          path: "workOutDetail.exerciseId",
          select: "_id name difficulty met",
        },
      ])
      .lean()
      .exec();
  }

  /**
   * Tìm tất cả bản ghi, có thể truyền query filter, phân trang, sort.
   * @param filter - điều kiện tìm kiếm (optional)
   * @param options - optional: limit, page, sort
   */
  async findAllWorkoutTemplate(
    filter: FilterQuery<IWorkoutTemplate> = {},
    options?: PaginationQueryOptions
  ): Promise<IWorkoutTemplate[]> {
    try {
      const page = options?.page ?? 1;
      const limit = options?.limit ?? 20;
      const skip = (page - 1) * limit;
      const sort = options?.sort ?? { createdAt: -1 };

      const finalFilter = {
        ...filter,
        ...(options?.filter || {}),
      };

      // Chỉ lấy các trường quan trọng
      const projection =
        "name description equipments bodyPartsTarget exerciseTypes exerciseCategories musclesTarget location createdByAI createdForUserId updatedAt";

      return this.model
        .find(finalFilter, projection)
        .populate([
          { path: "bodyPartsTarget", select: "_id name" },
          { path: "exerciseTypes", select: "_id name" },
          { path: "musclesTarget", select: "_id name" },
        ])
        .skip(skip)
        .limit(limit)
        .sort(sort)
        .exec();
    } catch (e) {
      throw e;
    }
  }
}

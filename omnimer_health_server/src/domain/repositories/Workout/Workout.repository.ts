import { FilterQuery, Model, Types } from "mongoose";
import { IWorkout, IWorkoutDeviceData } from "../../models";
import { BaseRepository } from "../base.repository";
import { PaginationQueryOptions } from "../../entities";
import { IWorkoutDetailInfo } from "../../../utils/Workout/WorkoutUtil";

export class WorkoutRepository extends BaseRepository<IWorkout> {
  constructor(model: Model<IWorkout>) {
    super(model);
  }

  /**
   * Lấy chi tiết WorkoutTemplate theo ID, bao gồm populate các reference.
   * @param id - ObjectId hoặc string của template
   */
  async getWorkoutById(id: string | Types.ObjectId) {
    return this.model
      .findById(id)
      .populate([
        { path: "workoutTemplateId", select: "_id name" },
        { path: "workoutDetail.exerciseId", select: "_id name difficulty met" },
      ])
      .lean()
      .exec();
  }

  /**
   * Tìm tất cả bản ghi, có thể truyền query filter, phân trang, sort.
   * @param filter - điều kiện tìm kiếm (optional)
   * @param options - optional: limit, page, sort
   */
  async findAllWorkout(
    filter: FilterQuery<IWorkout> = {},
    options?: PaginationQueryOptions
  ): Promise<IWorkout[]> {
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
      const projection = "userId workoutTemplateId date summary";

      return this.model
        .find(finalFilter, projection)
        .populate([{ path: "workoutTemplateId", select: "_id name" }])
        .skip(skip)
        .limit(limit)
        .sort(sort)
        .exec();
    } catch (e) {
      throw e;
    }
  }

  async updateSetDone(
    workoutId: string,
    workoutDetailId: string,
    workoutSetId: string,
    done: boolean
  ) {
    return this.model.updateOne(
      {
        _id: new Types.ObjectId(workoutId),
      },
      {
        $set: {
          "workoutDetail.$[detail].sets.$[set].done": done,
        },
      },
      {
        arrayFilters: [
          { "detail._id": new Types.ObjectId(workoutDetailId) },
          { "set._id": new Types.ObjectId(workoutSetId) },
        ],
      }
    );
  }

  async updateExerciseInfo(
    workoutId: string,
    workoutDetailId: string,
    durationMin: number,
    deviceData?: IWorkoutDeviceData
  ) {
    const updateFields: any = {
      "workoutDetail.$[detail].durationMin": durationMin,
    };

    if (deviceData) {
      updateFields["workoutDetail.$[detail].deviceData"] = deviceData;
    }

    return this.model.updateOne(
      { _id: new Types.ObjectId(workoutId) },
      { $set: updateFields },
      {
        arrayFilters: [{ "detail._id": new Types.ObjectId(workoutDetailId) }],
      }
    );
  }

  /**
   * 🔹 Lấy MET và cân nặng người dùng cho 1 bài tập cụ thể trong buổi tập
   * @param workoutId - ID của buổi tập
   * @param workoutDetailId - ID của bài tập trong buổi tập
   * @returns { met, weight }
   */
  async getExerciseMetAndUserWeightAndDetail(
    workoutId: string,
    workoutDetailId: string
  ): Promise<{
    met: number;
    weight: number;
    detail: IWorkoutDetailInfo;
  } | null> {
    const result = await this.model.aggregate([
      { $match: { _id: new Types.ObjectId(workoutId) } },
      { $unwind: "$workoutDetail" },
      { $match: { "workoutDetail._id": new Types.ObjectId(workoutDetailId) } },

      // 🔹 Lấy thông tin bài tập (exercise)
      {
        $lookup: {
          from: "exercises",
          localField: "workoutDetail.exerciseId",
          foreignField: "_id",
          as: "exercise",
        },
      },
      { $unwind: "$exercise" },

      // 🔹 Lấy thông tin health profile (cân nặng)
      {
        $lookup: {
          from: "healthprofiles",
          localField: "healthProfileId",
          foreignField: "_id",
          as: "healthProfile",
        },
      },
      { $unwind: "$healthProfile" },

      // 🔹 Lọc các set done === true
      {
        $addFields: {
          doneSets: {
            $filter: {
              input: "$workoutDetail.sets",
              as: "s",
              cond: { $eq: ["$$s.done", true] },
            },
          },
        },
      },

      // 🔹 Tính toán các tổng đúng theo IWorkoutDetailInfo
      {
        $addFields: {
          "detail.sets": { $size: "$doneSets" },
          "detail.reps": { $sum: "$doneSets.reps" },
          "detail.weight": {
            $sum: {
              $map: {
                input: "$doneSets",
                as: "s",
                in: { $multiply: ["$$s.weight", "$$s.reps"] },
              },
            },
          },
          "detail.duration": { $sum: "$doneSets.duration" },
          "detail.distance": { $sum: "$doneSets.distance" },
        },
      },

      // 🔹 Chỉ giữ lại trường cần thiết
      {
        $project: {
          _id: 0,
          met: { $ifNull: ["$exercise.met", 3] },
          weight: { $ifNull: ["$healthProfile.weight", 60] },
          detail: 1,
        },
      },
      { $limit: 1 },
    ]);

    return result.length > 0 ? result[0] : null;
  }

  /**
   * 🔹 Lấy danh sách thời gian tập luyện để tính tần suất
   */
  async getWorkoutsForFrequency(
    userId: string
  ): Promise<{ timeStart: Date }[]> {
    return this.model
      .find({ userId: new Types.ObjectId(userId) })
      .select("timeStart")
      .lean()
      .exec();
  }

  /**
   * 🔹 Lấy lịch sử calo tiêu thụ
   */
  async getCaloriesBurnedHistory(
    userId: string
  ): Promise<{ timeStart: Date; calories: number }[]> {
    const workouts = await this.model
      .find({ userId: new Types.ObjectId(userId) })
      .sort({ timeStart: 1 })
      .select("timeStart summary.totalCalories")
      .lean()
      .exec();

    return workouts.map((w) => ({
      timeStart: w.timeStart,
      calories: w.summary?.totalCalories || 0,
    }));
  }

  /**
   * 🔹 Thống kê phân bố nhóm cơ tập luyện
   */
  async getMuscleDistributionStats(
    userId: string
  ): Promise<{ muscle: string; count: number }[]> {
    return this.model.aggregate([
      { $match: { userId: new Types.ObjectId(userId) } },
      { $unwind: "$workoutDetail" },
      {
        $lookup: {
          from: "exercises",
          localField: "workoutDetail.exerciseId",
          foreignField: "_id",
          as: "exercise",
        },
      },
      { $unwind: "$exercise" },
      { $unwind: "$exercise.muscles" },
      {
        $lookup: {
          from: "muscles",
          localField: "exercise.muscles",
          foreignField: "_id",
          as: "muscleDetail",
        },
      },
      { $unwind: "$muscleDetail" },
      {
        $group: {
          _id: "$muscleDetail.name",
          count: { $sum: 1 },
        },
      },
      { $project: { muscle: "$_id", count: 1, _id: 0 } },
    ]);
  }
  /**
   * 🔹 Count total workouts
   */
  async countWorkouts(): Promise<number> {
    return this.model.countDocuments();
  }

  /**
   * 🔹 Get workout activity stats
   */
  async getWorkoutActivityStats(
    period: "daily" | "weekly" | "monthly"
  ): Promise<{ date: string; count: number }[]> {
    const dateFormat =
      period === "daily" ? "%Y-%m-%d" : period === "weekly" ? "%Y-%U" : "%Y-%m";

    return this.model.aggregate([
      {
        $group: {
          _id: { $dateToString: { format: dateFormat, date: "$timeStart" } },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
      { $project: { date: "$_id", count: 1, _id: 0 } },
    ]);
  }

  /**
   * 🔹 Get popular exercises stats
   */
  async getPopularExercisesStats(
    limit: number = 5
  ): Promise<{ exerciseName: string; count: number }[]> {
    return this.model.aggregate([
      { $unwind: "$workoutDetail" },
      {
        $group: {
          _id: "$workoutDetail.exerciseId",
          count: { $sum: 1 },
        },
      },
      { $sort: { count: -1 } },
      { $limit: limit },
      {
        $lookup: {
          from: "exercises",
          localField: "_id",
          foreignField: "_id",
          as: "exercise",
        },
      },
      { $unwind: "$exercise" },
      {
        $project: {
          exerciseName: "$exercise.name",
          count: 1,
          _id: 0,
        },
      },
    ]);
  }
}

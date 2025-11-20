import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { IExerciseCategory } from "../../models";
import { HttpError } from "../../../utils/HttpError";
import { ExerciseCategoryRepository } from "../../repositories";
import { PaginationQueryOptions } from "../../entities";

export class ExerciseCategoryService {
  private readonly exerciseRepo: ExerciseCategoryRepository;

  constructor(exerciseRepo: ExerciseCategoryRepository) {
    this.exerciseRepo = exerciseRepo;
  }

  // =================== CREATE ===================
  async createExerciseCategory(
    userId: string,
    data: Partial<IExerciseCategory>
  ) {
    try {
      const exerciseCategory = await this.exerciseRepo.create(data);

      await logAudit({
        userId,
        action: "createExerciseCategory",
        message: `Tạo ExerciseCategory "${data.name}" thành công`,
        status: StatusLogEnum.Success,
        targetId: exerciseCategory._id.toString(),
      });

      return exerciseCategory;
    } catch (err: any) {
      await logError({
        userId,
        action: "createExerciseCategory",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== GET ALL ===================
  async getExerciseCategorys(option?: PaginationQueryOptions) {
    try {
      return await this.exerciseRepo.findAll({}, option);
    } catch (err: any) {
      await logError({
        action: "getExerciseCategorys",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== GET BY ID ===================
  async getExerciseCategoryById(exerciseCategoryId: string) {
    try {
      const exerciseCategory = await this.exerciseRepo.findById(
        exerciseCategoryId
      );
      if (!exerciseCategory) {
        throw new HttpError(404, "ExerciseCategory không tồn tại");
      }
      return exerciseCategory;
    } catch (err: any) {
      await logError({
        action: "getExerciseCategoryById",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== UPDATE ===================
  async updateExerciseCategory(
    exerciseCategoryId: string,
    data: Partial<IExerciseCategory>,
    userId?: string
  ) {
    try {
      const updated = await this.exerciseRepo.update(exerciseCategoryId, data);

      await logAudit({
        userId,
        action: "updateExerciseCategory",
        message: `Cập nhật ExerciseCategory "${exerciseCategoryId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: exerciseCategoryId,
      });

      return updated;
    } catch (err: any) {
      await logError({
        userId,
        action: "updateExerciseCategory",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== DELETE ===================
  async deleteExerciseCategory(exerciseCategoryId: string, userId?: string) {
    try {
      const deleted = await this.exerciseRepo.delete(exerciseCategoryId);

      if (!deleted) {
        await logAudit({
          userId,
          action: "deleteExerciseCategory",
          message: `ExerciseCategory "${exerciseCategoryId}" không tồn tại`,
          status: StatusLogEnum.Failure,
        });
        throw new HttpError(404, "ExerciseCategory không tồn tại");
      }

      await logAudit({
        userId,
        action: "deleteExerciseCategory",
        message: `Xóa ExerciseCategory "${exerciseCategoryId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: exerciseCategoryId,
      });

      return deleted;
    } catch (err: any) {
      await logError({
        userId,
        action: "deleteExerciseCategory",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }
}

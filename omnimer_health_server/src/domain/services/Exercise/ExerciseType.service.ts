import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { IExerciseType } from "../../models";
import { HttpError } from "../../../utils/HttpError";
import { ExerciseTypeRepository } from "../../repositories";
import { PaginationQueryOptions } from "../../entities";

export class ExerciseTypeService {
  private readonly exerciseRepo: ExerciseTypeRepository;

  constructor(exerciseRepo: ExerciseTypeRepository) {
    this.exerciseRepo = exerciseRepo;
  }

  // =================== CREATE ===================
  async createExerciseType(userId: string, data: Partial<IExerciseType>) {
    try {
      const exerciseType = await this.exerciseRepo.create(data);

      await logAudit({
        userId,
        action: "createExerciseType",
        message: `Tạo ExerciseType "${data.name}" thành công`,
        status: StatusLogEnum.Success,
        targetId: exerciseType._id.toString(),
      });

      return exerciseType;
    } catch (err: any) {
      await logError({
        userId,
        action: "createExerciseType",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== GET ALL ===================
  async getExerciseTypes(option?: PaginationQueryOptions) {
    try {
      return await this.exerciseRepo.findAll({}, option);
    } catch (err: any) {
      await logError({
        action: "getExerciseTypes",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== GET BY ID ===================
  async getExerciseTypeById(exerciseTypeId: string) {
    try {
      const exerciseType = await this.exerciseRepo.findById(exerciseTypeId);
      if (!exerciseType) {
        throw new HttpError(404, "ExerciseType không tồn tại");
      }
      return exerciseType;
    } catch (err: any) {
      await logError({
        action: "getExerciseTypeById",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== UPDATE ===================
  async updateExerciseType(
    exerciseTypeId: string,
    data: Partial<IExerciseType>,
    userId?: string
  ) {
    try {
      const updated = await this.exerciseRepo.update(exerciseTypeId, data);

      await logAudit({
        userId,
        action: "updateExerciseType",
        message: `Cập nhật ExerciseType "${exerciseTypeId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: exerciseTypeId,
      });

      return updated;
    } catch (err: any) {
      await logError({
        userId,
        action: "updateExerciseType",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== DELETE ===================
  async deleteExerciseType(exerciseTypeId: string, userId?: string) {
    try {
      const deleted = await this.exerciseRepo.delete(exerciseTypeId);

      if (!deleted) {
        await logAudit({
          userId,
          action: "deleteExerciseType",
          message: `ExerciseType "${exerciseTypeId}" không tồn tại`,
          status: StatusLogEnum.Failure,
        });
        throw new HttpError(404, "ExerciseType không tồn tại");
      }

      await logAudit({
        userId,
        action: "deleteExerciseType",
        message: `Xóa ExerciseType "${exerciseTypeId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: exerciseTypeId,
      });

      return deleted;
    } catch (err: any) {
      await logError({
        userId,
        action: "deleteExerciseType",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }
}

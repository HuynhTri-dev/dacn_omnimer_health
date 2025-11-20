import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { IExerciseRating } from "../../models";
import { HttpError } from "../../../utils/HttpError";
import { ExerciseRatingRepository } from "../../repositories";
import { PaginationQueryOptions } from "../../entities";
import { Types } from "mongoose";

export class ExerciseRatingService {
  private readonly exerciseRepo: ExerciseRatingRepository;

  constructor(exerciseRepo: ExerciseRatingRepository) {
    this.exerciseRepo = exerciseRepo;
  }

  // =================== CREATE ===================
  async createExerciseRating(userId: string, data: Partial<IExerciseRating>) {
    try {
      // Thêm userId vào data để bảo đảm chủ sở hữu
      const newData = { ...data, userId: new Types.ObjectId(userId) };

      // Kiểm tra nếu đã tồn tại rating của user cho exercise này
      const existing = await this.exerciseRepo.findOne({
        exerciseId: newData.exerciseId,
        userId,
      });
      if (existing) {
        throw new HttpError(409, "Người dùng đã đánh giá bài tập này");
      }

      const exerciseRating = await this.exerciseRepo.create(newData);

      await logAudit({
        userId,
        action: "createExerciseRating",
        message: `Tạo ExerciseRating thành công`,
        status: StatusLogEnum.Success,
        targetId: exerciseRating._id.toString(),
      });

      return exerciseRating;
    } catch (err: any) {
      await logError({
        userId,
        action: "createExerciseRating",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== GET ALL ===================
  async getExerciseRatings(option?: PaginationQueryOptions) {
    try {
      return await this.exerciseRepo.findAll({}, option);
    } catch (err: any) {
      await logError({
        action: "getExerciseRatings",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== GET BY ID ===================
  async getExerciseRatingById(exerciseRatingId: string) {
    try {
      const exerciseRating = await this.exerciseRepo.findById(exerciseRatingId);
      if (!exerciseRating) {
        throw new HttpError(404, "ExerciseRating không tồn tại");
      }
      return exerciseRating;
    } catch (err: any) {
      await logError({
        action: "getExerciseRatingById",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== UPDATE ===================
  async updateExerciseRating(
    exerciseRatingId: string,
    data: Partial<IExerciseRating>,
    userId: string
  ) {
    try {
      const existing = await this.exerciseRepo.findById(exerciseRatingId);
      if (!existing) throw new HttpError(404, "Đánh giá bài tập không tồn tại");

      // Kiểm tra quyền sở hữu
      if (existing.userId.toString() !== userId)
        throw new HttpError(403, "Bạn không có quyền cập nhật đánh giá này");

      const updated = await this.exerciseRepo.update(exerciseRatingId, data);

      await logAudit({
        userId,
        action: "updateExerciseRating",
        message: `Cập nhật ExerciseRating "${exerciseRatingId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: exerciseRatingId,
      });

      return updated;
    } catch (err: any) {
      await logError({
        userId,
        action: "updateExerciseRating",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== DELETE ===================
  async deleteExerciseRating(exerciseRatingId: string, userId?: string) {
    try {
      const deleted = await this.exerciseRepo.delete(exerciseRatingId);

      if (!deleted) {
        await logAudit({
          userId,
          action: "deleteExerciseRating",
          message: `ExerciseRating "${exerciseRatingId}" không tồn tại`,
          status: StatusLogEnum.Failure,
        });
        throw new HttpError(404, "ExerciseRating không tồn tại");
      }

      await logAudit({
        userId,
        action: "deleteExerciseRating",
        message: `Xóa ExerciseRating "${exerciseRatingId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: exerciseRatingId,
      });

      return deleted;
    } catch (err: any) {
      await logError({
        userId,
        action: "deleteExerciseRating",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }
}

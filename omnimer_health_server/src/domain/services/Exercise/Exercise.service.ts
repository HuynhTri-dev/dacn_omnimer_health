import mongoose from "mongoose";
import { ExerciseRepository } from "../../repositories";
import { IExercise } from "../../models";
import {
  uploadToCloudflare,
  updateCloudflareImage,
  deleteFileFromCloudflare,
} from "../../../utils/CloudflareUpload";
import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { HttpError } from "../../../utils/HttpError";
import {
  IRAGHealthProfile,
  PaginationQueryOptions,
  UserRAGRequest,
} from "../../entities";

export class ExerciseService {
  private readonly exerciseRepository: ExerciseRepository;

  constructor(exerciseRepository: ExerciseRepository) {
    this.exerciseRepository = exerciseRepository;
  }

  // =================== CREATE ===================
  async createExercise(
    userId: string,
    imageFiles: Express.Multer.File[] | undefined,
    videoFile: Express.Multer.File | undefined,
    data: Partial<IExercise>
  ) {
    let imageUrls: string[] = [];
    let videoUrl: string | undefined;
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      if (imageFiles && imageFiles.length > 0) {
        for (const file of imageFiles) {
          const url = await uploadToCloudflare(
            file,
            "exercises/images",
            userId
          );
          imageUrls.push(url);
        }
      }
      if (videoFile) {
        videoUrl = await uploadToCloudflare(
          videoFile,
          "exercises/videos",
          userId
        );
      }

      const exercise = await this.exerciseRepository.createWithSession(
        { ...data, imageUrls, videoUrl },
        session
      );

      await session.commitTransaction();
      await logAudit({
        userId,
        action: "createExercise",
        message: `Tạo exercise "${data.name}" thành công`,
        status: StatusLogEnum.Success,
        targetId: exercise._id.toString(),
      });
      return exercise;
    } catch (err: any) {
      await session.abortTransaction();
      if (imageUrls.length > 0) {
        for (const url of imageUrls) {
          await deleteFileFromCloudflare(url, "exercises/images");
        }
      }
      if (videoUrl) {
        await deleteFileFromCloudflare(videoUrl, "exercises/videos");
      }
      await logError({
        userId,
        action: "createExercise",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    } finally {
      session.endSession();
    }
  }

  // =================== UPDATE ===================
  async updateExercise(
    userId: string,
    id: string,
    imageFiles: Express.Multer.File[] | undefined,
    videoFile: Express.Multer.File | undefined,
    data: Partial<IExercise>
  ) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const exercise = await this.exerciseRepository.findById(id);
      if (!exercise) throw new HttpError(404, "Exercise không tồn tại");

      // copy lại mảng ảnh hiện có
      let imageUrls: string[] = exercise.imageUrls || [];

      // nếu có upload thêm ảnh mới
      if (imageFiles && imageFiles.length > 0) {
        for (const file of imageFiles) {
          const url = await uploadToCloudflare(
            file,
            "exercises/images",
            userId
          );
          imageUrls.push(url);
        }
      }

      // xử lý video
      let videoUrl = exercise.videoUrl;
      if (videoFile) {
        if (videoUrl) {
          videoUrl = await updateCloudflareImage(
            videoFile,
            videoUrl,
            "exercises/videos",
            userId
          );
        } else {
          videoUrl = await uploadToCloudflare(
            videoFile,
            "exercises/videos",
            userId
          );
        }
      }

      const updated = await this.exerciseRepository.updateWithSession(
        id,
        {
          ...data,
          imageUrls,
          videoUrl,
        },
        session
      );

      await session.commitTransaction();

      await logAudit({
        userId,
        action: "updateExercise",
        message: `Cập nhật exercise "${updated?.name}" thành công`,
        status: StatusLogEnum.Success,
        targetId: id,
      });

      return updated;
    } catch (err: any) {
      await session.abortTransaction();
      await logError({
        userId,
        action: "updateExercise",
        targetId: id,
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    } finally {
      session.endSession();
    }
  }

  // =================== GET ALL ===================
  async getAllExercises(options?: PaginationQueryOptions) {
    try {
      const list = await this.exerciseRepository.getExercises(options);

      return list;
    } catch (err: any) {
      await logError({
        action: "getAllExercises",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== GET ALL ===================
  async getExerciseById(id: string) {
    try {
      const exercise = await this.exerciseRepository.getExerciseById(id);

      return exercise;
    } catch (err: any) {
      await logError({
        action: "getExerciseById",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== DELETE ===================
  async deleteExercise(userId: string, id: string) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const exercise = await this.exerciseRepository.findById(id);
      if (!exercise) throw new HttpError(404, "Exercise không tồn tại");

      // xóa tất cả ảnh
      if (exercise.imageUrls && exercise.imageUrls.length > 0) {
        for (const url of exercise.imageUrls) {
          await deleteFileFromCloudflare(url, "exercises/images");
        }
      }

      // xóa video
      if (exercise.videoUrl) {
        await deleteFileFromCloudflare(exercise.videoUrl, "exercises/videos");
      }

      const deleted = await this.exerciseRepository.deleteWithSession(
        id,
        session
      );
      if (!deleted) throw new HttpError(500, "Xoá thất bại");

      await session.commitTransaction();

      await logAudit({
        userId,
        action: "deleteExercise",
        message: `Xoá exercise "${exercise.name}" thành công`,
        status: StatusLogEnum.Success,
      });

      return true;
    } catch (err: any) {
      await session.abortTransaction();
      await logError({
        userId,
        action: "deleteExercise",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    } finally {
      session.endSession();
    }
  }

  async getAllExercisesForRAG(
    userId: string,
    filter?: UserRAGRequest,
    profile?: IRAGHealthProfile
  ) {
    try {
      const list = await this.exerciseRepository.filterExerciseForRAG(
        filter,
        profile
      );
      await logAudit({
        userId,
        action: "getAllExercisesForRAG",
        message: "Lấy danh sách exercises",
        status: StatusLogEnum.Success,
      });
      return list;
    } catch (err: any) {
      await logError({
        userId,
        action: "getAllExercisesForRAG",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }
}

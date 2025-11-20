import mongoose from "mongoose";
import { MuscleRepository } from "../../repositories";
import { IMuscle } from "../../models";
import {
  uploadToCloudflare,
  updateCloudflareImage,
  deleteFileFromCloudflare,
} from "../../../utils/CloudflareUpload";
import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { HttpError } from "../../../utils/HttpError";
import { PaginationQueryOptions } from "../../entities";

export class MuscleService {
  private readonly muscleRepository: MuscleRepository;

  constructor(muscleRepository: MuscleRepository) {
    this.muscleRepository = muscleRepository;
  }

  // =================== CREATE ===================
  async createMuscle(
    userId: string,
    file: Express.Multer.File | undefined,
    data: Partial<IMuscle>
  ) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      let imageUrl: string | undefined;
      if (file) {
        imageUrl = await uploadToCloudflare(file, "muscles", userId);
      }

      const muscle = await this.muscleRepository.createWithSession(
        {
          name: data.name,
          bodyPartIds: data.bodyPartIds || [],
          description: data.description,
          imageUrl: imageUrl,
        },
        session
      );

      await session.commitTransaction();

      await logAudit({
        userId,
        action: "createMuscle",
        message: `Tạo muscle "${data.name}" thành công`,
        status: StatusLogEnum.Success,
        targetId: muscle._id.toString(),
      });

      return muscle;
    } catch (err: any) {
      await session.abortTransaction();
      await logError({
        userId,
        action: "createMuscle",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    } finally {
      session.endSession();
    }
  }

  // =================== UPDATE ===================
  async updateMuscle(
    userId: string,
    id: string,
    file: Express.Multer.File | undefined,
    data: Partial<IMuscle>
  ) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const muscle = await this.muscleRepository.findById(id);
      if (!muscle) throw new HttpError(404, "Muscle không tồn tại");

      let imageUrl = muscle.imageUrl;
      if (file) {
        if (imageUrl) {
          imageUrl = await updateCloudflareImage(
            file,
            imageUrl,
            "muscles",
            userId
          );
        } else {
          imageUrl = await uploadToCloudflare(file, "muscles", userId);
        }
      }

      const updated = await this.muscleRepository.updateWithSession(
        id,
        {
          name: data.name || muscle.name,
          bodyPartIds: data.bodyPartIds || muscle.bodyPartIds,
          description: data.description ?? muscle.description,
          imageUrl,
        },
        session
      );

      await session.commitTransaction();

      await logAudit({
        userId,
        action: "updateMuscle",
        message: `Cập nhật muscle "${updated?.name}" thành công`,
        status: StatusLogEnum.Success,
        targetId: id,
      });

      return updated;
    } catch (err: any) {
      await session.abortTransaction();
      await logError({
        userId,
        action: "updateMuscle",
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
  async getAllMuscles(options?: PaginationQueryOptions) {
    try {
      const list = await this.muscleRepository.findAll({}, options);
      await logAudit({
        action: "getAllMuscles",
        message: "Lấy danh sách muscles",
        status: StatusLogEnum.Success,
      });
      return list;
    } catch (err: any) {
      await logError({
        action: "getAllMuscles",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== GET BY ID ===================
  async getMuscleById(id: string) {
    try {
      const muscle = await this.muscleRepository.getMuscleById(id);
      if (!muscle) {
        throw new HttpError(401, "Cannot find the muscle");
      }
      return muscle;
    } catch (err: any) {
      await logError({
        action: "getMuscleById",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== DELETE ===================
  async deleteMuscle(userId: string, id: string) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const muscle = await this.muscleRepository.findById(id);
      if (!muscle) throw new HttpError(404, "Muscle không tồn tại");

      if (muscle.imageUrl) {
        await deleteFileFromCloudflare(muscle.imageUrl, "muscles");
      }

      const deleted = await this.muscleRepository.deleteWithSession(
        id,
        session
      );
      if (!deleted) throw new HttpError(500, "Xoá thất bại");

      await session.commitTransaction();

      await logAudit({
        userId,
        action: "deleteMuscle",
        message: `Xoá muscle "${muscle.name}" thành công`,
        status: StatusLogEnum.Success,
      });

      return true;
    } catch (err: any) {
      await session.abortTransaction();
      await logError({
        userId,
        action: "deleteMuscle",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    } finally {
      session.endSession();
    }
  }
}

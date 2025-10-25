import mongoose from "mongoose";
import { BodyPartRepository } from "../../repositories";
import { IBodyPart } from "../../models";
import {
  uploadToCloudflare,
  updateCloudflareImage,
  deleteFileFromCloudflare,
} from "../../../utils/CloudflareUpload";
import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { HttpError } from "../../../utils/HttpError";
import { PaginationQueryOptions } from "../../entities";

export class BodyPartService {
  private readonly bodyPartRepository: BodyPartRepository;

  constructor(bodyPartRepository: BodyPartRepository) {
    this.bodyPartRepository = bodyPartRepository;
  }

  // =================== CREATE ===================
  async createBodyPart(
    userId: string,
    file: Express.Multer.File | undefined,
    data: Partial<IBodyPart>
  ) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      let imageUrl: string | undefined;
      if (file) {
        imageUrl = await uploadToCloudflare(file, "bodyparts", userId);
      }

      const bodyPart = await this.bodyPartRepository.createWithSession(
        {
          name: data.name,
          description: data.description || null,
          imageUrl: imageUrl || null,
        },
        session
      );

      await session.commitTransaction();

      await logAudit({
        userId,
        action: "createBodyPart",
        message: `Tạo body part "${data.name}" thành công`,
        status: StatusLogEnum.Success,
        targetId: bodyPart._id.toString(),
      });

      return bodyPart;
    } catch (err: any) {
      await session.abortTransaction();
      await logError({
        userId,
        action: "createBodyPart",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    } finally {
      session.endSession();
    }
  }

  // =================== UPDATE ===================
  async updateBodyPart(
    userId: string,
    id: string,
    file: Express.Multer.File | undefined,
    data: Partial<IBodyPart>
  ) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const bodyPart = await this.bodyPartRepository.findById(id);
      if (!bodyPart) throw new HttpError(404, "Body part không tồn tại");

      let imageUrl = bodyPart.imageUrl;
      if (file) {
        if (imageUrl) {
          imageUrl = await updateCloudflareImage(
            file,
            imageUrl,
            "bodyparts",
            userId
          );
        } else {
          imageUrl = await uploadToCloudflare(file, "bodyparts", userId);
        }
      }

      const updated = await this.bodyPartRepository.update(id, {
        name: data.name || bodyPart.name,
        description: data.description ?? bodyPart.description,
        imageUrl,
      });

      await session.commitTransaction();

      await logAudit({
        userId,
        action: "updateBodyPart",
        message: `Cập nhật body part "${updated?.name}" thành công`,
        status: StatusLogEnum.Success,
        targetId: id,
      });

      return updated;
    } catch (err: any) {
      await session.abortTransaction();
      await logError({
        userId,
        action: "updateBodyPart",
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
  async getAllBodyParts(options?: PaginationQueryOptions) {
    try {
      const list = await this.bodyPartRepository.findAll({}, options);
      await logAudit({
        action: "getAllBodyParts",
        message: "Lấy danh sách body parts",
        status: StatusLogEnum.Success,
      });
      return list;
    } catch (err: any) {
      await logError({
        action: "getAllBodyParts",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== DELETE ===================
  async deleteBodyPart(userId: string, id: string) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const bodyPart = await this.bodyPartRepository.findById(id);
      if (!bodyPart) throw new HttpError(404, "Body part không tồn tại");

      if (bodyPart.imageUrl) {
        // Trích xuất key từ URL nếu bạn lưu URL đầy đủ
        await deleteFileFromCloudflare(bodyPart.imageUrl, "bodyparts");
      }

      const deleted = await this.bodyPartRepository.deleteWithSession(
        id,
        session
      );
      if (!deleted) throw new HttpError(500, "Xoá thất bại");

      await session.commitTransaction();

      await logAudit({
        userId,
        action: "deleteBodyPart",
        message: `Xoá body part "${bodyPart.name}" thành công`,
        status: StatusLogEnum.Success,
      });

      return true;
    } catch (err: any) {
      await session.abortTransaction();
      await logError({
        userId,
        action: "deleteBodyPart",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    } finally {
      session.endSession();
    }
  }
}

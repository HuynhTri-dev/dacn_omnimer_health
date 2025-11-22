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

  /**
   * Tạo mới một body part.
   * - Upload hình ảnh (nếu có) lên Cloudflare.
   * - Lưu thông tin body part vào cơ sở dữ liệu trong transaction.
   * - Ghi log audit khi tạo thành công.
   *
   * @param {string} userId - ID của người thực hiện hành động.
   * @param {Express.Multer.File} [file] - File hình ảnh body part (tuỳ chọn).
   * @param {Partial<IBodyPart>} data - Dữ liệu body part cần tạo (name, description, ...).
   * @returns {Promise<IBodyPart>} Thông tin body part đã được tạo.
   * @throws {HttpError} Nếu xảy ra lỗi trong quá trình tạo hoặc ghi dữ liệu.
   */
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

  /**
   * Cập nhật thông tin body part.
   * - Kiểm tra body part tồn tại.
   * - Nếu có file hình mới, cập nhật hoặc upload lên Cloudflare.
   * - Cập nhật thông tin trong transaction.
   * - Ghi log audit khi cập nhật thành công.
   *
   * @param {string} userId - ID của người thực hiện hành động.
   * @param {string} id - ID của body part cần cập nhật.
   * @param {Express.Multer.File} [file] - File hình ảnh mới (tuỳ chọn).
   * @param {Partial<IBodyPart>} data - Dữ liệu cần cập nhật (name, description, ...).
   * @returns {Promise<IBodyPart | null>} Thông tin body part sau khi cập nhật.
   * @throws {HttpError} Nếu body part không tồn tại hoặc có lỗi trong quá trình cập nhật.
   */
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

      const updated = await this.bodyPartRepository.updateWithSession(
        id,
        {
          name: data.name || bodyPart.name,
          description: data.description ?? bodyPart.description,
          imageUrl,
        },
        session
      );

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

  /**
   * Lấy danh sách tất cả body parts (hỗ trợ phân trang, tìm kiếm).
   * - Ghi log audit khi truy vấn thành công.
   *
   * @param {PaginationQueryOptions} [options] - Tuỳ chọn truy vấn (phân trang, sắp xếp, lọc, ...).
   * @returns {Promise<IBodyPart[]>} Danh sách body parts.
   * @throws {HttpError} Nếu xảy ra lỗi khi truy vấn dữ liệu.
   */
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

  /**
   * Xoá một body part khỏi hệ thống.
   * - Kiểm tra body part tồn tại.
   * - Xoá hình ảnh khỏi Cloudflare (nếu có).
   * - Xoá record trong cơ sở dữ liệu bằng transaction.
   * - Ghi log audit khi xoá thành công.
   *
   * @param {string} userId - ID của người thực hiện hành động xoá.
   * @param {string} id - ID của body part cần xoá.
   * @returns {Promise<boolean>} Trả về `true` nếu xoá thành công.
   * @throws {HttpError} Nếu body part không tồn tại hoặc có lỗi trong quá trình xoá.
   */
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

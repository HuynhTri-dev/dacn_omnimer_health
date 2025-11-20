import mongoose from "mongoose";
import { EquipmentRepository } from "../../repositories";
import { IEquipment } from "../../models";
import {
  uploadToCloudflare,
  updateCloudflareImage,
  deleteFileFromCloudflare,
  extractFileKey,
} from "../../../utils/CloudflareUpload";
import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { HttpError } from "../../../utils/HttpError";
import { PaginationQueryOptions } from "../../entities";

export class EquipmentService {
  private readonly equipmentRepository: EquipmentRepository;

  constructor(equipmentRepository: EquipmentRepository) {
    this.equipmentRepository = equipmentRepository;
  }

  // =================== CREATE ===================
  async createEquipment(
    userId: string,
    file: Express.Multer.File | undefined,
    data: Partial<IEquipment>
  ) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      let imageUrl: string | undefined;
      if (file) {
        imageUrl = await uploadToCloudflare(file, "equipments", userId);
      }

      const equipment = await this.equipmentRepository.createWithSession(
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
        action: "createEquipment",
        message: `Tạo equipment "${data.name}" thành công`,
        status: StatusLogEnum.Success,
        targetId: equipment._id.toString(),
      });

      return equipment;
    } catch (err: any) {
      await session.abortTransaction();
      await logError({
        userId,
        action: "createEquipment",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    } finally {
      session.endSession();
    }
  }

  // =================== UPDATE ===================
  async updateEquipment(
    userId: string,
    id: string,
    file: Express.Multer.File | undefined,
    data: Partial<IEquipment>
  ) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const equipment = await this.equipmentRepository.findById(id);
      if (!equipment) throw new HttpError(404, "Body part không tồn tại");

      let imageUrl = equipment.imageUrl;
      if (file) {
        if (imageUrl) {
          imageUrl = await updateCloudflareImage(
            file,
            imageUrl,
            "equipments",
            userId
          );
        } else {
          imageUrl = await uploadToCloudflare(file, "equipments", userId);
        }
      }

      const updated = await this.equipmentRepository.updateWithSession(
        id,
        {
          name: data.name || equipment.name,
          description: data.description ?? equipment.description,
          imageUrl,
        },
        session
      );

      await session.commitTransaction();

      await logAudit({
        userId,
        action: "updateEquipment",
        message: `Cập nhật equipment "${updated?.name}" thành công`,
        status: StatusLogEnum.Success,
        targetId: id,
      });

      return updated;
    } catch (err: any) {
      await session.abortTransaction();
      await logError({
        userId,
        action: "updateEquipment",
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
  async getAllEquipments(options?: PaginationQueryOptions) {
    try {
      const list = await this.equipmentRepository.findAll({}, options);
      await logAudit({
        action: "getAllEquipments",
        message: "Lấy danh sách equipments",
        status: StatusLogEnum.Success,
      });
      return list;
    } catch (err: any) {
      await logError({
        action: "getAllEquipments",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =================== DELETE ===================
  async deleteEquipment(userId: string, id: string) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const equipment = await this.equipmentRepository.findById(id);
      if (!equipment) throw new HttpError(404, "Body part không tồn tại");

      if (equipment.imageUrl) {
        await deleteFileFromCloudflare(equipment.imageUrl, "equipments");
      }

      const deleted = await this.equipmentRepository.deleteWithSession(
        id,
        session
      );
      if (!deleted) throw new HttpError(500, "Xoá thất bại");

      await session.commitTransaction();

      await logAudit({
        userId,
        action: "deleteEquipment",
        message: `Xoá equipment "${equipment.name}" thành công`,
        status: StatusLogEnum.Success,
      });

      return true;
    } catch (err: any) {
      await session.abortTransaction();
      await logError({
        userId,
        action: "deleteEquipment",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    } finally {
      session.endSession();
    }
  }
}

import mongoose from "mongoose";
import { LODMapper } from "../LOD/LODMapper";
import { GraphDBService } from "../LOD/GraphDB.service";
import { UserRepository } from "../../repositories";
import { IUser } from "../../models";
import {
  uploadUserAvatar,
  updateUserAvatar,
} from "../../../utils/CloudflareUpload";
import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { HttpError } from "../../../utils/HttpError";
import { PaginationQueryOptions } from "../../entities";

export class UserService {
  private readonly userRepository: UserRepository;

  constructor(userRepository: UserRepository) {
    this.userRepository = userRepository;
  }

  // ======================================================
  // =============== UPDATE USER PROFILE ==================
  // ======================================================
  /**
   * Update user profile information and optionally update their avatar.
   * - Uses MongoDB transactions to ensure consistency.
   * - Uploads or updates the user's avatar image on Cloudflare if provided.
   * - Records audit and error logs for all operations.
   *
   * @param userId - ID of the user performing the update action (for auditing)
   * @param id - ID of the user whose profile is being updated
   * @param avatarImage - Optional image file uploaded via Multer
   * @param data - Partial user data to be updated
   * @returns The updated user document
   * @throws HttpError(404) if the target user does not exist
   * @throws Error if any database or Cloudflare operation fails
   */
  async updateUser(
    userId: string,
    id: string,
    avatarImage: Express.Multer.File | undefined,
    data: Partial<IUser>
  ) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const user = await this.userRepository.findById(id);
      if (!user) throw new HttpError(404, "User không tồn tại");

      // Handle avatar upload/update
      let imageUrl = user.imageUrl;
      if (avatarImage) {
        if (imageUrl) {
          imageUrl = await updateUserAvatar(avatarImage, imageUrl, userId);
        } else {
          imageUrl = await uploadUserAvatar(avatarImage, user.id);
        }
      }

      // Update user profile data within transaction
      const updated = await this.userRepository.updateWithSession(
        id,
        {
          ...data,
          imageUrl,
        },
        session
      );

      await session.commitTransaction();

      await logAudit({
        userId,
        action: "updateUser",
        message: `Cập nhật user "${updated?.fullname}" thành công`,
        status: StatusLogEnum.Success,
        targetId: id,
      });

      return updated;
    } catch (err: any) {
      await session.abortTransaction();
      await logError({
        userId,
        action: "updateUser",
        targetId: id,
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    } finally {
      session.endSession();
    }
  }

  // ======================================================
  // =============== GET ALL USERS ========================
  // ======================================================
  /**
   * Retrieve all users with pagination and sorting options.
   * - Supports flexible query parameters via `PaginationQueryOptions`.
   * - Records successful retrievals and logs any encountered errors.
   *
   * @param options - Optional pagination and filtering options
   * @returns A list of user documents
   * @throws Error if the database query fails
   */
  async getAllUsers(options?: PaginationQueryOptions) {
    try {
      const list = await this.userRepository.findAllUser(options);

      await logAudit({
        action: "getAllUsers",
        message: "Lấy danh sách người dùng thành công",
        status: StatusLogEnum.Success,
      });

      return list;
    } catch (err: any) {
      await logError({
        action: "getAllUsers",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // ======================================================
  // =============== TOGGLE DATA SHARING ==================
  // ======================================================
  /**
   * Toggle the user's data sharing preference.
   * - Updates the isDataSharingAccepted flag in the database.
   * - If enabled, maps user data to RDF and pushes to GraphDB.
   * - If disabled, deletes user data from GraphDB.
   *
   * @param userId - ID of the user
   * @returns The updated user document
   * @throws HttpError(404) if the user does not exist
   */
  async toggleDataSharing(userId: string) {
    const user = await this.userRepository.findById(userId);
    if (!user) throw new HttpError(404, "User không tồn tại");

    const newValue = !user.isDataSharingAccepted;

    // Update in DB
    const updatedUser = await this.userRepository.update(userId, {
      isDataSharingAccepted: newValue,
    });

    const graphDBService = new GraphDBService();

    if (newValue) {
      // If turning ON, map to RDF and insert
      if (updatedUser) {
        const rdfData = LODMapper.mapUserToRDF(updatedUser);
        if (rdfData) {
          await graphDBService.insertData(rdfData);
        }
      }
    } else {
      // If turning OFF, delete from GraphDB
      await graphDBService.deleteUserData(userId);
    }

    return updatedUser;
  }
}

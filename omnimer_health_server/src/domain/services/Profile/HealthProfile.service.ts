import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { IHealthProfile } from "../../models";
import { HttpError } from "../../../utils/HttpError";
import { HealthProfileRepository, UserRepository } from "../../repositories";
import { IRAGHealthProfile, PaginationQueryOptions } from "../../entities";
import { calculateHealthMetrics } from "../../../utils/HealthFunction/HealthCalculationUtil";
import { callOllamaEvaluation } from "../../../utils/HealthFunction/AiEvaluationUtil";
import { Types } from "mongoose";

/**
 * Service class for handling HealthProfile-related operations.
 * Provides CRUD functionality, metric calculations, and AI-assisted evaluations.
 */
export class HealthProfileService {
  private readonly healthProfileRepo: HealthProfileRepository;
  private readonly userRepo: UserRepository;

  constructor(
    healthProfileRepo: HealthProfileRepository,
    userRepo: UserRepository
  ) {
    this.healthProfileRepo = healthProfileRepo;
    this.userRepo = userRepo;
  }

  // =========================================================
  // CREATE
  // =========================================================

  /**
   * Create a new health profile for a user.
   *
   * @param userId - The ID of the user performing the operation.
   * @param data - Partial health profile data provided by the client.
   * @returns The newly created HealthProfile document.
   *
   * @throws HttpError - If user or health profile creation fails.
   */
  async createHealthProfile(userId: string, data: Partial<IHealthProfile>) {
    try {
      // Retrieve user information
      const user = await this.userRepo.findById(
        data.userId?.toString() ?? userId
      );

      console.log("User: ", user);

      // Compute key health metrics (e.g., BMI, body fat, etc.)
      const metrics = calculateHealthMetrics({
        gender: user?.gender,
        height: data.height,
        weight: data.weight,
        neck: data.neck,
        waist: data.waist,
        hip: data.hip,
        birthday: user?.birthday!,
        bmi: data.bmi,
        bmr: data.bmr,
        bodyFatPercentage: data.bodyFatPercentage,
        muscleMass: data.muscleMass,
        whr: data.whr,
      });

      console.log("User metrics: ", metrics);

      // Prepare input for AI model evaluation
      const aiInput = {
        ...data,
        ...metrics,
        healthStatus: data.healthStatus,
      };

      // Perform AI-based health evaluation
      const aiEvaluation = await callOllamaEvaluation(aiInput);

      // Persist the record in database
      const healthProfile = await this.healthProfileRepo.create({
        ...data,
        ...metrics,
        userId: new Types.ObjectId(data.userId ?? userId),
        checkupDate: new Date(),
        aiEvaluation,
      });

      // Audit log
      await logAudit({
        userId,
        action: "createHealthProfile",
        message: `Created HealthProfile for user "${userId}" successfully`,
        status: StatusLogEnum.Success,
        targetId: healthProfile._id.toString(),
      });

      return healthProfile;
    } catch (err: any) {
      await logError({
        userId,
        action: "createHealthProfile",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =========================================================
  // READ
  //! For Admin
  // =========================================================

  /**
   * Retrieve all health profiles with optional pagination and filters.
   *
   * @param option - Pagination and query options.
   * @returns A list of HealthProfile documents.
   */
  async getHealthProfiles(option?: PaginationQueryOptions) {
    try {
      return await this.healthProfileRepo.findAll({}, option);
    } catch (err: any) {
      await logError({
        action: "getHealthProfiles",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  //! For User
  /**
   * Retrieve all health profiles for a specific user.
   *
   * @param userId - The ID of the target user.
   * @param option - Pagination and query options.
   * @returns A list of HealthProfile documents for the specified user.
   */
  async getHealthProfilesByUserId(
    userId: string,
    option?: PaginationQueryOptions
  ) {
    try {
      return await this.healthProfileRepo.findAll({ userId }, option);
    } catch (err: any) {
      await logError({
        action: "getHealthProfilesByUserId",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  /**
   * Retrieve a specific health profile by ID.
   *
   * @param healthProfileId - The ID of the health profile.
   * @returns The corresponding HealthProfile document.
   *
   * @throws HttpError - If the profile does not exist.
   */
  async getHealthProfileById(healthProfileId: string) {
    try {
      const healthProfile = await this.healthProfileRepo.findById(
        healthProfileId
      );
      if (!healthProfile) {
        throw new HttpError(404, "HealthProfile not found");
      }
      return healthProfile;
    } catch (err: any) {
      await logError({
        action: "getHealthProfileById",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  /**
   * Retrieve a specific health profile by userId.
   *
   * @param userId - The ID of the userId in health profile.
   * @returns The corresponding HealthProfile document.
   *
   * @throws HttpError - If the profile does not exist.
   */
  async getHealthProfileLatestByUserId(userId: string) {
    try {
      const healthProfile =
        await this.healthProfileRepo.getHealthProfileLatestByUserId(userId);
      if (!healthProfile) {
        throw new HttpError(404, "HealthProfile not found");
      }
      return healthProfile;
    } catch (err: any) {
      await logError({
        userId,
        action: "getHealthProfileLatestByUserId",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  /**
   * Retrieve a specific health profile by userId and date.
   *
   * @param userId - The ID of the user.
   * @param date - The date to search for.
   * @returns The corresponding HealthProfile document or null.
   */
  async getHealthProfileByDate(userId: string, date: string) {
    try {
      const parsedDate = new Date(date);
      if (isNaN(parsedDate.getTime())) {
        throw new HttpError(400, "Invalid date format");
      }

      const profile = await this.healthProfileRepo.findByDate(
        userId,
        parsedDate
      );

      return profile;
    } catch (err: any) {
      await logError({
        userId,
        action: "getHealthProfileByDate",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =========================================================
  // UPDATE
  // =========================================================

  /**
   * Update an existing health profile and trigger re-evaluation.
   *
   * @param healthProfileId - The ID of the profile to update.
   * @param data - Updated partial data.
   * @param userId - The ID of the user performing the update.
   * @returns The updated HealthProfile document.
   *
   * @throws HttpError - If the profile or user does not exist.
   */
  async updateHealthProfile(
    healthProfileId: string,
    data: Partial<IHealthProfile>,
    userId: string
  ) {
    try {
      // Retrieve existing profile
      const existing = await this.healthProfileRepo.findById(healthProfileId);
      if (!existing) {
        throw new HttpError(404, "Hồ sơ không tìm thấy");
      }

      if (userId !== existing.userId?.toString()) {
        throw new HttpError(403, "Không có quyền cập nhật hồ sơ này");
      }

      // Retrieve user data for recalculations
      const user = await this.userRepo.findById(
        data.userId?.toString() ?? existing.userId?.toString() ?? userId
      );
      if (!user) {
        throw new HttpError(404, "Không tìm thấy người dùng");
      }

      // Recalculate health metrics
      const metrics = calculateHealthMetrics({
        gender: user.gender!,
        height: data.height ?? existing.height!,
        weight: data.weight ?? existing.weight!,
        neck: data.neck ?? existing.neck!,
        waist: data.waist ?? existing.waist!,
        hip: data.hip ?? existing.hip!,
        birthday: user.birthday!,
      });

      // Prepare AI evaluation input
      const aiInput = {
        ...(existing.toObject?.() ?? existing),
        ...data,
        ...metrics,
        healthStatus: data.healthStatus ?? existing.healthStatus,
      };

      const aiEvaluation = await callOllamaEvaluation(aiInput);

      // Update database record
      const updated = await this.healthProfileRepo.update(healthProfileId, {
        ...data,
        ...metrics,
        aiEvaluation,
        updatedAt: new Date(),
      });

      // Audit log
      await logAudit({
        userId,
        action: "updateHealthProfile",
        message: `Updated HealthProfile "${healthProfileId}" successfully`,
        status: StatusLogEnum.Success,
        targetId: healthProfileId,
      });

      return updated;
    } catch (err: any) {
      await logError({
        userId,
        action: "updateHealthProfile",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

  /**
   * Delete a health profile by ID.
   *
   * @param healthProfileId - The ID of the profile to delete.
   * @param userId - The ID of the user performing the deletion.
   * @returns The deleted HealthProfile document.
   *
   * @throws HttpError - If the profile does not exist.
   */
  async deleteHealthProfile(healthProfileId: string, userId: string) {
    try {
      const existing = await this.healthProfileRepo.findById(healthProfileId);
      if (!existing) {
        await logAudit({
          userId,
          action: "deleteHealthProfile",
          message: `HealthProfile "${healthProfileId}" not found`,
          status: StatusLogEnum.Failure,
        });
        throw new HttpError(404, "Không tùm thấy hồ sơ");
      }
      if (userId !== existing.userId?.toString()) {
        throw new HttpError(403, "Không có quyền xoá hồ sơ này");
      }

      const deleted = await this.healthProfileRepo.delete(healthProfileId);

      await logAudit({
        userId,
        action: "deleteHealthProfile",
        message: `Deleted HealthProfile "${healthProfileId}" successfully`,
        status: StatusLogEnum.Success,
        targetId: healthProfileId,
      });

      return deleted;
    } catch (err: any) {
      await logError({
        userId,
        action: "deleteHealthProfile",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  /**
   * Lấy hồ sơ sức khỏe mới nhất của người dùng cho mô hình RAG.
   *
   * @param userId - ID người dùng.
   * @returns Hồ sơ RAG hoặc null nếu không tìm thấy.
   */
  async findProfileForRAG(userId: string): Promise<IRAGHealthProfile | null> {
    try {
      const profile = await this.healthProfileRepo.findProfileForRAG(userId);

      if (!profile) {
        await logAudit({
          userId,
          action: "findProfileForRAG",
          message: `Không tìm thấy hồ sơ sức khỏe RAG cho user "${userId}"`,
          status: StatusLogEnum.Failure,
        });
        return null;
      }

      await logAudit({
        userId,
        action: "findProfileForRAG",
        message: `Truy vấn hồ sơ RAG thành công cho user "${userId}"`,
        status: StatusLogEnum.Success,
      });

      return profile;
    } catch (err: any) {
      await logError({
        userId,
        action: "findProfileForRAG",
        message: "Lỗi khi truy vấn hồ sơ RAG",
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể truy vấn hồ sơ sức khỏe RAG");
    }
  }
}

import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { IWorkoutTemplate, IWorkoutTemplateDetail } from "../../models";
import { WorkoutTemplateRepository } from "../../repositories";
import { HttpError } from "../../../utils/HttpError";
import {
  IRAGAIResponse,
  IRAGExercise,
  PaginationQueryOptions,
  UserRAGRequest,
} from "../../entities";
import { Types } from "mongoose";
import { mapAIResponseToWorkoutDetail } from "../../../utils/Workout/MapAIToDatabase";

export class WorkoutTemplateService {
  private readonly workoutTemplateRepo: WorkoutTemplateRepository;

  constructor(workoutTemplateRepo: WorkoutTemplateRepository) {
    this.workoutTemplateRepo = workoutTemplateRepo;
  }

  // ======================================================
  // =============== CREATE WORKOUT TEMPLATE ===============
  // ======================================================
  /**
   * Create a new workout template for a user.
   * - Saves the workout template into the database.
   * - Logs the creation event in the audit log.
   *
   * @param userId - ID of the user creating the template
   * @param data - Partial workout template data
   * @returns The created workout template document
   * @throws HttpError if creation fails
   */
  async createWorkoutTemplate(userId: string, data: Partial<IWorkoutTemplate>) {
    try {
      // Gán createdForUserId từ authenticated user
      const templateData = { ...data, createdForUserId: new Types.ObjectId(userId) };
      const newTemplate = await this.workoutTemplateRepo.create(templateData);

      await logAudit({
        userId,
        action: "createWorkoutTemplate",
        message: `Tạo WorkoutTemplate "${newTemplate.name}" thành công`,
        status: StatusLogEnum.Success,
        targetId: newTemplate._id.toString(),
      });

      return newTemplate;
    } catch (err: any) {
      await logError({
        userId,
        action: "createWorkoutTemplate",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể tạo mẫu buổi tập");
    }
  }

  // ======================================================
  // =============== UPDATE WORKOUT TEMPLATE ===============
  // ======================================================
  /**
   * Update an existing workout template.
   * - Applies partial updates to the template data.
   * - Logs the update event in the audit log.
   *
   * @param userId - ID of the user performing the update
   * @param workoutTemplateId - ID of the workout template to update
   * @param updateData - Partial data to update
   * @returns The updated workout template document
   * @throws HttpError if update fails or template not found
   */
  async updateWorkoutTemplate(
    userId: string,
    workoutTemplateId: string,
    updateData: Partial<IWorkoutTemplate>
  ) {
    try {
      const updated = await this.workoutTemplateRepo.update(
        workoutTemplateId,
        updateData
      );

      if (!updated) {
        throw new HttpError(404, "Mẫu buổi tập không tồn tại");
      }

      await logAudit({
        userId,
        action: "updateWorkoutTemplate",
        message: `Cập nhật WorkoutTemplate "${workoutTemplateId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: workoutTemplateId,
      });

      return updated;
    } catch (err: any) {
      await logError({
        userId,
        action: "updateWorkoutTemplate",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // ======================================================
  // =============== DELETE WORKOUT TEMPLATE ===============
  // ======================================================
  /**
   * Delete a workout template by ID.
   * - Removes the template from the database.
   * - Logs success or failure.
   *
   * @param userId - ID of the user performing the deletion
   * @param workoutTemplateId - ID of the template to delete
   * @returns The deleted workout template document
   * @throws HttpError(404) if the template does not exist
   */
  async deleteWorkoutTemplate(userId: string, workoutTemplateId: string) {
    try {
      const deleted = await this.workoutTemplateRepo.delete(workoutTemplateId);

      if (!deleted) {
        await logAudit({
          userId,
          action: "deleteWorkoutTemplate",
          message: `WorkoutTemplate "${workoutTemplateId}" không tồn tại`,
          status: StatusLogEnum.Failure,
        });
        throw new HttpError(404, "Mẫu buổi tập không tồn tại");
      }

      await logAudit({
        userId,
        action: "deleteWorkoutTemplate",
        message: `Xóa WorkoutTemplate "${workoutTemplateId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: workoutTemplateId,
      });

      return deleted;
    } catch (err: any) {
      await logError({
        userId,
        action: "deleteWorkoutTemplate",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // ======================================================
  // =============== GET WORKOUT TEMPLATE BY ID ============
  // ======================================================
  /**
   * Retrieve a single workout template by ID.
   * - Throws error if not found.
   *
   * @param workoutTemplateId - ID of the workout template to retrieve
   * @returns The workout template document
   * @throws HttpError(404) if not found
   */
  async getWorkoutTemplateById(workoutTemplateId: string) {
    try {
      const template = await this.workoutTemplateRepo.getWorkoutTemplateById(
        workoutTemplateId
      );

      if (!template) {
        throw new HttpError(404, "Mẫu buổi tập không tồn tại");
      }

      return template;
    } catch (err: any) {
      await logError({
        action: "getWorkoutTemplateById",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // ======================================================
  // =============== GET ALL WORKOUT TEMPLATES (ADMIN) =====
  // ======================================================
  /**
   * Retrieve all workout templates in the system.
   * - For admin usage.
   * - Supports pagination and sorting.
   *
   * @param options - Optional pagination and filtering options
   * @returns Paginated list of workout templates
   */
  async getAllWorkoutTemplates(options?: PaginationQueryOptions) {
    try {
      return await this.workoutTemplateRepo.findAllWorkoutTemplate({}, options);
    } catch (err: any) {
      await logError({
        action: "getAllWorkoutTemplates",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể lấy danh sách mẫu buổi tập");
    }
  }

  // ======================================================
  // =============== GET WORKOUT TEMPLATES BY USER =========
  // ======================================================
  /**
   * Retrieve all workout templates created by a specific user.
   * - Supports pagination.
   *
   * @param userId - ID of the user whose templates to retrieve
   * @param options - Optional pagination and filtering options
   * @returns Paginated list of user's workout templates
   */
  async getWorkoutTemplatesByUserId(
    userId: string,
    options?: PaginationQueryOptions
  ) {
    try {
      return await this.workoutTemplateRepo.findAllWorkoutTemplate(
        { createdForUserId: userId },
        options
      );
    } catch (err: any) {
      await logError({
        userId,
        action: "getWorkoutTemplatesByUserId",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(
        500,
        "Không thể lấy danh sách mẫu buổi tập của người dùng"
      );
    }
  }

  /**
   * Create a workout template for a user from AI-generated recommendation.
   *
   * @param userId - User ID
   * @param userRequest - Original request data (equipment, muscles, etc.)
   * @param aiResponse - AI response containing exercises, sets, HR, etc.
   * @returns The created workout template
   */
  async createWorkoutTemplateByAI(
    userId: string,
    userRequest: UserRAGRequest,
    aiResponse: IRAGAIResponse,
    exerciseStuitable: IRAGExercise[]
  ): Promise<IWorkoutTemplate> {
    try {
      // Convert AI exercises to WorkoutTemplateDetail using your utils
      const workOutDetail: IWorkoutTemplateDetail[] =
        mapAIResponseToWorkoutDetail(aiResponse, exerciseStuitable);

      const newTemplateData: Partial<IWorkoutTemplate> = {
        name: `AI Workout - ${new Date().toISOString().split("T")[0]}`,
        description: `Generated based on user profile and AI recommendation`,
        createdByAI: true,
        createdForUserId: new Types.ObjectId(userId),
        location: userRequest.location,
        equipments: userRequest.equipmentIds,
        bodyPartsTarget: userRequest.bodyPartIds,
        exerciseTypes: userRequest.exerciseTypes,
        exerciseCategories: userRequest.exerciseCategories,
        workOutDetail,
      };

      const newTemplate = await this.workoutTemplateRepo.create(
        newTemplateData
      );

      await logAudit({
        userId,
        action: "createWorkoutTemplateByAI",
        message: `Created AI workout template "${newTemplate.name}" successfully`,
        status: StatusLogEnum.Success,
        targetId: newTemplate._id.toString(),
      });

      return newTemplate;
    } catch (err: any) {
      await logError({
        userId,
        action: "createWorkoutTemplateByAI",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Failed to create AI workout template");
    }
  }
}

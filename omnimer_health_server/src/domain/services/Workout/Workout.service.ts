import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import {
  IWorkout,
  IWorkoutDetail,
  IWorkoutDeviceData,
  IWorkoutSet,
} from "../../models";
import {
  HealthProfileRepository,
  UserRepository,
  WatchLogRepository,
  WorkoutRepository,
  WorkoutTemplateRepository,
} from "../../repositories";
import { HttpError } from "../../../utils/HttpError";
import { PaginationQueryOptions } from "../../entities";
import { Types } from "mongoose";
import {
  calculateCaloriesByMET,
  calculateWorkoutSummary,
} from "../../../utils/Workout/WorkoutUtil";
import { GraphDBService } from "../LOD/GraphDB.service";
import { LODMapper } from "../LOD/LODMapper";

export class WorkoutService {
  private readonly workoutRepo: WorkoutRepository;
  private readonly workoutTemplateRepo: WorkoutTemplateRepository;
  private readonly healthProfileRepo: HealthProfileRepository;
  private readonly watchLogRepo: WatchLogRepository;
  private readonly graphDBService: GraphDBService;

  constructor(
    workoutRepo: WorkoutRepository,
    workoutTemplateRepo: WorkoutTemplateRepository,
    healthProfileRepo: HealthProfileRepository,
    watchLogRepo: WatchLogRepository,
    graphDBService: GraphDBService
  ) {
    this.workoutRepo = workoutRepo;
    this.workoutTemplateRepo = workoutTemplateRepo;
    this.healthProfileRepo = healthProfileRepo;
    this.watchLogRepo = watchLogRepo;
    this.graphDBService = graphDBService;
  }

  // ======================================================
  // =============== CREATE WORKOUT TEMPLATE ===============
  // ======================================================
  /**
   * Create a new workout for a user.
   * - Saves the workout into the database.
   * - Logs the creation event in the audit log.
   *
   * @param userId - ID of the user creating the template
   * @param data - Partial workout data
   * @returns The created workout document
   * @throws HttpError if creation fails
   */
  async createWorkout(userId: string, data: Partial<IWorkout>) {
    try {
      // Auto-fill userId and healthProfileId if not provided
      const healthProfileId =
        await this.healthProfileRepo.findEarliestIdByUserId(userId);

      const workoutData: Partial<IWorkout> = {
        ...data,
        userId: new Types.ObjectId(userId),
      };

      // Only add healthProfileId if found (it's optional)
      if (healthProfileId) {
        workoutData.healthProfileId = healthProfileId;
      }

      const workout = await this.workoutRepo.create(workoutData);
      await logAudit({
        userId,
        action: "createWorkout",
        message: `Tạo Workout thành công`,
        status: StatusLogEnum.Success,
        targetId: workout._id.toString(),
      });
      return workout;
    } catch (err: any) {
      await logError({
        userId,
        action: "createWorkout",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      if (err instanceof HttpError) throw err;
      throw new HttpError(500, "Không thể tạo buổi tập");
    }
  }

  // ======================================================
  // =============== UPDATE WORKOUT TEMPLATE ===============
  // ======================================================
  /**
   * Update an existing workout template.
   * - Applies partial updates to the data.
   * - Logs the update event in the audit log.
   *
   * @param userId - ID of the user performing the update
   * @param workoutId - ID of the workout to update
   * @param updateData - Partial data to update
   * @returns The updated workout document
   * @throws HttpError if update fails or not found
   */
  async updateWorkout(
    userId: string,
    workoutId: string,
    updateData: Partial<IWorkout>
  ) {
    try {
      const updated = await this.workoutRepo.update(workoutId, updateData);

      if (!updated) {
        throw new HttpError(404, "Buổi tập không tồn tại");
      }

      await logAudit({
        userId,
        action: "updateWorkout",
        message: `Cập nhật Workout "${workoutId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: workoutId,
      });

      return updated;
    } catch (err: any) {
      await logError({
        userId,
        action: "updateWorkout",
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
   * Delete a workout by ID.
   * - Removes the from the database.
   * - Logs success or failure.
   *
   * @param userId - ID of the user performing the deletion
   * @param workoutId - ID of the to delete
   * @returns The deleted workout document
   * @throws HttpError(404) if the does not exist
   */
  async deleteWorkout(
    userId: string,
    workoutId: string,
    isDataSharingAccepted?: boolean
  ) {
    try {
      const deleted = await this.workoutRepo.delete(workoutId);

      if (!deleted) {
        await logAudit({
          userId,
          action: "deleteWorkout",
          message: `Workout "${workoutId}" không tồn tại`,
          status: StatusLogEnum.Failure,
        });
        throw new HttpError(404, "Buổi tập không tồn tại");
      }

      if (isDataSharingAccepted) {
        await this.graphDBService.deleteWorkoutData(workoutId);
      }

      await logAudit({
        userId,
        action: "deleteWorkout",
        message: `Xóa Workout "${workoutId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: workoutId,
      });

      return deleted;
    } catch (err: any) {
      await logError({
        userId,
        action: "deleteWorkout",
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
   * Retrieve a single workout by ID.
   * - Throws error if not found.
   *
   * @param workoutId - ID of the workout to retrieve
   * @returns The workout document
   * @throws HttpError(404) if not found
   */
  async getWorkoutById(workoutId: string) {
    try {
      const workouts = await this.workoutRepo.getWorkoutById(workoutId);

      if (!workouts) {
        throw new HttpError(404, "Buổi tập không tồn tại");
      }

      return workouts;
    } catch (err: any) {
      await logError({
        action: "getWorkoutById",
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
   * @param userId - ID of the user requesting the data
   * @param options - Optional pagination and filtering options
   * @returns Paginated list of workout templates
   */
  async getAllWorkouts(userId: string, options?: PaginationQueryOptions) {
    try {
      return await this.workoutRepo.findAllWorkout({}, options);
    } catch (err: any) {
      await logError({
        userId,
        action: "getAllWorkouts",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể lấy danh sách buổi tập");
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
  async getWorkoutsByUserId(userId: string, options?: PaginationQueryOptions) {
    try {
      return await this.workoutRepo.findAllWorkout({ userId: userId }, options);
    } catch (err: any) {
      await logError({
        userId,
        action: "getWorkoutsByUserId",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(
        500,
        "Không thể lấy danh sách buổi tập của người dùng"
      );
    }
  }

  //? Work flow chính của buổi tập:
  // Bắt đầu buổi tập: Cập nhật timeStart = Date.now
  // Thực hiện 1 bài tập
  // Kết thúc 1 set: Cập nhật done trong IWorkoutSet thành true
  // Kết thúc 1 bài tập (tất cả set trong bài tập đó đều done): Cập nhật durationMin từ client tự đo và gửi vào và deviceData được thu thập bằng devices của apple watch
  // Kết thúc buổi tập hoặc hoàn thành tất cả bài tập: Tự động tính toán totalSets, totalReps, totalWeight, totalCalories, totalDistance mà đã done totalDuration. Date.now - timeStart

  // ======================================================
  // =========== CREATE WORKOUT FROM TEMPLATE ==============
  // ======================================================
  /**
   * Tạo mới một buổi tập dựa trên Workout Template có sẵn.
   *
   * Quy trình:
   * - Sao chép cấu trúc `workOutDetail` từ template.
   * - Gán `userId` và `workoutTemplateId`.
   * - Đặt `timeStart = null` (chưa bắt đầu buổi tập).
   * - Đánh dấu tất cả các sets trong bài tập là `done = false`.
   *
   * @async
   * @param {string} userId - ID của người dùng tạo buổi tập.
   * @param {string} workoutTemplateId - ID của template dùng để khởi tạo.
   * @returns {Promise<IWorkout>} Trả về document Workout mới được tạo.
   * @throws {HttpError} - Nếu template không tồn tại hoặc không có bài tập.
   */
  async createWorkoutByTemplateId(userId: string, workoutTemplateId: string) {
    try {
      const healthProfileId =
        await this.healthProfileRepo.findEarliestIdByUserId(userId);
      if (!healthProfileId)
        throw new HttpError(404, "Can't find health profile user");

      const template = await this.workoutTemplateRepo.findById(
        workoutTemplateId
      );
      if (!template) throw new HttpError(404, "Can't find the template");

      if (!template.workOutDetail || template.workOutDetail.length === 0) {
        throw new HttpError(400, "The template is empty");
      }

      // Clone workOutDetail từ template
      const workoutDetail = template.workOutDetail.map((ex) => ({
        exerciseId: ex.exerciseId,
        type: ex.type,
        sets: ex.sets.map((set) => ({
          ...set,
          done: false,
        })) as IWorkoutSet[],
      })) as IWorkoutDetail[];

      const newWorkout = await this.workoutRepo.create({
        userId: new Types.ObjectId(userId),
        healthProfileId: healthProfileId,
        workoutTemplateId: new Types.ObjectId(workoutTemplateId),
        workoutDetail,
        summary: {},
      });

      await logAudit({
        userId,
        action: "createWorkoutByTemplateId",
        message: `Tạo buổi tập mới từ template ${template.name}`,
        status: StatusLogEnum.Success,
      });

      return newWorkout;
    } catch (err: any) {
      await logError({
        userId,
        action: "createWorkoutByTemplateId",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể tạo buổi tập");
    }
  }

  // ======================================================
  // ================= START WORKOUT ======================
  // ======================================================
  /**
   * Cập nhật thời gian bắt đầu (`timeStart`) cho một buổi tập,
   * đánh dấu trạng thái buổi tập là “đang diễn ra”.
   *
   * @async
   * @param {string} workoutId - ID của buổi tập cần bắt đầu.
   * @returns {Promise<IWorkout>} Trả về document Workout sau khi cập nhật.
   * @throws {HttpError} - Nếu không tìm thấy buổi tập hoặc cập nhật thất bại.
   */
  async startWorkout(workoutId: string) {
    try {
      const workout = await this.workoutRepo.update(workoutId, {
        timeStart: new Date(),
      });
      if (!workout) throw new HttpError(404, "Buổi tập không tồn tại");

      return workout;
    } catch (err: any) {
      await logError({
        action: "startWorkout",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể bắt đầu buổi tập");
    }
  }

  // ======================================================
  // ================= COMPLETE SET =======================
  // ======================================================
  /**
   * Đánh dấu một set cụ thể trong bài tập là đã hoàn thành (`done = true`).
   *
   * @async
   * @param {string} workoutId - ID của buổi tập chứa set.
   * @param {string} workoutDetailId - ID của bài tập (exercise) chứa set.
   * @param {string} workoutSetId - ID của set cần đánh dấu hoàn thành.
   * @returns {Promise<boolean>} Trả về `true` nếu cập nhật thành công.
   * @throws {HttpError} - Nếu không tìm thấy set hoặc cập nhật thất bại.
   */
  async completeSet(
    workoutId: string,
    workoutDetailId: string,
    workoutSetId: string
  ) {
    try {
      const result = await this.workoutRepo.updateSetDone(
        workoutId,
        workoutDetailId,
        workoutSetId,
        true
      );

      if (result.modifiedCount === 0)
        throw new HttpError(404, "Không tìm thấy set cần cập nhật");

      await logAudit({
        action: "completeSet",
        message: `Đánh dấu hoàn thành set ${workoutSetId}`,
        status: StatusLogEnum.Success,
      });

      // Trả về document mới nhất nếu cần
      return true;
    } catch (err: any) {
      await logError({
        action: "completeSet",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể cập nhật trạng thái set");
    }
  }

  // ======================================================
  // ============ COMPLETE EXERCISE =======================
  // ======================================================
  /**
   * Đánh dấu một bài tập trong buổi tập là đã hoàn thành,
   * đồng thời cập nhật thời lượng tập và dữ liệu thiết bị nếu có.
   *
   * @async
   * @param {string} workoutId - ID của buổi tập.
   * @param {string} workoutDetailId - ID của bài tập trong buổi tập.
   * @param {number} durationMin - Thời gian tập luyện (phút).
   * @param {object} [deviceData] - Dữ liệu từ thiết bị (calories, heartRate, ...).
   * @returns {Promise<boolean>} Trả về `true` nếu cập nhật thành công.
   * @throws {HttpError} - Nếu không tìm thấy bài tập hoặc không có thay đổi.
   */
  async completeExercise(
    userId: string,
    workoutId: string,
    workoutDetailId: string,
    startTime: Date,
    endTime: Date,
    deviceData?: IWorkoutDeviceData
  ) {
    try {
      // 1. Tính toán durationMin
      const durationMs =
        new Date(endTime).getTime() - new Date(startTime).getTime();
      const durationMin = durationMs / 60000;

      let finalDeviceData = deviceData;

      if (!finalDeviceData) {
        // 2. Thử lấy dữ liệu từ WatchLog (Server-side Aggregation)
        const logs = await this.watchLogRepo.findLogsByTimeRange(
          userId,
          new Date(startTime),
          new Date(endTime)
        );

        if (logs && logs.length > 0) {
          console.log(`Found ${logs.length} watch logs for aggregation.`);

          // Aggregate Data
          const totalCalories = logs.reduce(
            (sum, log) => sum + (log.caloriesActive || 0),
            0
          );

          // Heart Rate Avg: Trung bình cộng đơn giản (có thể cải tiến thành weighted average)
          const validHrLogs = logs.filter(
            (l) => l.heartRateAvg && l.heartRateAvg > 0
          );
          const avgHR =
            validHrLogs.length > 0
              ? validHrLogs.reduce(
                  (sum, log) => sum + (log.heartRateAvg || 0),
                  0
                ) / validHrLogs.length
              : 0;

          // Heart Rate Max: Lấy max của các max
          const maxHR = Math.max(...logs.map((log) => log.heartRateMax || 0));

          finalDeviceData = {
            caloriesBurned: totalCalories,
            heartRateAvg: Math.round(avgHR),
            heartRateMax: maxHR > 0 ? maxHR : undefined,
          };
        } else {
          // 3. Fallback: Nếu không có WatchLog, dùng công thức MET
          console.log("No watch logs found. Using MET calculation fallback.");

          const metaInfo =
            await this.workoutRepo.getExerciseMetAndUserWeightAndDetail(
              workoutId,
              workoutDetailId
            );

          if (!metaInfo) {
            throw new HttpError(
              404,
              "Không tìm thấy thông tin bài tập hoặc người dùng"
            );
          }

          const { met, weight, detail } = metaInfo;

          const caloriesBurned = calculateCaloriesByMET(
            met,
            weight,
            durationMin,
            detail
          );

          finalDeviceData = {
            caloriesBurned,
          };
        }
      }

      const result = await this.workoutRepo.updateExerciseInfo(
        workoutId,
        workoutDetailId,
        durationMin,
        finalDeviceData
      );

      if (result.matchedCount === 0)
        throw new HttpError(404, "Buổi tập hoặc bài tập không tồn tại");

      if (result.modifiedCount === 0)
        // Có thể không lỗi nếu dữ liệu y hệt, nhưng cứ báo warning hoặc success
        console.warn("Không có thay đổi nào được thực hiện trong DB");

      return true;
    } catch (err: any) {
      await logError({
        action: "completeExercise",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể cập nhật bài tập");
    }
  }

  // ======================================================
  // ============ FINISH WORKOUT & CALCULATE ==============
  // ======================================================
  /**
   * Kết thúc buổi tập và tính toán thống kê tổng hợp (summary).
   *
   * Quy trình:
   * - Lấy dữ liệu buổi tập theo ID.
   * - Gọi util `calculateWorkoutSummary()` để tính toán:
   *   - Tổng set, reps, weight, thời lượng, calories, nhịp tim, v.v.
   * - Gán `summary` vào document và lưu lại.
   *
   * @async
   * @param {string} workoutId - ID của buổi tập cần hoàn thành.
   * @returns {Promise<{ message: string; summary: any }>}
   * Trả về thông báo và kết quả summary tổng hợp.
   * @throws {HttpError} - Nếu buổi tập không tồn tại hoặc cập nhật thất bại.
   */
  async finishWorkout(
    workoutId: string,
    userId?: string,
    isDataSharingAccepted?: boolean
  ) {
    try {
      const workout = await this.workoutRepo.findById(workoutId);
      if (!workout) throw new HttpError(404, "Buổi tập không tồn tại");

      const summary = calculateWorkoutSummary(workout);

      workout.summary = summary;
      await workout.save();

      if (isDataSharingAccepted) {
        console.log("Inserting workout data to GraphDB");
        const rdf = LODMapper.mapWorkoutToRDF(workout);
        console.log("Inserting workout data to GraphDB: ", rdf);
        await this.graphDBService.insertData(rdf);
      }

      await logAudit({
        action: "finishWorkout",
        status: StatusLogEnum.Success,
        message: `Người dùng hoàn thành buổi tập ${workoutId}`,
      });

      return {
        message: "Đã hoàn thành buổi tập",
        summary,
      };
    } catch (err: any) {
      await logError({
        userId,
        action: "finishWorkout",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể kết thúc buổi tập");
    }
  }
}

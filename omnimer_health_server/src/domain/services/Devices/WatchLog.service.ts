import { logError, logAudit } from "../../../utils/LoggerUtil";
import { StatusLogEnum } from "../../../common/constants/AppConstants";
import { IWatchLog } from "../../models";
import { WatchLogRepository } from "../../repositories";
import { HttpError } from "../../../utils/HttpError";
import { PaginationQueryOptions } from "../../entities";

export class WatchLogService {
  private readonly watchLogRepo: WatchLogRepository;

  constructor(watchLogRepo: WatchLogRepository) {
    this.watchLogRepo = watchLogRepo;
  }

  // ======================================================
  // =============== CREATE SINGLE WATCHLOG ==============
  // ======================================================
  /**
   * Create a new WatchLog entry for a user.
   * - Saves a single WatchLog document into the database.
   * - Logs the creation event in the audit log.
   *
   * @param userId - ID of the user creating the WatchLog
   * @param data - Partial WatchLog data to be saved
   * @returns The created WatchLog document
   * @throws HttpError if creation fails
   */
  async createWatchLog(userId: string, data: Partial<IWatchLog>) {
    try {
      const newLog = await this.watchLogRepo.create(data);

      await logAudit({
        userId,
        action: "createWatchLog",
        message: `Tạo WatchLog thành công`,
        status: StatusLogEnum.Success,
        targetId: newLog._id.toString(),
      });

      return newLog;
    } catch (err: any) {
      await logError({
        userId,
        action: "createWatchLog",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể tạo WatchLog");
    }
  }

  // ======================================================
  // =============== CREATE MANY WATCHLOG =================
  // ======================================================
  /**
   * Create multiple WatchLog entries at once.
   * - Inserts an array of WatchLog documents into the database.
   * - Logs the creation event with count of successfully inserted documents.
   *
   * @param userId - ID of the user creating the WatchLogs
   * @param logs - Array of Partial WatchLog data to be saved
   * @returns Array of created WatchLog documents
   * @throws HttpError if insertion fails
   */
  async createManyWatchLog(userId: string, logs: Partial<IWatchLog>[]) {
    try {
      const createdLogs = await this.watchLogRepo.createMany(logs);

      await logAudit({
        userId,
        action: "createManyWatchLog",
        message: `Tạo ${createdLogs.length} WatchLog thành công`,
        status: StatusLogEnum.Success,
      });

      return createdLogs;
    } catch (err: any) {
      await logError({
        userId,
        action: "createManyWatchLog",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể tạo nhiều WatchLog");
    }
  }

  // ======================================================
  // =============== UPDATE WATCHLOG ======================
  // ======================================================
  /**
   * Update an existing WatchLog entry.
   * - Applies partial updates to the specified WatchLog document.
   * - Logs the update event in the audit log.
   *
   * @param userId - ID of the user performing the update
   * @param watchLogId - ID of the WatchLog to update
   * @param updateData - Partial data to update
   * @returns The updated WatchLog document
   * @throws HttpError if WatchLog not found or update fails
   */
  async updateWatchLog(
    userId: string,
    watchLogId: string,
    updateData: Partial<IWatchLog>
  ) {
    try {
      const updated = await this.watchLogRepo.update(watchLogId, updateData);

      if (!updated) throw new HttpError(404, "WatchLog không tồn tại");

      await logAudit({
        userId,
        action: "updateWatchLog",
        message: `Cập nhật WatchLog "${watchLogId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: watchLogId,
      });

      return updated;
    } catch (err: any) {
      await logError({
        userId,
        action: "updateWatchLog",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // ======================================================
  // =============== GET ALL WATCHLOG =====================
  // ======================================================
  /**
   * Retrieve all WatchLog entries.
   * - Supports optional pagination and sorting options.
   * - Returns a list of WatchLog documents.
   *
   * @param options - Optional pagination and filtering options
   * @returns Array of WatchLog documents
   * @throws HttpError if retrieval fails
   */
  async getAllWatchLog(userId: string, options?: PaginationQueryOptions) {
    try {
      const logs = await this.watchLogRepo.findAll({}, options);
      await logAudit({
        userId,
        action: "getAllWatchLog",
        message: `Danh sách WatchLog "${logs.length}" thành công`,
        status: StatusLogEnum.Success,
        metadata: options,
      });
      return logs;
    } catch (err: any) {
      await logError({
        userId,
        action: "getAllWatchLog",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể lấy danh sách WatchLog");
    }
  }

  // ======================================================
  // =============== DELETE SINGLE WATCHLOG ==============
  // ======================================================
  /**
   * Delete a single WatchLog entry by ID.
   * - Removes the WatchLog document from the database.
   * - Logs the deletion event in the audit log.
   *
   * @param userId - ID of the user performing the deletion
   * @param watchLogId - ID of the WatchLog to delete
   * @returns The deleted WatchLog document
   * @throws HttpError if WatchLog not found or deletion fails
   */
  async deleteWatchLog(userId: string, watchLogId: string) {
    try {
      const deleted = await this.watchLogRepo.delete(watchLogId);

      if (!deleted) throw new HttpError(404, "WatchLog không tồn tại");

      await logAudit({
        userId,
        action: "deleteWatchLog",
        message: `Xóa WatchLog "${watchLogId}" thành công`,
        status: StatusLogEnum.Success,
        targetId: watchLogId,
      });

      return deleted;
    } catch (err: any) {
      await logError({
        userId,
        action: "deleteWatchLog",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw err;
    }
  }

  // ======================================================
  // =============== DELETE MANY WATCHLOG ===============
  // ======================================================
  /**
   * Delete multiple WatchLog entries at once.
   * - Removes all WatchLog documents matching the provided IDs.
   * - Logs the deletion event with count of deleted documents.
   *
   * @param userId - ID of the user performing the deletion
   * @param watchLogIds - Array of WatchLog IDs to delete
   * @returns Object containing deletion result (deletedCount)
   * @throws HttpError if deletion fails
   */
  async deleteManyWatchLog(userId: string, watchLogIds: string[]) {
    try {
      const result = await this.watchLogRepo.deleteMany({
        _id: { $in: watchLogIds },
      });

      await logAudit({
        userId,
        action: "deleteManyWatchLog",
        message: `Xóa ${result.deletedCount} WatchLog thành công`,
        status: StatusLogEnum.Success,
      });

      return result;
    } catch (err: any) {
      await logError({
        userId,
        action: "deleteManyWatchLog",
        message: err.message || err,
        errorMessage: err.stack || err,
      });
      throw new HttpError(500, "Không thể xóa nhiều WatchLog");
    }
  }
}

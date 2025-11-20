import { Request, Response, NextFunction } from "express";
import { WatchLogService } from "../../services";
import {
  sendSuccess,
  sendCreated,
  sendUnauthorized,
} from "../../../utils/ResponseHelper";
import { DecodePayload } from "../../entities/DecodePayload.entity";
import { buildQueryOptions } from "../../../utils/BuildQueryOptions";

export class WatchLogController {
  private readonly watchLogService: WatchLogService;

  constructor(watchLogService: WatchLogService) {
    this.watchLogService = watchLogService;
  }

  // ======================================================
  // =================== CREATE SINGLE =====================
  // ======================================================
  /**
   * Create a new WatchLog record.
   * - Requires authentication (userId).
   * - Returns the created WatchLog.
   */
  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const log = await this.watchLogService.createWatchLog(userId, req.body);
      return sendCreated(res, log, "Tạo WatchLog thành công");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== CREATE MANY =======================
  // ======================================================
  /**
   * Create multiple WatchLog records at once.
   * - Requires authentication (userId).
   * - Expects an array of WatchLog data.
   */
  createMany = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const logs = await this.watchLogService.createManyWatchLog(
        userId,
        req.body
      );
      return sendCreated(res, logs, "Tạo nhiều WatchLog thành công");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== GET ALL (ADMIN) ==================
  // ======================================================
  /**
   * Retrieve all WatchLog records.
   *! - For admin usage.
   * - Supports pagination and sorting.
   */
  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }
      const options = buildQueryOptions(req.query as any);
      const logs = await this.watchLogService.getAllWatchLog(userId, options);
      return sendSuccess(res, logs, "Danh sách WatchLog");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== UPDATE ===========================
  // ======================================================
  /**
   * Update a WatchLog record by ID.
   * - Requires authentication (userId).
   * - Applies partial updates to the WatchLog document.
   */
  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const updated = await this.watchLogService.updateWatchLog(
        userId,
        req.params.id,
        req.body
      );
      return sendSuccess(res, updated, "Cập nhật WatchLog thành công");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== DELETE SINGLE ====================
  // ======================================================
  /**
   * Delete a single WatchLog record by ID.
   * - Requires authentication (userId).
   * - Removes the record permanently.
   */
  delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const deleted = await this.watchLogService.deleteWatchLog(
        userId,
        req.params.id
      );
      return sendSuccess(res, deleted, "Xóa WatchLog thành công");
    } catch (err) {
      next(err);
    }
  };

  // ======================================================
  // =================== DELETE MANY ======================
  // ======================================================
  /**
   * Delete multiple WatchLog records by IDs.
   * - Requires authentication (userId).
   * - Expects an array of WatchLog IDs.
   */
  deleteMany = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = req.user as DecodePayload;
      const userId = user?.id?.toString();
      if (!userId) {
        sendUnauthorized(res);
        return;
      }

      const result = await this.watchLogService.deleteManyWatchLog(
        userId,
        req.body.ids
      );
      return sendSuccess(res, result, "Xóa nhiều WatchLog thành công");
    } catch (err) {
      next(err);
    }
  };
}

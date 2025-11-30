import { FilterQuery, Model } from "mongoose";
import { IWatchLog } from "../../models";
import { BaseRepository } from "../base.repository";
export class WatchLogRepository extends BaseRepository<IWatchLog> {
  constructor(model: Model<IWatchLog>) {
    super(model);
  }

  /**
   * Tạo nhiều WatchLog cùng lúc
   * @param logs - mảng dữ liệu IWatchLog
   */
  async createMany(logs: Partial<IWatchLog>[]): Promise<IWatchLog[]> {
    if (!logs || logs.length === 0) return [];

    const result = await this.model.insertMany(logs, {
      ordered: false,
    });
    return result;
  }

  /**
   * Xóa nhiều WatchLog cùng lúc theo filter
   * @param filter - điều kiện để xóa nhiều bản ghi
   * @returns kết quả deleteMany
   */
  async deleteMany(filter: FilterQuery<IWatchLog>) {
    const result = await this.model.deleteMany(filter);
    return result; // { acknowledged: boolean, deletedCount: number }
  }

  /**
   * Tìm các WatchLog trong khoảng thời gian
   * @param userId - ID người dùng
   * @param startTime - Thời gian bắt đầu
   * @param endTime - Thời gian kết thúc
   */
  async findLogsByTimeRange(
    userId: string,
    startTime: Date,
    endTime: Date
  ): Promise<IWatchLog[]> {
    return this.model
      .find({
        userId: userId,
        date: { $gte: startTime, $lte: endTime },
      })
      .sort({ date: 1 })
      .exec();
  }
}

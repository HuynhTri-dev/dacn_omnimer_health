import { ISystemLog, SystemLog } from "../../models";
import { BaseRepository } from "../base.repository";

export class SystemLogRepository extends BaseRepository<ISystemLog> {
  constructor() {
    super(SystemLog);
  }
}

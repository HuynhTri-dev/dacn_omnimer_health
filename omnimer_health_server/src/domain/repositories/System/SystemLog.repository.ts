import { ISystemLog, SystemLog } from "../../models";
import { BaseRepository } from "../Base.repository";

export class SystemLogRepository extends BaseRepository<ISystemLog> {
  constructor() {
    super(SystemLog);
  }
}

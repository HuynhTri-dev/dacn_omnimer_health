import { DateTime } from "luxon";
import { DEFAULT_ZONE } from "../common/constants/AppConstants";

/**
 * DateUtils - Helper để làm việc với Date theo múi giờ local/UTC
 * Mặc định: VN
 */

class DateUtils {
  /**
   * Trả về khoảng thời gian UTC (start, end) ứng với ngày local
   * Mặc định Local là múi giờ VN (Asia/Ho_Chi_Minh) là UTC+7 thì sẽ chuyển start, end về UTC + 0
   * @param date Ngày local (mặc định: hôm nay)
   * @param timezone Múi giờ (default = "Asia/Ho_Chi_Minh")
   */
  static getUtcDayRange(
    date: string | Date = new Date(),
    timezone: string = DEFAULT_ZONE
  ) {
    // parse theo kiểu dữ liệu
    const dt =
      typeof date === "string"
        ? DateTime.fromISO(date, { zone: timezone })
        : DateTime.fromJSDate(date, { zone: timezone });

    if (!dt.isValid) {
      throw new Error(`Invalid date input: ${date}`);
    }

    // Bắt đầu/kết thúc ngày theo local
    const startLocal = dt.startOf("day");
    const endLocal = dt.endOf("day");

    // Chuyển về UTC
    return {
      start: startLocal.toUTC(),
      end: endLocal.toUTC(),
    };
  }

  /**
   * Trả về số ngày (số nguyên) giữa ngày attendance (theo zone local) và ngày hiện tại (theo zone local).
   * - attendanceDate: string ISO hoặc Date (lưu trong DB là UTC)
   * - zone: múi giờ để so sánh (mặc định Asia/Ho_Chi_Minh)
   */
  static daysSinceAttendance(
    attendanceDate: string | Date,
    zone = DEFAULT_ZONE
  ): number {
    // parse attendance as UTC (DB lưu UTC)
    const att =
      typeof attendanceDate === "string"
        ? DateTime.fromISO(attendanceDate, { zone: "utc" })
        : DateTime.fromJSDate(attendanceDate as Date, { zone: "utc" });

    // chuyển sang local zone, so sánh theo startOf('day') để so sánh theo calendar-day
    const attLocalDay = att.setZone(zone).startOf("day");
    const nowLocalDay = DateTime.now().setZone(zone).startOf("day");

    // kết quả là số ngày (>=0 nếu attendance không phải tương lai)
    return Math.floor(nowLocalDay.diff(attLocalDay, "days").days);
  }

  static isEditableByTeacher(
    attendanceDate: string | Date,
    allowedDays = 2,
    zone = DEFAULT_ZONE
  ): boolean {
    const days = this.daysSinceAttendance(attendanceDate, zone);
    return days >= 0 && days <= allowedDays;
  }
}

export default DateUtils;

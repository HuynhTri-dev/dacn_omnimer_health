import { Response } from "express";

/* ============================================================
 * SUCCESS RESPONSES
 * ============================================================
 */

/**
 * Gửi response thành công (mặc định status 200).
 *
 * @param res - Đối tượng Response từ Express
 * @param data - Dữ liệu trả về (object | array | null)
 * @param message - Thông điệp mô tả kết quả
 * @param statusCode - HTTP status code (default: 200)
 */
export const sendSuccess = (
  res: Response,
  data: any = null,
  message: string = "Success",
  statusCode: number = 200
) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
};

/**
 * Gửi response thành công khi tạo dữ liệu mới (status 201).
 *
 * @param res - Đối tượng Response
 * @param data - Dữ liệu mới được tạo
 * @param message - Thông điệp tùy chọn (default: "Tạo thành công")
 */
export const sendCreated = (
  res: Response,
  data: any = null,
  message: string = "Create Success"
) => {
  return sendSuccess(res, data, message, 201);
};

/**
 * Gửi response thành công nhưng không có nội dung (status 204).
 *
 * ⚠ Lưu ý: Theo chuẩn HTTP, 204 thường không trả body.
 * Tuy nhiên ở đây vẫn trả JSON để đồng bộ response format.
 *
 * @param res - Đối tượng Response
 * @param message - Thông điệp tùy chọn (default: "Không có dữ liệu")
 */
export const sendNoContent = (res: Response) => {
  return res.status(204);
};

/**
 * Gửi response cho trường hợp danh sách rỗng.
 *
 * @param res - Đối tượng Response
 * @param message - Thông điệp tùy chọn (default: "Danh sách trống")
 */
export const sendEmpty = (res: Response, message: string = "Empty") => {
  return sendSuccess(res, null, message);
};

/* ============================================================
 * ERROR RESPONSES
 * ============================================================
 */

/**
 * Gửi response thất bại chuẩn hóa.
 *
 * @param res - Đối tượng Response
 * @param message - Thông điệp lỗi hiển thị cho client
 * @param statusCode - HTTP status code (default: 500)
 * @param errorData - Chi tiết lỗi (dùng cho dev/debug)
 */
export const sendError = (
  res: Response,
  message: string = "Server fail",
  statusCode: number = 500,
  errorData?: any
) => {
  return res.status(statusCode).json({
    success: false,
    message,
    error: errorData ?? null,
  });
};

/**
 * Gửi response khi thiếu dữ liệu cần thiết (status 400)
 *
 * @param res - Đối tượng Response
 * @param message - Thông điệp tùy chọn (default: "Không tìm thấy")
 */
export const sendBadRequest = (
  res: Response,
  message: string = "Bad Request"
) => {
  return sendError(res, message, 400);
};

/**
 * Gửi response khi không tìm thấy dữ liệu (status 404).
 *
 * @param res - Đối tượng Response
 * @param message - Thông điệp tùy chọn (default: "Không tìm thấy")
 */
export const sendNotFound = (res: Response, message: string = "Not Found") => {
  return sendError(res, message, 404);
};

/**
 * Gửi response khi người dùng chưa đăng nhập (status 401).
 *
 * @param res - Đối tượng Response
 * @param message - Thông điệp tùy chọn (default: "Người dùng chưa đăng nhập")
 */
export const sendUnauthorized = (
  res: Response,
  message: string = "User is not login"
) => {
  return sendError(res, message, 401);
};

/**
 * Gửi response khi người dùng không có quyền truy cập (status 403).
 *
 * @param res - Đối tượng Response
 * @param message - Thông điệp tùy chọn (default: "Người dùng không có quyền truy cập")
 */
export const sendForbidden = (
  res: Response,
  message: string = "User does not have permission to access."
) => {
  return sendError(res, message, 403);
};

/* ============================================================
 * HELPER FUNCTIONS
 * ============================================================
 */

/**
 * Làm sạch message lỗi trả về từ Mongoose / Validation.
 *
 * @param err - Đối tượng lỗi
 * @returns Chuỗi thông báo lỗi đã được làm sạch
 */
export const cleanErrorMessage = (err: any): string => {
  if (!err) return "Server fail";

  let message = "";

  if (err instanceof Error) {
    message = err.message;
  } else if (typeof err === "string") {
    message = err;
  } else {
    return "Server fail";
  }

  // Các pattern thường gặp cần loại bỏ
  const patternsToRemove = [
    /^Validation failed:\s*/i, // Mongoose validation
    /^Error:\s*/i, // Prefix Error chung
    /^MongoError:\s*/i, // Mongo error
    /^Cast to \w+ failed.*$/i, // CastError của mongoose
    /^E11000 duplicate key error.*$/i, // Duplicate key
  ];

  for (const pattern of patternsToRemove) {
    message = message.replace(pattern, "");
  }

  // Nếu message rỗng hoặc quá chung chung thì fallback
  if (!message.trim()) {
    return "Server fail";
  }

  return message.trim();
};

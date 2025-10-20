import { Request, Response, NextFunction } from "express";
import chalk from "chalk";
import dotenv from "dotenv";
import { HttpError } from "../../utils/HttpError";
import { ZodError } from "zod";

dotenv.config();

const isDev = process.env.NODE_ENV === "development";

export const errorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  let status = 500;
  let message = "Lỗi hệ thống";
  let code: string | undefined;
  let details: any;

  // Xử lý từng loại lỗi riêng
  if (err instanceof HttpError) {
    status = err.status;
    message = err.message;
    code = err.code;
    details = err.details;
  } else if (err instanceof ZodError) {
    status = 400;
    message = "Dữ liệu không hợp lệ";
    details = err.issues.map((i) => ({
      field: i.path.join("."),
      message: i.message,
    }));
  } else if (err.name === "ValidationError") {
    // Ví dụ Mongoose error
    status = 400;
    message = "Lỗi xác thực dữ liệu";
    details = err.errors;
  } else if (err instanceof Error) {
    message = err.message;
  }

  // Ghi log ra console
  console.error(
    chalk.red(`[ERROR] ${req.method} ${req.originalUrl}`),
    chalk.yellow(`→ ${status} ${message}`),
    isDev ? chalk.gray(err.stack || err) : ""
  );

  // Phản hồi JSON
  res.status(status).json({
    success: false,
    status,
    message,
    ...(code && { code }),
    ...(details && { details }),
    ...(isDev && { stack: err.stack }),
  });
};

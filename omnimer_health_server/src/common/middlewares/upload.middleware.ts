import multer from "multer";
import { Request } from "express";
import { HttpError } from "../../utils/HttpError";

// =================== Multer Config ===================

// Cho phép file ảnh và video (jpeg, png, mp4, mov, webm,...)
const FILE_TYPES = {
  image: ["image/jpeg", "image/png", "image/jpg", "image/webp"],
  video: ["video/mp4", "video/mpeg", "video/quicktime", "video/webm"],
};

// Cấu hình lưu trữ: sử dụng memory để upload trực tiếp lên Cloudflare
const storage = multer.memoryStorage();

/**
 * Hàm kiểm tra loại file hợp lệ (theo field cần upload)
 * @param allowedTypes mảng các MIME type được phép
 */
function fileFilterBuilder(allowedTypes: string[]) {
  return (
    req: Request,
    file: Express.Multer.File,
    cb: multer.FileFilterCallback
  ) => {
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new HttpError(400, "File này không được phép"));
    }
  };
}

/**
 * Upload middleware cho ảnh
 * @param fieldName tên field trong form (vd: "image")
 */
export const uploadImage = (fieldName: string) =>
  multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
    fileFilter: fileFilterBuilder(FILE_TYPES.image),
  }).single(fieldName);

/**
 * Upload middleware cho video
 * @param fieldName tên field trong form (vd: "video")
 */
export const uploadVideo = (fieldName: string) =>
  multer({
    storage,
    limits: { fileSize: 50 * 1024 * 1024 }, // 50MB
    fileFilter: fileFilterBuilder(FILE_TYPES.video),
  }).single(fieldName);

/**
 * Upload nhiều ảnh (nếu cần)
 * @param fieldName tên field
 * @param maxCount số lượng tối đa
 */
export const uploadMultipleImages = (fieldName: string, maxCount = 5) =>
  multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: fileFilterBuilder(FILE_TYPES.image),
  }).array(fieldName, maxCount);

/**
 * Upload đồng thời 1 ảnh và 1 video
 * @param imageField tên field ảnh (vd: "image")
 * @param videoField tên field video (vd: "video")
 */
export const uploadImageAndVideo = (
  imageField: string = "image",
  videoField: string = "video"
) =>
  multer({
    storage,
    limits: { fileSize: 50 * 1024 * 1024 },
    fileFilter(req, file, cb) {
      const allowedTypes = [...FILE_TYPES.image, ...FILE_TYPES.video];
      if (allowedTypes.includes(file.mimetype)) {
        cb(null, true);
      } else {
        cb(new HttpError(400, "File này không được phép"));
      }
    },
  }).fields([
    { name: imageField, maxCount: 10 }, // cho phép tối đa 10 ảnh
    { name: videoField, maxCount: 1 },
  ]);

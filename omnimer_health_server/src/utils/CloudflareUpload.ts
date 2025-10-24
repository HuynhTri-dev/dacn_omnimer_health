import r2 from "../common/configs/cloudflareConfig";
import { DeleteObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";
import { HttpError } from "./HttpError";
import { logError } from "./LoggerUtil";
import { v4 as uuidv4 } from "uuid";

export function extractFileKey(urlOrKey: string): string {
  try {
    const parsedUrl = new URL(urlOrKey);
    return parsedUrl.pathname.startsWith("/")
      ? parsedUrl.pathname.slice(1)
      : parsedUrl.pathname;
  } catch {
    // Nếu là key sẵn (ví dụ "users/123.jpg") thì giữ nguyên
    return urlOrKey;
  }
}
export async function uploadToCloudflare(
  file: Express.Multer.File,
  folder: string,
  userId?: string
): Promise<string> {
  try {
    const fileKey = `${folder}/${uuidv4()}-${file.originalname}`;

    const command = new PutObjectCommand({
      Bucket: process.env.CLOUDFLARE_BUCKET_NAME,
      Key: fileKey,
      Body: file.buffer,
      ContentType: file.mimetype,
    });

    await r2.send(command);

    // Return public URL
    return `https://${process.env.CLOUDFLARE_ACCOUNT_ID}.r2.cloudflarestorage.com/${fileKey}`;
  } catch (err: any) {
    await logError({
      userId,
      action: "uploadToCloudflare",
      message: err.message || err,
      errorMessage: err.stack || err,
    });
    throw new HttpError(500, "Failed to upload file to Cloudflare R2");
  }
}

export async function updateCloudflareImage(
  file: Express.Multer.File,
  existingUrl: string, // URL cũ trên Cloudflare
  folder: string,
  userId?: string
): Promise<string> {
  try {
    if (!existingUrl) throw new HttpError(400, "Existing image URL required");

    // Lấy key từ URL
    const key = existingUrl.split(".com/")[1];

    // Kiểm tra folder
    if (!key.startsWith(folder)) {
      throw new HttpError(
        400,
        `Existing file key does not belong to folder "${folder}"`
      );
    }

    const command = new PutObjectCommand({
      Bucket: process.env.CLOUDFLARE_BUCKET_NAME,
      Key: key, // overwrite file cũ
      Body: file.buffer,
      ContentType: file.mimetype,
    });

    await r2.send(command);

    // URL cũ vẫn giữ nguyên
    return existingUrl;
  } catch (err: any) {
    await logError({
      userId,
      action: "updateCloudflareImage",
      message: err.message || err,
      errorMessage: err.stack || err,
    });
    throw new HttpError(500, "Failed to update image on Cloudflare R2");
  }
}

/**
 * Upload avatar mới cho user
 */
export async function uploadUserAvatar(
  file: Express.Multer.File,
  userId: string // người đang thao tác
): Promise<string> {
  try {
    const folder = "users";
    const fileKey = `${folder}/${userId}`;

    const command = new PutObjectCommand({
      Bucket: process.env.CLOUDFLARE_BUCKET_NAME,
      Key: fileKey,
      Body: file.buffer,
      ContentType: file.mimetype,
    });

    await r2.send(command);

    return `https://${process.env.CLOUDFLARE_ACCOUNT_ID}.r2.cloudflarestorage.com/${fileKey}`;
  } catch (err: any) {
    await logError({
      userId,
      action: "uploadUserAvatar",
      message: err.message || err,
      errorMessage: err.stack || err,
    });
    throw new HttpError(500, "Failed to upload avatar to Cloudflare R2");
  }
}

/**
 * Update avatar (overwrite file cũ)
 */
export async function updateUserAvatar(
  file: Express.Multer.File,
  existingUrl: string,
  userId: string // user đang thao tác
): Promise<string> {
  try {
    // Lấy key từ URL
    const key = existingUrl.split(".com/")[1];

    const parts = key.split("/"); // ['users', '12345']
    const uidFromUrl = parts[1];
    if (uidFromUrl !== userId) {
      throw new HttpError(403, "Bạn không có quyền chỉnh sửa avatar này");
    }

    const command = new PutObjectCommand({
      Bucket: process.env.CLOUDFLARE_BUCKET_NAME,
      Key: key, // overwrite
      Body: file.buffer,
      ContentType: file.mimetype,
    });

    await r2.send(command);

    return existingUrl; // URL giữ nguyên
  } catch (err: any) {
    await logError({
      userId: userId,
      action: "updateUserAvatar",
      message: err.message || err,
      errorMessage: err.stack || err,
    });
    throw new HttpError(500, "Failed to update avatar on Cloudflare R2");
  }
}

export async function deleteFileFromCloudflare(
  filePath: string,
  expectedFolder?: string
): Promise<void> {
  try {
    // Chuẩn hóa key
    const key = extractFileKey(filePath);

    // Kiểm tra folder nếu có yêu cầu
    if (expectedFolder && !key.startsWith(`${expectedFolder}/`)) {
      throw new HttpError(
        400,
        `Tệp cần xóa không nằm trong folder "${expectedFolder}"`
      );
    }

    const command = new DeleteObjectCommand({
      Bucket: process.env.CLOUDFLARE_BUCKET_NAME,
      Key: key,
    });

    await r2.send(command);
  } catch (err: any) {
    await logError({
      action: "deleteFileFromCloudflare",
      message: err.message || err,
      errorMessage: err.stack || err,
    });
    throw new HttpError(500, "Không thể xóa file khỏi Cloudflare");
  }
}

import admin from "firebase-admin";
import path from "path";
import dotenv from "dotenv";

dotenv.config();

/**
 * Khởi tạo Firebase Admin SDK.
 */
export const initializeFirebaseAdmin = (): void => {
  try {
    const firebaseAdmin = process.env.FIREBASE_ADMIN_SDK_JSON;

    if (!firebaseAdmin) {
      throw new Error("FIREBASE_ADMIN_SDK_JSON chưa được cấu hình.");
    }

    const serviceAccountPath = path.resolve(
      __dirname,
      firebaseAdmin || "serviceAccountKey.json"
    );

    const serviceAccount = require(serviceAccountPath);

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: process.env.FIREBASE_PROJECT_ID,
      storageBucket: process.env.STORAGE_BUCKET,
    });

    console.log("✅ Firebase Admin SDK đã khởi tạo.");
  } catch (error: any) {
    console.error("❌ Lỗi Firebase Admin:", error.message);
    process.exit(1);
  }
};

export default admin;

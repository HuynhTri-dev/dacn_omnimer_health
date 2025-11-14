import mongoose from "mongoose";
import dotenv from "dotenv";

dotenv.config();

/**
 * Kết nối MongoDB Atlas.
 */
export const connectMongoDB = async (): Promise<void> => {
  try {
    await mongoose.connect(process.env.MONGO_URI!);
    console.log("✅ MongoDB Atlas connected.");
  } catch (error) {
    console.error("❌ MongoDB connection error:", error);
    process.exit(1);
  }
};

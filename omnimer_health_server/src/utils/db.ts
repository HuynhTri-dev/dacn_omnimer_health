import mongoose from "mongoose";
import dotenv from "dotenv";
dotenv.config();

export const connectDB = async () => {
  if (!process.env.MONGO_URI) throw new Error("Missing MONGO_URI in .env");
  await mongoose.connect(process.env.MONGO_URI);
  console.log("✅ Connected to MongoDB");
};

export const disconnectDB = async () => {
  await mongoose.disconnect();
  console.log("🔌 Disconnected from MongoDB");
};

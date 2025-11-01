import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import morgan from "morgan";

import { connectMongoDB } from "./common/configs/mongoDBConfig";
//import { initializeFirebaseAdmin } from "./common/configs/firebase/firebaseAdminConfig";
import helmet from "helmet";

import route from "./domain/routes";
import { errorHandler } from "./common/middlewares/errorHandler.middleware";
import { loadRolePermissionsToCache } from "./redis/RoleCache";
import { connectRedis } from "./common/configs/redisConnect";
import { initializeFirebaseAdmin } from "./common/configs/firebaseAdminConfig";
import { setupSwagger } from "./common/configs/swagger";

dotenv.config();

const app = express();

// Middleware cơ bản
app.use(cors());
app.use(express.json());

// Ghi log theo format 'dev' (dành cho môi trường dev)
app.use(helmet());
app.use(morgan("dev"));

// Khi production thì  sẽ thêm một middleware giới hạn request tránh sập

// Mount routes
//Sẽ sử dụng site.route để quản lý tất cả các route của ứng dụng
route(app);

app.use(errorHandler);

// Kết nối DB + Firebase
const initializeApp = async () => {
  try {
    await connectMongoDB();
    await initializeFirebaseAdmin();

    const redisClient = await connectRedis(); // connect trước
    await loadRolePermissionsToCache(redisClient); // truyền client vào

    console.log("✅ All services initialized.");
  } catch (err) {
    console.error("❌ Initialization error:", err);
    process.exit(1);
  }
};

initializeApp();

setupSwagger(app);

export default app;

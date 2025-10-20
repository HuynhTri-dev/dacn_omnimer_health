import { createClient, RedisClientType } from "redis";
import dotenv from "dotenv";

dotenv.config();

let redisClient: RedisClientType | null = null;

/**
 * Kết nối Redis và trả về client
 */
export const connectRedis = async (): Promise<RedisClientType> => {
  if (redisClient && redisClient.isReady) {
    // Nếu đã kết nối rồi, trả về client hiện tại
    return redisClient;
  }

  const host = process.env.REDIS_HOST || "localhost";
  const port = process.env.REDIS_PORT ? parseInt(process.env.REDIS_PORT) : 6379;
  const username = process.env.REDIS_USERNAME;
  const password = process.env.REDIS_PASSWORD;

  redisClient = createClient({
    socket: { host, port },
    username, // optional, Redis Cloud
    password, // optional, Redis Cloud
  });

  redisClient.on("error", (err) => console.error("Redis Client Error", err));

  await redisClient.connect();
  console.log("Redis connected");

  return redisClient;
};

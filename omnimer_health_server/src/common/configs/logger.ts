import winston from "winston";
import "winston-mongodb";

const { combine, timestamp, printf, colorize, json } = winston.format;

const logFormat = printf(({ level, message, timestamp }) => {
  return `[${timestamp}] ${level}: ${message}`;
});

let transports: winston.transport[] = [];

if (process.env.NODE_ENV === "development") {
  // Dev: console + file
  transports = [
    new winston.transports.Console({ format: combine(colorize(), logFormat) }),
    new winston.transports.File({ filename: "logs/combined.log" }),
    new winston.transports.File({ filename: "logs/error.log", level: "error" }),
  ];
} else {
  const mongoUri = process.env.MONGO_URI;
  if (!mongoUri) {
    throw new Error("MONGO_URI is not defined in environment variables");
  }
  // Production: MongoDB
  transports = [
    new winston.transports.MongoDB({
      db: mongoUri,
      collection: "system_logs",
      level: "info", // lưu từ info trở lên
      options: { useUnifiedTopology: true },
      tryReconnect: true,
    }),
  ];
}

const logger = winston.createLogger({
  level: process.env.NODE_ENV === "development" ? "debug" : "info",
  format: combine(timestamp({ format: "YYYY-MM-DD HH:mm:ss" }), json()),
  transports,
});

export default logger;

import jwt, { SignOptions, Secret } from "jsonwebtoken";
import { StringValue } from "ms";

const ACCESS_TOKEN_SECRET: Secret =
  process.env.ACCESS_TOKEN_SECRET || "ACCESS_SECRET_DEV";
const REFRESH_TOKEN_SECRET: Secret =
  process.env.REFRESH_TOKEN_SECRET || "REFRESH_SECRET_DEV";

export const JwtUtils = {
  generateAccessToken(payload: any, expiresIn: StringValue | number = "1h") {
    const options: SignOptions = { expiresIn };
    return jwt.sign(payload, ACCESS_TOKEN_SECRET, options);
  },

  generateRefreshToken(payload: any, expiresIn: StringValue | number = "1y") {
    const options: SignOptions = { expiresIn };
    return jwt.sign(payload, REFRESH_TOKEN_SECRET, options);
  },

  verifyAccessToken(token: string) {
    return jwt.verify(token, ACCESS_TOKEN_SECRET);
  },

  verifyRefreshToken(token: string) {
    return jwt.verify(token, REFRESH_TOKEN_SECRET);
  },
};

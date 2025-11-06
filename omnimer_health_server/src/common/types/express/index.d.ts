import "express";
import { DecodePayload } from "../../../domain/entities/DecodePayload.entity";
import { IUser } from "../../../domain/models";
declare module "express" {
  export interface Request {
    user?: DecodePayload | IUser;
  }
}

import "express";
import { DecodePayload } from "../../../domain/entities/DecodePayload";
import { IUser } from "../../../domain/models";
declare module "express" {
  export interface Request {
    user?: DecodePayload | IUser;
  }
}
declare module '*.jpg' {
  import { ImageSourcePropType } from 'react-native';
  const content: ImageSourcePropType;
  export default content;
}
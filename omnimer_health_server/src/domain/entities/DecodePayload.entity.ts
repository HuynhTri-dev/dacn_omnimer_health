import { Types } from "mongoose";

export interface DecodePayload {
  uid: string;
  id: Types.ObjectId;
  roleIds: Types.ObjectId[];
}

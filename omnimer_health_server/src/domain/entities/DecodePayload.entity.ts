import { Types } from "mongoose";

export interface DecodePayload {
  id: Types.ObjectId;
  roleIds: Types.ObjectId[];
  isDataSharingAccepted: boolean;
}

import { BaseRepository } from "./Base.repository";
import { IUser } from "../models";
import { Model } from "mongoose";

export class UserRepository extends BaseRepository<IUser> {
  constructor(model: Model<IUser>) {
    super(model);
  }

  async findByUid(uid: string): Promise<IUser | null> {
    try {
      return this.model.findOne({ uid }).exec();
    } catch (e) {
      throw e;
    }
  }

  async findByEmail(email: string): Promise<IUser | null> {
    try {
      return this.model.findOne({ email }).exec();
    } catch (e) {
      throw e;
    }
  }
}

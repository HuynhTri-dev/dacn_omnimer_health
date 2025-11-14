import { BaseRepository } from "../Base.repository";
import { IUser } from "../../models";
import { Model, Types } from "mongoose";
import {
  IUserResponse,
  IUserWithPasswordHash,
  PaginationQueryOptions,
} from "../../entities";
import { ListUserResponse } from "../../entities";

export class UserRepository extends BaseRepository<IUser> {
  constructor(model: Model<IUser>) {
    super(model);
  }

  async getUserById(id: string): Promise<IUserResponse | null> {
    try {
      const user = await this.model
        .findById(id)
        .populate({
          path: "roleIds",
          select: "_id name",
        })
        .lean();

      if (!user) return null;

      const roles = Array.isArray(user.roleIds)
        ? (user.roleIds as unknown as { _id: Types.ObjectId; name: string }[])
        : [];

      const userResponse: IUserResponse = {
        fullname: user.fullname,
        email: user.email ?? null,
        imageUrl: user.imageUrl,
        gender: user.gender,
        birthday: user.birthday,
        roleName: roles.map((r) => r.name),
      };

      return userResponse;
    } catch (e) {
      throw e;
    }
  }

  async userByEmailWithPassword(
    email: string
  ): Promise<IUserWithPasswordHash | null> {
    try {
      const user = await this.model
        .findOne({ email })
        .populate({
          path: "roleIds",
          select: "_id name",
        })
        .lean();

      if (!user) return null;

      const roles = Array.isArray(user.roleIds)
        ? (user.roleIds as unknown as { _id: Types.ObjectId; name: string }[])
        : [];

      const userResponse: IUserResponse = {
        _id: user._id,
        fullname: user.fullname,
        email: user.email ?? null,
        imageUrl: user.imageUrl,
        gender: user.gender,
        birthday: user.birthday,
        roleName: roles.map((r) => r.name),
        roleIds: roles.map((r) => r._id),
      };

      if (!user.passwordHashed) {
        return null;
      }

      return {
        userResponse: userResponse,
        passwordHashed: user.passwordHashed,
      };
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

  async findAllUser(
    options?: PaginationQueryOptions
  ): Promise<ListUserResponse[]> {
    try {
      const page = options?.page ?? 1;
      const limit = options?.limit ?? 50;
      const skip = (page - 1) * limit;
      const sort = options?.sort ?? { _id: -1 };

      // Truy vấn và populate role
      const users = await this.model
        .find(options?.filter || {})
        .populate({
          path: "roleIds",
          select: "name",
        })
        .skip(skip)
        .limit(limit)
        .sort(sort)
        .lean()
        .exec();

      const result: ListUserResponse[] = users.map((user) => ({
        _id: user._id,
        fullname: user.fullname,
        email: user.email ?? null,
        birthday: user.birthday ?? null,
        gender: user.gender,
        imageUrl: user.imageUrl ?? undefined,
        roleNames: Array.isArray(user.roleIds)
          ? user.roleIds.map((r: any) => r.name)
          : [],
      }));

      return result;
    } catch (e) {
      throw e;
    }
  }
}

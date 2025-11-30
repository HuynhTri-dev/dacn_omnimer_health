import { BaseRepository } from "../base.repository";
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
        _id: user._id,
        fullname: user.fullname,
        email: user.email ?? null,
        imageUrl: user.imageUrl,
        gender: user.gender,
        birthday: user.birthday,
        roleName: roles.map((r) => r.name),
        isDataSharingAccepted: user.isDataSharingAccepted,
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
        isDataSharingAccepted: user.isDataSharingAccepted,
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

  /**
   * Lấy password hash của user theo ID
   * @param id - ID của user
   * @returns Promise<string | null> - Password hash hoặc null nếu không tìm thấy
   */
  async getPasswordHashById(id: string): Promise<string | null> {
    try {
      const user = await this.model
        .findById(id)
        .select("passwordHashed")
        .lean();
      return user?.passwordHashed ?? null;
    } catch (e) {
      throw e;
    }
  }

  /**
   * Cập nhật password của user
   * @param id - ID của user
   * @param newPasswordHash - Password hash mới
   * @returns Promise<boolean> - true nếu cập nhật thành công
   */
  async updatePassword(id: string, newPasswordHash: string): Promise<boolean> {
    try {
      const result = await this.model.findByIdAndUpdate(
        id,
        { passwordHashed: newPasswordHash },
        { new: true }
      );
      return !!result;
    } catch (e) {
      throw e;
    }
  }
  /**
   * 🔹 Count total users
   */
  async countUsers(): Promise<number> {
    return this.model.countDocuments();
  }

  /**
   * 🔹 Get user growth stats
   */
  async getUserGrowthStats(
    period: "daily" | "weekly" | "monthly"
  ): Promise<{ date: string; count: number }[]> {
    const dateFormat =
      period === "daily" ? "%Y-%m-%d" : period === "weekly" ? "%Y-%U" : "%Y-%m";

    return this.model.aggregate([
      {
        $group: {
          _id: { $dateToString: { format: dateFormat, date: "$createdAt" } },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
      { $project: { date: "$_id", count: 1, _id: 0 } },
    ]);
  }
}

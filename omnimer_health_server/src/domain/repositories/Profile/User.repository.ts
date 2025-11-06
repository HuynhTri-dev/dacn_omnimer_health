import { BaseRepository } from "../Base.repository";
import { IUser } from "../../models";
import { FilterQuery, Model } from "mongoose";
import { PaginationQueryOptions } from "../../entities";
import { ListUserResponse } from "../../entities";

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
          select: "name", // chỉ lấy field name
        })
        .skip(skip)
        .limit(limit)
        .sort(sort)
        .lean() // Chuyển về object JS thuần (không phải document Mongoose)
        .exec();

      // Chuyển dữ liệu sang kiểu ListUserResponse
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

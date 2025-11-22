import {
  Model,
  Types,
  FilterQuery,
  UpdateQuery,
  ClientSession,
} from "mongoose";
import { PaginationQueryOptions } from "../entities";
import {
  DEFAULT_LIMIT,
  DEFAULT_PAGE,
} from "../../common/constants/AppConstants";

/**
 * BaseRepository là class cơ sở để thao tác CRUD với Mongoose.
 * T có thể là bất kỳ interface nào đại diện cho dữ liệu (IClass, ISchool, IStudent, ...)
 */
export class BaseRepository<T> {
  protected readonly model: Model<T>;

  constructor(model: Model<T>) {
    this.model = model;
  }

  /**
   * Tìm tất cả bản ghi, có thể truyền query filter, phân trang, sort.
   * @param filter - điều kiện tìm kiếm (optional)
   * @param options - optional: limit, page, sort
   */
  async findAll(
    filter: FilterQuery<T> = {},
    options?: PaginationQueryOptions
  ): Promise<T[]> {
    try {
      const page = options?.page ?? DEFAULT_PAGE;
      const limit = options?.limit ?? DEFAULT_LIMIT;
      const skip = (page - 1) * limit;
      const sort = options?.sort ?? { _id: -1 };

      const finalFilter = {
        ...filter,
        ...(options?.filter || {}),
      };

      return this.model
        .find(finalFilter)
        .skip(skip)
        .limit(limit)
        .sort(sort)
        .exec();
    } catch (e) {
      throw e;
    }
  }

  /**
   * Tìm một bản ghi theo ID
   */
  async findById(id: string): Promise<T | null> {
    try {
      if (!Types.ObjectId.isValid(id)) return null;
      return this.model.findById(id).exec();
    } catch (e) {
      throw e;
    }
  }

  /**
   * Tìm một bản ghi duy nhất theo điều kiện
   */
  async findOne(filter: FilterQuery<T>): Promise<T | null> {
    try {
      return this.model.findOne(filter).exec();
    } catch (e) {
      throw e;
    }
  }

  /**
   * Tạo bản ghi mới
   */
  async create(data: Partial<T>): Promise<T> {
    try {
      const created = await this.model.create(data);
      return created.toObject();
    } catch (e) {
      throw e;
    }
  }

  async createWithSession(
    data: Partial<T>,
    session: ClientSession
  ): Promise<T> {
    try {
      const doc = new this.model(data);
      await doc.save({ session });
      return doc;
    } catch (e) {
      throw e;
    }
  }

  /**
   * Cập nhật một bản ghi theo ID
   */
  async update(id: string, data: UpdateQuery<T>): Promise<T | null> {
    try {
      if (!Types.ObjectId.isValid(id)) return null;
      return this.model.findByIdAndUpdate(id, data, { new: true }).exec();
    } catch (e) {
      throw e;
    }
  }

  /**
   * Xoá một bản ghi theo ID
   */
  async delete(id: string): Promise<boolean> {
    try {
      if (!Types.ObjectId.isValid(id)) return false;
      const result = await this.model.findByIdAndDelete(id).exec();
      return result !== null;
    } catch (e) {
      throw e;
    }
  }

  async deleteWithSession(
    id: string,
    session?: ClientSession
  ): Promise<boolean> {
    try {
      if (!Types.ObjectId.isValid(id)) return false;

      const result = await this.model.findByIdAndDelete(id, { session }).exec();

      return result !== null;
    } catch (e) {
      throw e;
    }
  }

  /**
   * Cập nhật một bản ghi theo ID (có hỗ trợ transaction session)
   */
  async updateWithSession(
    id: string,
    data: UpdateQuery<T>,
    session: ClientSession
  ): Promise<T | null> {
    try {
      if (!Types.ObjectId.isValid(id)) return null;
      return this.model
        .findByIdAndUpdate(id, data, { new: true, session })
        .exec();
    } catch (e) {
      throw e;
    }
  }
}

export function castArrayToObjectIds(value: any): Types.ObjectId[] {
  if (!value) return [];
  if (Array.isArray(value)) return value.map((v) => new Types.ObjectId(v));
  return [new Types.ObjectId(value)];
}

import { Model } from "mongoose";
import { IBodyPart } from "../../models";
import { BaseRepository } from "../base.repository";

export class BodyPartRepository extends BaseRepository<IBodyPart> {
  constructor(model: Model<IBodyPart>) {
    super(model);
  }
}

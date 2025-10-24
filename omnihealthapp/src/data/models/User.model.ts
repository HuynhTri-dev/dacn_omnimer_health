import { GenderEnum } from '@/app/enum/EnumConstants';

export interface IUser {
  id: string;
  uid: string;
  fullname: string;

  email?: string | null;
  birthday?: Date | null;
  gender?: GenderEnum;

  roleIds: string[];

  imageUrl?: string;
}

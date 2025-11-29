// Base API Response
export interface ApiResponse<T = any> {
  message: string;
  data: T;
}

// Base Error Response
export interface ErrorResponse {
  error: string;
  statusCode: number;
}

// Pagination Parameters
export interface PaginationParams {
  page?: number;
  limit?: number;
  sort?: string;
  order?: 'asc' | 'desc';
}

// Pagination Response
export interface PaginationResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

// User Entity
export interface User {
  _id: string;
  username: string;
  email: string;
  firstName: string;
  lastName: string;
  dateOfBirth?: Date;
  gender?: 'male' | 'female' | 'other';
  avatar?: string;
  roles: Role[];
  permissions: Permission[];
  createdAt: Date;
  updatedAt: Date;
}

// Role Entity
export interface Role {
  _id: string;
  name: string;
  description: string;
  permissions: Permission[];
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Permission Entity
export interface Permission {
  _id: string;
  name: string;
  description: string;
  resource: string;
  action: string;
  createdAt: Date;
  updatedAt: Date;
}

// Equipment Entity
export interface Equipment {
  _id: string;
  name: string;
  description: string;
  image?: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// BodyPart Entity
export interface BodyPart {
  _id: string;
  name: string;
  description: string;
  image?: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Muscle Entity
export interface Muscle {
  _id: string;
  name: string;
  description: string;
  image?: string;
  bodyPart: BodyPart;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Exercise Type Entity
export interface ExerciseType {
  _id: string;
  name: string;
  description: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Exercise Category Entity
export interface ExerciseCategory {
  _id: string;
  name: string;
  description: string;
  image?: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Exercise Entity
export interface Exercise {
  _id: string;
  name: string;
  description: string;
  instructions: string[];
  image?: string;
  video?: string;
  difficulty: 'easy' | 'medium' | 'hard' | 'very_hard';
  type: ExerciseType;
  category: ExerciseCategory;
  bodyParts: BodyPart[];
  muscles: Muscle[];
  equipment: Equipment[];
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Form Types
export interface UserFormValues {
  username: string;
  email: string;
  firstName: string;
  lastName: string;
  dateOfBirth?: string;
  gender?: 'male' | 'female' | 'other';
  password?: string;
  roles: string[];
}

export interface RoleFormValues {
  name: string;
  description: string;
  permissions: string[];
}

export interface PermissionFormValues {
  name: string;
  description: string;
  resource: string;
  action: string;
}

export interface EquipmentFormValues {
  name: string;
  description: string;
  image?: File;
}

export interface BodyPartFormValues {
  name: string;
  description: string;
  image?: File;
}

export interface MuscleFormValues {
  name: string;
  description: string;
  bodyPart: string;
  image?: File;
}

export interface ExerciseTypeFormValues {
  name: string;
  description: string;
}

export interface ExerciseCategoryFormValues {
  name: string;
  description: string;
  image?: File;
}

export interface ExerciseFormValues {
  name: string;
  description: string;
  instructions: string[];
  image?: File;
  video?: File;
  difficulty: 'easy' | 'medium' | 'hard' | 'very_hard';
  type: string;
  category: string;
  bodyParts: string[];
  muscles: string[];
  equipment: string[];
}

// Navigation Item Type
export interface NavigationItem {
  key: string;
  label: string;
  icon?: string;
  path: string;
  children?: NavigationItem[];
}

// Theme Colors
export interface ThemeColors {
  primary: string;
  secondary: string;
  background: string;
  surface: string;
  error: string;
  success: string;
  warning: string;
  info: string;
  danger: string;
  gray: {
    100: string;
    200: string;
    300: string;
    400: string;
    500: string;
    600: string;
    700: string;
    800: string;
    900: string;
  };
}
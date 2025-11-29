import type {
  Equipment,
  BodyPart,
  Muscle,
  ExerciseType,
  ExerciseCategory,
  Exercise,
  PaginationParams,
  PaginationResponse,
  ExerciseTypeFormValues,
} from "../../shared/types";

export interface IExerciseRepository {
  // Equipment
  getEquipment(
    params?: PaginationParams
  ): Promise<PaginationResponse<Equipment>>;
  getEquipmentById(id: string): Promise<Equipment>;
  createEquipment(equipmentData: FormData): Promise<Equipment>;
  updateEquipment(
    id: string,
    equipmentData: FormData | Partial<Equipment>
  ): Promise<Equipment>;
  deleteEquipment(id: string): Promise<void>;

  // Body Parts
  getBodyParts(
    params?: PaginationParams
  ): Promise<PaginationResponse<BodyPart>>;
  getBodyPartById(id: string): Promise<BodyPart>;
  createBodyPart(bodyPartData: FormData): Promise<BodyPart>;
  updateBodyPart(
    id: string,
    bodyPartData: FormData | Partial<BodyPart>
  ): Promise<BodyPart>;
  deleteBodyPart(id: string): Promise<void>;

  // Muscles
  getMuscles(params?: PaginationParams): Promise<PaginationResponse<Muscle>>;
  getMuscleById(id: string): Promise<Muscle>;
  createMuscle(muscleData: FormData): Promise<Muscle>;
  updateMuscle(
    id: string,
    muscleData: FormData | Partial<Muscle>
  ): Promise<Muscle>;
  deleteMuscle(id: string): Promise<void>;

  // Exercise Types
  getExerciseTypes(
    params?: PaginationParams
  ): Promise<PaginationResponse<ExerciseType>>;
  getExerciseTypeById(id: string): Promise<ExerciseType>;
  createExerciseType(typeData: ExerciseTypeFormValues): Promise<ExerciseType>;
  updateExerciseType(
    id: string,
    typeData: Partial<ExerciseType>
  ): Promise<ExerciseType>;
  deleteExerciseType(id: string): Promise<void>;

  // Exercise Categories
  getExerciseCategories(
    params?: PaginationParams
  ): Promise<PaginationResponse<ExerciseCategory>>;
  getExerciseCategoryById(id: string): Promise<ExerciseCategory>;
  createExerciseCategory(categoryData: FormData): Promise<ExerciseCategory>;
  updateExerciseCategory(
    id: string,
    categoryData: FormData | Partial<ExerciseCategory>
  ): Promise<ExerciseCategory>;
  deleteExerciseCategory(id: string): Promise<void>;

  // Exercises
  getExercises(
    params?: PaginationParams
  ): Promise<PaginationResponse<Exercise>>;
  getExerciseById(id: string): Promise<Exercise>;
  createExercise(exerciseData: FormData): Promise<Exercise>;
  updateExercise(
    id: string,
    exerciseData: FormData | Partial<Exercise>
  ): Promise<Exercise>;
  deleteExercise(id: string): Promise<void>;
}

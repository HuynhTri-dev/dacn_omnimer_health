import type { IExerciseRepository } from "../repositories/exercise.repository";
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

export class ExerciseUseCase {
  private exerciseRepository: IExerciseRepository;

  constructor(exerciseRepository: IExerciseRepository) {
    this.exerciseRepository = exerciseRepository;
  }

  // Equipment
  async getEquipment(
    params?: PaginationParams
  ): Promise<PaginationResponse<Equipment>> {
    return await this.exerciseRepository.getEquipment(params);
  }

  async getEquipmentById(id: string): Promise<Equipment> {
    return await this.exerciseRepository.getEquipmentById(id);
  }

  async createEquipment(equipmentData: FormData): Promise<Equipment> {
    return await this.exerciseRepository.createEquipment(equipmentData);
  }

  async updateEquipment(
    id: string,
    equipmentData: FormData | Partial<Equipment>
  ): Promise<Equipment> {
    return await this.exerciseRepository.updateEquipment(id, equipmentData);
  }

  async deleteEquipment(id: string): Promise<void> {
    await this.exerciseRepository.deleteEquipment(id);
  }

  // Body Parts
  async getBodyParts(
    params?: PaginationParams
  ): Promise<PaginationResponse<BodyPart>> {
    return await this.exerciseRepository.getBodyParts(params);
  }

  async getBodyPartById(id: string): Promise<BodyPart> {
    return await this.exerciseRepository.getBodyPartById(id);
  }

  async createBodyPart(bodyPartData: FormData): Promise<BodyPart> {
    return await this.exerciseRepository.createBodyPart(bodyPartData);
  }

  async updateBodyPart(
    id: string,
    bodyPartData: FormData | Partial<BodyPart>
  ): Promise<BodyPart> {
    return await this.exerciseRepository.updateBodyPart(id, bodyPartData);
  }

  async deleteBodyPart(id: string): Promise<void> {
    await this.exerciseRepository.deleteBodyPart(id);
  }

  // Muscles
  async getMuscles(
    params?: PaginationParams
  ): Promise<PaginationResponse<Muscle>> {
    return await this.exerciseRepository.getMuscles(params);
  }

  async getMuscleById(id: string): Promise<Muscle> {
    return await this.exerciseRepository.getMuscleById(id);
  }

  async createMuscle(muscleData: FormData): Promise<Muscle> {
    return await this.exerciseRepository.createMuscle(muscleData);
  }

  async updateMuscle(
    id: string,
    muscleData: FormData | Partial<Muscle>
  ): Promise<Muscle> {
    return await this.exerciseRepository.updateMuscle(id, muscleData);
  }

  async deleteMuscle(id: string): Promise<void> {
    await this.exerciseRepository.deleteMuscle(id);
  }

  // Exercise Types
  async getExerciseTypes(
    params?: PaginationParams
  ): Promise<PaginationResponse<ExerciseType>> {
    return await this.exerciseRepository.getExerciseTypes(params);
  }

  async getExerciseTypeById(id: string): Promise<ExerciseType> {
    return await this.exerciseRepository.getExerciseTypeById(id);
  }

  async createExerciseType(
    typeData: ExerciseTypeFormValues
  ): Promise<ExerciseType> {
    return await this.exerciseRepository.createExerciseType(typeData);
  }

  async updateExerciseType(
    id: string,
    typeData: Partial<ExerciseType>
  ): Promise<ExerciseType> {
    return await this.exerciseRepository.updateExerciseType(id, typeData);
  }

  async deleteExerciseType(id: string): Promise<void> {
    await this.exerciseRepository.deleteExerciseType(id);
  }

  // Exercise Categories
  async getExerciseCategories(
    params?: PaginationParams
  ): Promise<PaginationResponse<ExerciseCategory>> {
    return await this.exerciseRepository.getExerciseCategories(params);
  }

  async getExerciseCategoryById(id: string): Promise<ExerciseCategory> {
    return await this.exerciseRepository.getExerciseCategoryById(id);
  }

  async createExerciseCategory(
    categoryData: FormData
  ): Promise<ExerciseCategory> {
    return await this.exerciseRepository.createExerciseCategory(categoryData);
  }

  async updateExerciseCategory(
    id: string,
    categoryData: FormData | Partial<ExerciseCategory>
  ): Promise<ExerciseCategory> {
    return await this.exerciseRepository.updateExerciseCategory(
      id,
      categoryData
    );
  }

  async deleteExerciseCategory(id: string): Promise<void> {
    await this.exerciseRepository.deleteExerciseCategory(id);
  }

  // Exercises
  async getExercises(
    params?: PaginationParams
  ): Promise<PaginationResponse<Exercise>> {
    return await this.exerciseRepository.getExercises(params);
  }

  async getExerciseById(id: string): Promise<Exercise> {
    return await this.exerciseRepository.getExerciseById(id);
  }

  async createExercise(exerciseData: FormData): Promise<Exercise> {
    return await this.exerciseRepository.createExercise(exerciseData);
  }

  async updateExercise(
    id: string,
    exerciseData: FormData | Partial<Exercise>
  ): Promise<Exercise> {
    return await this.exerciseRepository.updateExercise(id, exerciseData);
  }

  async deleteExercise(id: string): Promise<void> {
    await this.exerciseRepository.deleteExercise(id);
  }
}

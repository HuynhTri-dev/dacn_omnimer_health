import type { IExerciseRepository } from "../../domain/repositories/exercise.repository";
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
import { apiClient } from "../services/authApi";

export class ExerciseRepositoryImpl implements IExerciseRepository {
  // Equipment
  async getEquipment(
    params?: PaginationParams
  ): Promise<PaginationResponse<Equipment>> {
    const response = await apiClient.get<Equipment[]>("/equipment", params);
    return {
      data: response.data.data,
      total: response.data.data.length,
      page: params?.page || 1,
      limit: params?.limit || 10,
      totalPages: Math.ceil(response.data.data.length / (params?.limit || 10)),
    };
  }

  async getEquipmentById(id: string): Promise<Equipment> {
    const response = await apiClient.get<Equipment>(`/equipment/${id}`);
    return response.data.data;
  }

  async createEquipment(equipmentData: FormData): Promise<Equipment> {
    const response = await apiClient.uploadFile<Equipment>(
      "/equipment/",
      equipmentData
    );
    return response.data.data;
  }

  async updateEquipment(
    id: string,
    equipmentData: FormData | Partial<Equipment>
  ): Promise<Equipment> {
    if (equipmentData instanceof FormData) {
      const response = await apiClient.uploadFile<Equipment>(
        `/equipment/${id}`,
        equipmentData
      );
      return response.data.data;
    } else {
      const response = await apiClient.put<Equipment>(
        `/equipment/${id}`,
        equipmentData
      );
      return response.data.data;
    }
  }

  async deleteEquipment(id: string): Promise<void> {
    await apiClient.delete(`/equipment/${id}`);
  }

  // Body Parts
  async getBodyParts(
    params?: PaginationParams
  ): Promise<PaginationResponse<BodyPart>> {
    const response = await apiClient.get<BodyPart[]>("/body-part/", params);
    return {
      data: response.data.data,
      total: response.data.data.length,
      page: params?.page || 1,
      limit: params?.limit || 10,
      totalPages: Math.ceil(response.data.data.length / (params?.limit || 10)),
    };
  }

  async getBodyPartById(id: string): Promise<BodyPart> {
    const response = await apiClient.get<BodyPart>(`/body-part/${id}`);
    return response.data.data;
  }

  async createBodyPart(bodyPartData: FormData): Promise<BodyPart> {
    const response = await apiClient.uploadFile<BodyPart>(
      "/body-part/",
      bodyPartData
    );
    return response.data.data;
  }

  async updateBodyPart(
    id: string,
    bodyPartData: FormData | Partial<BodyPart>
  ): Promise<BodyPart> {
    if (bodyPartData instanceof FormData) {
      const response = await apiClient.uploadFile<BodyPart>(
        `/body-part/${id}`,
        bodyPartData
      );
      return response.data.data;
    } else {
      const response = await apiClient.put<BodyPart>(
        `/body-part/${id}`,
        bodyPartData
      );
      return response.data.data;
    }
  }

  async deleteBodyPart(id: string): Promise<void> {
    await apiClient.delete(`/body-part/${id}`);
  }

  // Muscles
  async getMuscles(
    params?: PaginationParams
  ): Promise<PaginationResponse<Muscle>> {
    const response = await apiClient.get<Muscle[]>("/muscle/", params);
    return {
      data: response.data.data,
      total: response.data.data.length,
      page: params?.page || 1,
      limit: params?.limit || 10,
      totalPages: Math.ceil(response.data.data.length / (params?.limit || 10)),
    };
  }

  async getMuscleById(id: string): Promise<Muscle> {
    const response = await apiClient.get<Muscle>(`/muscle/${id}`);
    return response.data.data;
  }

  async createMuscle(muscleData: FormData): Promise<Muscle> {
    const response = await apiClient.uploadFile<Muscle>("/muscle/", muscleData);
    return response.data.data;
  }

  async updateMuscle(
    id: string,
    muscleData: FormData | Partial<Muscle>
  ): Promise<Muscle> {
    if (muscleData instanceof FormData) {
      const response = await apiClient.uploadFile<Muscle>(
        `/muscle/${id}`,
        muscleData
      );
      return response.data.data;
    } else {
      const response = await apiClient.put<Muscle>(`/muscle/${id}`, muscleData);
      return response.data.data;
    }
  }

  async deleteMuscle(id: string): Promise<void> {
    await apiClient.delete(`/muscle/${id}`);
  }

  // Exercise Types
  async getExerciseTypes(
    params?: PaginationParams
  ): Promise<PaginationResponse<ExerciseType>> {
    const response = await apiClient.get<ExerciseType[]>(
      "/exercise-type/",
      params
    );
    return {
      data: response.data.data,
      total: response.data.data.length,
      page: params?.page || 1,
      limit: params?.limit || 10,
      totalPages: Math.ceil(response.data.data.length / (params?.limit || 10)),
    };
  }

  async getExerciseTypeById(id: string): Promise<ExerciseType> {
    const response = await apiClient.get<ExerciseType>(`/exercise-type/${id}`);
    return response.data.data;
  }

  async createExerciseType(
    typeData: ExerciseTypeFormValues
  ): Promise<ExerciseType> {
    const response = await apiClient.post<ExerciseType>(
      "/exercise-type/",
      typeData
    );
    return response.data.data;
  }

  async updateExerciseType(
    id: string,
    typeData: Partial<ExerciseType>
  ): Promise<ExerciseType> {
    const response = await apiClient.put<ExerciseType>(
      `/exercise-type/${id}`,
      typeData
    );
    return response.data.data;
  }

  async deleteExerciseType(id: string): Promise<void> {
    await apiClient.delete(`/exercise-type/${id}`);
  }

  // Exercise Categories
  async getExerciseCategories(
    params?: PaginationParams
  ): Promise<PaginationResponse<ExerciseCategory>> {
    const response = await apiClient.get<ExerciseCategory[]>(
      "/exercise-category/",
      params
    );
    return {
      data: response.data.data,
      total: response.data.data.length,
      page: params?.page || 1,
      limit: params?.limit || 10,
      totalPages: Math.ceil(response.data.data.length / (params?.limit || 10)),
    };
  }

  async getExerciseCategoryById(id: string): Promise<ExerciseCategory> {
    const response = await apiClient.get<ExerciseCategory>(
      `/exercise-category/${id}`
    );
    return response.data.data;
  }

  async createExerciseCategory(
    categoryData: FormData
  ): Promise<ExerciseCategory> {
    const response = await apiClient.uploadFile<ExerciseCategory>(
      "/exercise-category/",
      categoryData
    );
    return response.data.data;
  }

  async updateExerciseCategory(
    id: string,
    categoryData: FormData | Partial<ExerciseCategory>
  ): Promise<ExerciseCategory> {
    if (categoryData instanceof FormData) {
      const response = await apiClient.uploadFile<ExerciseCategory>(
        `/exercise-category/${id}`,
        categoryData
      );
      return response.data.data;
    } else {
      const response = await apiClient.put<ExerciseCategory>(
        `/exercise-category/${id}`,
        categoryData
      );
      return response.data.data;
    }
  }

  async deleteExerciseCategory(id: string): Promise<void> {
    await apiClient.delete(`/exercise-category/${id}`);
  }

  // Exercises
  async getExercises(
    params?: PaginationParams
  ): Promise<PaginationResponse<Exercise>> {
    const response = await apiClient.get<Exercise[]>("/exercise/", params);
    return {
      data: response.data.data,
      total: response.data.data.length,
      page: params?.page || 1,
      limit: params?.limit || 10,
      totalPages: Math.ceil(response.data.data.length / (params?.limit || 10)),
    };
  }

  async getExerciseById(id: string): Promise<Exercise> {
    const response = await apiClient.get<Exercise>(`/exercise/${id}`);
    return response.data.data;
  }

  async createExercise(exerciseData: FormData): Promise<Exercise> {
    const response = await apiClient.uploadFile<Exercise>(
      "/exercise/",
      exerciseData
    );
    return response.data.data;
  }

  async updateExercise(
    id: string,
    exerciseData: FormData | Partial<Exercise>
  ): Promise<Exercise> {
    if (exerciseData instanceof FormData) {
      const response = await apiClient.uploadFile<Exercise>(
        `/exercise/${id}`,
        exerciseData
      );
      return response.data.data;
    } else {
      const response = await apiClient.put<Exercise>(
        `/exercise/${id}`,
        exerciseData
      );
      return response.data.data;
    }
  }

  async deleteExercise(id: string): Promise<void> {
    await apiClient.delete(`/exercise/${id}`);
  }
}

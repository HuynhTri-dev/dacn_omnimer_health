import axios from "axios";
import {
  IRAGAIResponse,
  IRAGUserContext,
} from "../entities/RecommendAI.entity";

export class AIService {
  private readonly aiServerUrl: string;

  constructor(aiServerUrl: string) {
    this.aiServerUrl = aiServerUrl;
  }

  async recommendExercises(context: IRAGUserContext): Promise<IRAGAIResponse> {
    try {
      const response = await axios.post<IRAGAIResponse>(
        `${this.aiServerUrl}/v4/recommend`,
        context
      );
      return response.data;
    } catch (error) {
      console.error("Error calling AI Server:", error);
      throw error;
    }
  }
}

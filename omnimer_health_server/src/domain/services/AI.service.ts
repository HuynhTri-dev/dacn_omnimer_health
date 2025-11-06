// src/services/RAGAIService.ts
import axios from "axios";
import { IRAGAIResponse, IRAGUserContext } from "../entities";

export class AIService {
  private readonly apiUrl: string;

  constructor(apiUrl: string) {
    this.apiUrl = apiUrl;
  }

  /**
   * Send user context + request to FastAPI RAG model and get exercise recommendation
   */
  async recommendExercises(context: IRAGUserContext): Promise<IRAGAIResponse> {
    try {
      const payload = {
        context,
      };

      const { data } = await axios.post<IRAGAIResponse>(this.apiUrl, payload);
      return data;
    } catch (err) {
      throw err;
    }
  }
}

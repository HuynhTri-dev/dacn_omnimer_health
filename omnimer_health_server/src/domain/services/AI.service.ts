// src/services/RAGAIService.ts
import axios from "axios";
import { IRAGAIResponse, IRAGUserContext } from "../entities";
import { normalizeUserContext } from "../../utils/normalizeRAGContext";

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
      const profile = normalizeUserContext(context);

      const payload = {
        profile,
        top_k: 5,
      };

      console.log("Payload sent to AI:", JSON.stringify(profile, null, 2));

      const { data } = await axios.post<IRAGAIResponse>(
        `${this.apiUrl}/recommend`,
        payload
      );

      console.log("Recommend Data Backend AI Service: ", { data });
      return data;
    } catch (err) {
      console.log(err);
      throw err;
    }
  }
}

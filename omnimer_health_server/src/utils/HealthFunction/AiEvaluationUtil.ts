import axios from "axios";
import { RiskLevelEnum } from "../../common/constants/EnumConstants";

/**
 * Loại bỏ Markdown code block và text dư trước khi JSON.parse
 */
function parseJsonSafe(str: string): any {
  try {
    let cleaned = str.trim();

    // Loại bỏ ```json hoặc ``` ở đầu và cuối
    cleaned = cleaned.replace(/^```json\s*/i, "").replace(/^```\s*/, "");
    cleaned = cleaned.replace(/```$/, "");

    // Thử parse
    return JSON.parse(cleaned);
  } catch (err) {
    console.error("Failed to parse AI JSON:", err, "Input:", str);
    return null;
  }
}

/**
 * Gọi AI Ollama (gpt-oss:120b-cloud) để đánh giá hồ sơ sức khỏe
 */
export async function callOllamaEvaluation(profileData: any) {
  try {
    const ollamaUrl =
      process.env.OLLAMA_BASE_URL || "http://host.docker.internal:11434";
    const response = await axios.post(`${ollamaUrl}/api/generate`, {
      model: "gpt-oss:120b-cloud",
      prompt: `
      Analyze the following health profile and provide a structured JSON response.
      Input data:
      ${JSON.stringify(profileData, null, 2)}

      Respond with a JSON object like:
      {
        "summary": "<health overview> in Vietnamese",
        "score": <0-100>,
        "riskLevel": "Low|Medium|High"
      }`,
      stream: false,
    });

    const text = response.data.response;

    // Dùng helper để parse an toàn
    const parsed = parseJsonSafe(text);

    if (!parsed) {
      throw new Error("Failed to parse AI JSON response");
    }

    return {
      summary: parsed.summary || "No summary",
      score: parsed.score ?? null,
      riskLevel: (parsed.riskLevel as RiskLevelEnum) ?? RiskLevelEnum.Unknown,
      updatedAt: new Date(),
      modelVersion: "gpt-oss:120b-cloud",
    };
  } catch (error) {
    console.error("AI Evaluation error:", error);
    return {
      summary: "AI evaluation failed.",
      score: null,
      riskLevel: RiskLevelEnum.Unknown,
      updatedAt: new Date(),
      modelVersion: "gpt-oss:120b-cloud",
    };
  }
}

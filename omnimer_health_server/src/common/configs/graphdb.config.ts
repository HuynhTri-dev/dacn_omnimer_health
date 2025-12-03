import dotenv from "dotenv";
import axios from "axios";

dotenv.config();

export const graphDBConfig = {
  baseUrl: process.env.GRAPHDB_URL || "http://localhost:7200",
  repoName: process.env.GRAPHDB_REPO || "omnimer_health_lod",
};

/**
 * Kiểm tra kết nối đến GraphDB.
 */
export const connectGraphDB = async (): Promise<void> => {
  try {
    // Kiểm tra repository có tồn tại không bằng cách lấy size
    const url = `${graphDBConfig.baseUrl}/repositories/${graphDBConfig.repoName}/size`;
    await axios.get(url);
    console.log(
      `✅ GraphDB connected to repository: ${graphDBConfig.repoName}`
    );
  } catch (error) {
    console.error("❌ GraphDB connection error:", error);
    // Không exit process để tránh sập app nếu GraphDB chưa bật, nhưng log lỗi rõ ràng
  }
};

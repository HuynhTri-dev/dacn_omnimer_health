import axios from "axios";

import { graphDBConfig } from "../../../common/configs/graphdb.config";

export class GraphDBService {
  private readonly baseUrl: string;
  private readonly repoName: string;

  constructor() {
    this.baseUrl = graphDBConfig.baseUrl;
    this.repoName = graphDBConfig.repoName;
  }

  // Hàm gửi SPARQL UPDATE để lưu dữ liệu
  async insertData(turtleData: string): Promise<void> {
    // Tách các dòng @prefix và chuyển đổi sang định dạng SPARQL PREFIX
    const lines = turtleData.split("\n");
    const prefixes: string[] = [];
    const triples: string[] = [];

    lines.forEach((line) => {
      const trimmed = line.trim();
      if (trimmed.startsWith("@prefix")) {
        // Chuyển đổi: @prefix ns: <url> .  ->  PREFIX ns: <url>
        const sparqlPrefix = trimmed
          .replace(/^@prefix/, "PREFIX")
          .replace(/\.\s*$/, "");
        prefixes.push(sparqlPrefix);
      } else if (trimmed && !trimmed.startsWith("#")) {
        // Chỉ thêm các dòng không rỗng và không phải comment
        triples.push(line);
      }
    });

    // Xây dựng SPARQL UPDATE query
    const prefixSection = prefixes.length > 0 ? prefixes.join("\n") : "";
    const tripleSection = triples.length > 0 ? triples.join("\n") : "";

    const sparqlUpdate = `
      ${prefixSection}
      INSERT DATA {
        ${tripleSection}
      }
    `;

    try {
      await axios.post(
        `${this.baseUrl}/repositories/${this.repoName}/statements`,
        sparqlUpdate,
        {
          headers: {
            "Content-Type": "application/sparql-update",
          },
        }
      );
      console.log("✅ Data pushed to GraphDB successfully");
    } catch (error) {
      console.error("❌ Failed to push to GraphDB:", error);
    }
  }
  async deleteUserData(userId: string): Promise<void> {
    const userUri = `http://omnimer.health/data/user_${userId}`;

    const sparqlUpdate = `
      PREFIX : <http://omnimer.health/data/>
      PREFIX sosa: <http://www.w3.org/ns/sosa/>
      PREFIX schema: <http://schema.org/>
      PREFIX fhir: <http://hl7.org/fhir/>

      DELETE {
        ?s ?p ?o .
      }
      WHERE {
        {
          BIND(<${userUri}> AS ?s)
          ?s ?p ?o .
        }
        UNION
        {
          ?s sosa:hasFeatureOfInterest <${userUri}> .
          ?s ?p ?o .
        }
        UNION
        {
          ?s schema:agent <${userUri}> .
          ?s ?p ?o .
        }
      }
    `;

    try {
      await axios.post(
        `${this.baseUrl}/repositories/${this.repoName}/statements`,
        sparqlUpdate,
        {
          headers: {
            "Content-Type": "application/sparql-update",
          },
        }
      );
      console.log(
        `✅ Data for user ${userId} deleted from GraphDB successfully`
      );
    } catch (error) {
      console.error(
        `❌ Failed to delete data for user ${userId} from GraphDB:`,
        error
      );
    }
  }
  async updateUserData(userId: string, turtleData: string): Promise<void> {
    console.log(`🔄 Updating data for user ${userId}...`);
    try {
      // Xóa dữ liệu cũ trước
      await this.deleteUserData(userId);
      // Thêm dữ liệu mới
      await this.insertData(turtleData);
      console.log(`✅ Data for user ${userId} updated successfully`);
    } catch (error) {
      console.error(
        `❌ Failed to update data for user ${userId} in GraphDB:`,
        error
      );
    }
  }

  async deleteGoalData(goalId: string): Promise<void> {
    const goalUri = `http://omnimer.health/data/gl_${goalId}`;

    const sparqlUpdate = `
      DELETE {
        ?s ?p ?o .
      }
      WHERE {
        BIND(<${goalUri}> AS ?s)
        ?s ?p ?o .
      }
    `;

    try {
      await axios.post(
        `${this.baseUrl}/repositories/${this.repoName}/statements`,
        sparqlUpdate,
        {
          headers: {
            "Content-Type": "application/sparql-update",
          },
        }
      );
      console.log(
        `✅ Data for goal ${goalId} deleted from GraphDB successfully`
      );
    } catch (error) {
      console.error(
        `❌ Failed to delete data for goal ${goalId} from GraphDB:`,
        error
      );
    }
  }

  async deleteHealthProfileData(healthProfileId: string): Promise<void> {
    const hpUri = `http://omnimer.health/data/hp_${healthProfileId}`;

    const sparqlUpdate = `
      DELETE {
        ?s ?p ?o .
      }
      WHERE {
        BIND(<${hpUri}> AS ?s)
        ?s ?p ?o .
      }
    `;

    try {
      await axios.post(
        `${this.baseUrl}/repositories/${this.repoName}/statements`,
        sparqlUpdate,
        {
          headers: {
            "Content-Type": "application/sparql-update",
          },
        }
      );
      console.log(
        `✅ Data for health profile ${healthProfileId} deleted from GraphDB successfully`
      );
    } catch (error) {
      console.error(
        `❌ Failed to delete data for health profile ${healthProfileId} from GraphDB:`,
        error
      );
    }
  }

  async deleteWorkoutData(workoutId: string): Promise<void> {
    const wkUri = `http://omnimer.health/data/wk_${workoutId}`;

    const sparqlUpdate = `
      DELETE {
        ?s ?p ?o .
      }
      WHERE {
        BIND(<${wkUri}> AS ?s)
        ?s ?p ?o .
      }
    `;

    try {
      await axios.post(
        `${this.baseUrl}/repositories/${this.repoName}/statements`,
        sparqlUpdate,
        {
          headers: {
            "Content-Type": "application/sparql-update",
          },
        }
      );
      console.log(
        `✅ Data for workout ${workoutId} deleted from GraphDB successfully`
      );
    } catch (error) {
      console.error(
        `❌ Failed to delete data for workout ${workoutId} from GraphDB:`,
        error
      );
    }
  }
}

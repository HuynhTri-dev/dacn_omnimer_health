import axios from "axios";
import { Writer } from "n3";

export class GraphDBService {
  private readonly baseUrl: string;
  private readonly repoName: string;

  constructor() {
    this.baseUrl = process.env.GRAPHDB_URL || "http://localhost:7200";
    this.repoName = process.env.GRAPHDB_REPO || "omnimer_health";

    if (!process.env.GRAPHDB_URL) {
      console.warn(
        "⚠️ GRAPHDB_URL not set, using default: http://localhost:7200"
      );
    }
    if (!process.env.GRAPHDB_REPO) {
      console.warn("⚠️ GRAPHDB_REPO not set, using default: omnimer_health");
    }
  }

  // Hàm gửi SPARQL UPDATE để lưu dữ liệu
  async insertData(turtleData: string): Promise<void> {
    const sparqlUpdate = `
      INSERT DATA {
        ${turtleData}
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

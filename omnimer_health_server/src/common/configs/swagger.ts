import swaggerJsdoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-express";
import { Express } from "express";
import dotenv from "dotenv";
dotenv.config();

const PORT: number = parseInt(process.env.PORT || "5000", 10);

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "OmniMer Health API",
      version: "1.0.0",
      description: "API documentation for OmniMer Health system",
    },
    servers: [
      { url: `http://localhost:${PORT}/api`, description: "Local server" },
      { url: "https://api.omnimer-health.com/api", description: "Production" },
    ],
  },
  // Nơi swagger-jsdoc sẽ tìm các comment
  apis: ["./src/domain/routes/*.ts", "./src/domain/controllers/**/*.ts"],
};

const swaggerSpec = swaggerJsdoc(options);

// Hàm setup cho Express app
export function setupSwagger(app: Express) {
  app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));
}

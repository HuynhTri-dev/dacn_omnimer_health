import { Express } from "express";
import permissionRoute from "./permission.route";
import roleRoute from "./role.route";
import authRoute from "./auth.route";
import bodyPartRoute from "./bodyPart.route";
import equipmentRoute from "./equipment.route";
import exerciseTypeRoute from "./exercise-type.route";
import muscleRoute from "./muscle.route";

function setupRoutes(app: Express) {
  app.use("/api/v1/permission", permissionRoute);
  app.use("/api/v1/role", roleRoute);
  app.use("/api/v1/auth", authRoute);
  app.use("/api/v1/body-part", bodyPartRoute);
  app.use("/api/v1/equipment", equipmentRoute);
  app.use("/api/v1/exercise-type", exerciseTypeRoute);
  app.use("/api/v1/muscle", muscleRoute);
}
export default setupRoutes;

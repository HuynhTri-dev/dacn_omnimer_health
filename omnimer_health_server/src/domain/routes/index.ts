import { Express } from "express";
import permissionRoute from "./permission.route";
import roleRoute from "./role.route";
import userRoute from "./user.route";

function setupRoutes(app: Express) {
  app.use("/api/v1/permission", permissionRoute);
  app.use("/api/v1/role", roleRoute);
  app.use("/api/v1/user", userRoute);
}
export default setupRoutes;

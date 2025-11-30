import { Express } from "express";
import permissionRoute from "./permission.route";
import roleRoute from "./role.route";
import authRoute from "./auth.route";
import verificationRoute from "./verification.route";
import forgotPasswordRoute from "./forgot-password.route";
import bodyPartRoute from "./body-part.route";
import equipmentRoute from "./equipment.route";
import exerciseTypeRoute from "./exercise-type.route";
import muscleRoute from "./muscle.route";
import exerciseCategoryRoute from "./exercise-category.route";
import exerciseRatingRoute from "./exercise-rating.route";
import exerciseRoute from "./exercise.route";
import userRoute from "./user.route";
import healthProfileRoute from "./health-profile.route";
import goalRoute from "./goal.route";
import workoutTemplateRoute from "./workout-template.route";
import workoutRoute from "./workout.route";
import workoutFeedbackRoute from "./workout-feedback.route";
import watchLogRoute from "./watch-log.route";
import AIRoute from "./ai.route";
import chartRoute from "./chart.route";
import adminChartRoute from "./admin-chart.route";

function setupRoutes(app: Express) {
  // System
  app.use("/api/v1/permission", permissionRoute);
  app.use("/api/v1/role", roleRoute);
  // Profile
  app.use("/api/v1/auth", authRoute);
  app.use("/api/v1/verification", verificationRoute);
  app.use("/api/v1/forgot-password", forgotPasswordRoute);
  app.use("/api/v1/user", userRoute);
  app.use("/api/v1/health-profile", healthProfileRoute);
  app.use("/api/v1/goal", goalRoute);
  // Exercise
  app.use("/api/v1/body-part", bodyPartRoute);
  app.use("/api/v1/equipment", equipmentRoute);
  app.use("/api/v1/exercise-type", exerciseTypeRoute);
  app.use("/api/v1/muscle", muscleRoute);
  app.use("/api/v1/exercise-category", exerciseCategoryRoute);
  app.use("/api/v1/exercise-rating", exerciseRatingRoute);
  app.use("/api/v1/exercise", exerciseRoute);
  // Workout
  app.use("/api/v1/workout-template", workoutTemplateRoute);
  app.use("/api/v1/workout", workoutRoute);
  app.use("/api/v1/workout-feedback", workoutFeedbackRoute);
  // Deices
  app.use("/api/v1/watch-log", watchLogRoute);
  // AI
  app.use("/api/v1/ai", AIRoute);
  // Charts
  app.use("/api/v1/chart", chartRoute);
  // Admin Charts
  app.use("/api/v1/admin-chart", adminChartRoute);
}
export default setupRoutes;

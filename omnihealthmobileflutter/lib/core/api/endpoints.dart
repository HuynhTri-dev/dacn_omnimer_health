import 'app_config.dart';

class Endpoints {
  static String get baseUrl => AppConfig.baseUrl;

  // ================== AUTH ==================
  static const String getAuth = "/v1/auth";
  static const String login = "/v1/auth/login";
  static const String register = "/v1/auth/register";
  static const String createNewAccessToken = "/v1/auth/new-access-token";

  // ================== USER ==================
  static const String getUsers = "/v1/user";
  static String updateUser(String id) => "/v1/user/$id";

  // ================== PERMISSION ==================
  static const String getPermissions = "/v1/permission";
  static const String createPermission = "/v1/permission";
  static String getPermissionById(String id) => "/v1/permission/$id";
  static String updatePermission(String id) => "/v1/permission/$id";
  static String deletePermission(String id) => "/v1/permission/$id";

  // ================== ROLE ==================
  static const String getRoles = "/v1/role";
  static const String getRoleWithoutAdmin = "/v1/role/without-admin";
  static const String createRole = "/v1/role";
  static String getRoleById(String id) => "/v1/role/$id";
  static String updateRole(String id) => "/v1/role/$id";
  static String updateRolePermissions(String id) => "/v1/role/$id";
  static String deleteRole(String id) => "/v1/role/$id";

  // ================== HEALTH PROFILE ==================
  static const String getHealthProfiles = "/v1/health-profile";
  static const String createHealthProfile = "/v1/health-profile";
  static const String getLatestHealthProfile = "/v1/health-profile/latest"; // Get the latest profile
  static String getHealthProfilesByUserId(String userId) =>
      "/v1/health-profile/user/$userId";
  static String getHealthProfileById(String id) => "/v1/health-profile/$id";
  static String updateHealthProfile(String id) => "/v1/health-profile/$id";
  static String deleteHealthProfile(String id) => "/v1/health-profile/$id";

  // ================== GOAL ==================
  static const String getGoals = "/v1/goal";
  static const String createGoal = "/v1/goal";
  static String getGoalById(String id) => "/v1/goal/$id";
  static String updateGoal(String id) => "/v1/goal/$id";
  static String deleteGoal(String id) => "/v1/goal/$id";

  // ================== BODY PART ==================
  static const String getBodyParts = "/v1/body-part";
  static const String createBodyPart = "/v1/body-part";
  static String updateBodyPart(String id) => "/v1/body-part/$id";
  static String deleteBodyPart(String id) => "/v1/body-part/$id";

  // ================== EQUIPMENT ==================
  static const String getEquipments = "/v1/equipment";
  static const String createEquipment = "/v1/equipment";
  static String updateEquipment(String id) => "/v1/equipment/$id";
  static String deleteEquipment(String id) => "/v1/equipment/$id";

  // ================== MUSCLE ==================
  static const String getMuscles = "/v1/muscle";
  static const String createMuscle = "/v1/muscle";
  static String getMuscleById(String id) => "/v1/muscle/$id";
  static String updateMuscle(String id) => "/v1/muscle/$id";
  static String deleteMuscle(String id) => "/v1/muscle/$id";

  // ================== EXERCISE TYPE ==================
  static const String getExerciseTypes = "/v1/exercise-type";
  static const String createExerciseType = "/v1/exercise-type";
  static String getExerciseTypeById(String id) => "/v1/exercise-type/$id";
  static String updateExerciseType(String id) => "/v1/exercise-type/$id";
  static String deleteExerciseType(String id) => "/v1/exercise-type/$id";

  // ================== EXERCISE CATEGORY ==================
  static const String getExerciseCategories = "/v1/exercise-category";
  static const String createExerciseCategory = "/v1/exercise-category";
  static String getExerciseCategoryById(String id) =>
      "/v1/exercise-category/$id";
  static String updateExerciseCategory(String id) =>
      "/v1/exercise-category/$id";
  static String deleteExerciseCategory(String id) =>
      "/v1/exercise-category/$id";

  // ================== EXERCISE ==================
  static const String exercises = "/v1/exercise";
  static const String createExercise = "/v1/exercise";
  static String getExerciseById(String id) => "/v1/exercise/$id";
  static String updateExercise(String id) => "/v1/exercise/$id";
  static String deleteExercise(String id) => "/v1/exercise/$id";

  // ================== EXERCISE RATING ==================
  static const String getExerciseRatings = "/v1/exercise-rating";
  static const String createExerciseRating = "/v1/exercise-rating";
  static String getExerciseRatingById(String id) => "/v1/exercise-rating/$id";
  static String updateExerciseRating(String id) => "/v1/exercise-rating/$id";
  static String deleteExerciseRating(String id) => "/v1/exercise-rating/$id";

  // ================== WORKOUT TEMPLATE ==================
  static const String getWorkoutTemplates = "/v1/workout-template";
  static const String createWorkoutTemplate = "/v1/workout-template";
  static const String getUserWorkoutTemplates = "/v1/workout-template/user";
  static String getWorkoutTemplateById(String id) => "/v1/workout-template/$id";
  static String updateWorkoutTemplate(String id) => "/v1/workout-template/$id";
  static String deleteWorkoutTemplate(String id) => "/v1/workout-template/$id";

  // ================== WORKOUT ==================
  static const String getWorkouts = "/v1/workout";
  static const String createWorkout = "/v1/workout";
  static const String getUserWorkouts = "/v1/workout/user";
  static String createWorkoutFromTemplate(String templateId) =>
      "/v1/workout/template/$templateId";
  static String getWorkoutById(String id) => "/v1/workout/$id";
  static String updateWorkout(String id) => "/v1/workout/$id";
  static String startWorkout(String id) => "/v1/workout/$id/start";
  static String completeWorkoutSet(String id) => "/v1/workout/$id/complete-set";
  static String completeWorkoutExercise(String id) =>
      "/v1/workout/$id/complete-exercise";
  static String finishWorkout(String id) => "/v1/workout/$id/finish";
  static String deleteWorkout(String id) => "/v1/workout/$id";

  // ================== WORKOUT FEEDBACK ==================
  static const String getWorkoutFeedbacks = "/v1/workout-feedback";
  static const String createWorkoutFeedback = "/v1/workout-feedback";
  static String getWorkoutFeedbackByWorkoutId(String workoutId) =>
      "/v1/workout-feedback/workout/$workoutId";
  static String getWorkoutFeedbackById(String id) => "/v1/workout-feedback/$id";
  static String updateWorkoutFeedback(String id) => "/v1/workout-feedback/$id";
  static String deleteWorkoutFeedback(String id) => "/v1/workout-feedback/$id";

  // ================== WATCH LOG ==================
  static const String getWatchLogs = "/v1/watch-log";
  static const String createWatchLog = "/v1/watch-log";
  static const String createManyWatchLogs = "/v1/watch-log/many";
  static String updateWatchLog(String id) => "/v1/watch-log/$id";
  static String deleteWatchLog(String id) => "/v1/watch-log/$id";
  static const String deleteWatchLogs = "/v1/watch-log";

  // ================== AI RECOMMENDATIONS ==================
  static const String getAiRecommendations = "/v1/ai/recommend";
}

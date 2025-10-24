import { Router } from "express";
import { ExerciseTypeController } from "../controllers";
import { ExerciseTypeService } from "../services";
import { ExerciseTypeRepository } from "../repositories";
import { ExerciseType } from "../models";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";

const exerciseTypeRepository = new ExerciseTypeRepository(ExerciseType);
const exerciseTypeService = new ExerciseTypeService(exerciseTypeRepository);
const exerciseTypeController = new ExerciseTypeController(exerciseTypeService);
const router = Router();

router.get("/", exerciseTypeController.getAll);
router.post("/", verifyAccessToken, exerciseTypeController.create);
router.delete("/:id", verifyAccessToken, exerciseTypeController.delete);
router.get("/:id", exerciseTypeController.getById);
router.put("/:id", verifyAccessToken, exerciseTypeController.update);

export default router;

// Cardio = "Cardio",            // Tập tim mạch: chạy bộ, đạp xe, bơi lội
// Strength = "Strength",        // Tập sức mạnh: tạ, bodyweight, resistance band
// HIIT = "HIIT",                // High-Intensity Interval Training
// Flexibility = "Flexibility",  // Tăng linh hoạt: yoga, pilates, stretching
// Balance = "Balance",          // Cân bằng: bosu, single-leg exercises
// Mobility = "Mobility",        // Vận động khớp, phòng chấn thương
// Endurance = "Endurance",      // Sức bền: chạy dài, rowing, cycling
// Functional = "Functional",    // Tập vận động chức năng: squats, lunges, push-ups
// MindBody = "MindBody",        // Tập kết hợp tâm trí và cơ thể: tai chi, yoga flow
// SportSpecific = "SportSpecific", // Bài tập chuyên môn thể thao: bóng đá, bóng rổ drills
// Custom = "Custom",            // Bài tập tùy chỉnh

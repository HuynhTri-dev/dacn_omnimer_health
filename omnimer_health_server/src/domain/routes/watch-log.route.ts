import express from "express";
import { WatchLogController } from "../controllers";
import { WatchLogService } from "../services";
import { WatchLogRepository } from "../repositories";
import { WatchLog } from "../models";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";

const router = express.Router();
const watchLogRepo = new WatchLogRepository(WatchLog);
const watchLogService = new WatchLogService(watchLogRepo);
const watchLogController = new WatchLogController(watchLogService);

router.post("/", verifyAccessToken, watchLogController.create);
router.post("/many", verifyAccessToken, watchLogController.createMany);
router.get("/", verifyAccessToken, watchLogController.getAll);
router.put("/:id", verifyAccessToken, watchLogController.update);
router.delete("/:id", verifyAccessToken, watchLogController.delete);
router.delete("/", verifyAccessToken, watchLogController.deleteMany);

export default router;

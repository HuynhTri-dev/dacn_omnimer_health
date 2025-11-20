import express from "express";
import { EquipmentController } from "../controllers";
import { EquipmentService } from "../services";
import { EquipmentRepository } from "../repositories";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";
import { uploadImage } from "../../common/middlewares/upload.middleware";
import { Equipment } from "../models";

const router = express.Router();

const repo = new EquipmentRepository(Equipment);
const service = new EquipmentService(repo);
const controller = new EquipmentController(service);

router.post("/", verifyAccessToken, uploadImage("image"), controller.create);
router.put("/:id", verifyAccessToken, uploadImage("image"), controller.update);
router.get("/", controller.getAll);
router.delete("/:id", verifyAccessToken, controller.delete);

export default router;

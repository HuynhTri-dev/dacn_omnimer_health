import express from "express";
import { BodyPartController } from "../controllers";
import { BodyPartService } from "../services";
import { BodyPartRepository } from "../repositories";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";
import { uploadImage } from "../../common/middlewares/upload.middleware";
import { BodyPart } from "../models";

const router = express.Router();

const repo = new BodyPartRepository(BodyPart);
const service = new BodyPartService(repo);
const controller = new BodyPartController(service);

router.post("/", verifyAccessToken, uploadImage("image"), controller.create);
router.put("/:id", verifyAccessToken, uploadImage("image"), controller.update);
router.get("/", controller.getAll);
router.delete("/:id", verifyAccessToken, controller.delete);

export default router;

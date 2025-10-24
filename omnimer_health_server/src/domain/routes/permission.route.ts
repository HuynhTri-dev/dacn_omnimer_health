import { Router } from "express";
import { PermissionController } from "../controllers";
import { PermissionService } from "../services";
import { PermissionRepository } from "../repositories";
import { Permission } from "../models";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";
import { checkPermission } from "../../common/middlewares/checkPermission";

const permissionRepository = new PermissionRepository(Permission);
const permissionService = new PermissionService(permissionRepository);
const permissionController = new PermissionController(permissionService);
const router = Router();

router.get("/", permissionController.getAll);
router.post("/", verifyAccessToken, permissionController.create);
router.delete("/:id", verifyAccessToken, permissionController.delete);
router.get("/:id", permissionController.getById);
router.put("/:id", verifyAccessToken, permissionController.update);

export default router;

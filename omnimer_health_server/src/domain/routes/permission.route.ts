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

router.get(
  "/",
  verifyAccessToken,
  //checkPermission("permission.getall"),
  checkPermission("bodyPart.update"),
  permissionController.getAll.bind(permissionController)
);
router.post(
  "/",
  verifyAccessToken,
  permissionController.create.bind(permissionController)
);
router.delete("/:id", permissionController.delete.bind(permissionController));

export default router;

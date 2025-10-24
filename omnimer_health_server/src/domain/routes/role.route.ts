import { Router } from "express";
import { RoleController } from "../controllers";
import { RoleService } from "../services";
import { RoleRepository } from "../repositories";
import { Role } from "../models";
import { verifyAccessToken } from "../../common/middlewares/auth.middleware";

const roleRepository = new RoleRepository(Role);
const roleService = new RoleService(roleRepository);
const roleController = new RoleController(roleService);

const router = Router();

router.get("/", verifyAccessToken, roleController.getAll);
router.post("/", roleController.create);
router.delete("/:id", roleController.delete);
router.get("/:id", roleController.getById);
router.put("/:id", verifyAccessToken, roleController.updateRole);
router.patch("/:id", verifyAccessToken, roleController.updatePermissionIds);

export default router;

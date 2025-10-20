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

router.get("/", verifyAccessToken, roleController.getAll.bind(roleController));
router.post("/", roleController.create.bind(roleController));
router.delete("/:id", roleController.delete.bind(roleController));

export default router;

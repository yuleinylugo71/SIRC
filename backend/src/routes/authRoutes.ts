import { Router } from 'express';
import { AuthController } from '../controllers/authController';

import { auth, adminOnly } from '../middlewares/auth';

const router = Router();
const authController = new AuthController();

// POST /api/auth/login
router.post('/login', authController.login.bind(authController));

// POST /api/auth/logout (protegido por token)
router.post('/logout', auth, authController.logout.bind(authController));

// POST /api/auth/register (protegido por token y adminOnly)
router.post('/register', auth, adminOnly, authController.register.bind(authController));

// GET /api/auth/users (protegido por token y adminOnly)
router.get('/users', auth, adminOnly, authController.listarUsuarios.bind(authController));

// PATCH /api/auth/users/:id (protegido por token y adminOnly)
router.patch('/users/:id', auth, adminOnly, authController.actualizarUsuario.bind(authController));

// PATCH /api/auth/me/password (protegido por token)
router.patch('/me/password', auth, authController.cambiarContrasena.bind(authController));

export default router;

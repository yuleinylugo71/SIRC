import { Router } from 'express';
import { SyncController } from '../controllers/syncController';
import { auth } from '../middlewares/auth';

const router = Router();
const syncController = new SyncController();

// POST /api/sync
// Protegido por autenticación y validación de dispositivo activo
router.post('/', auth, syncController.sincronizar.bind(syncController));

export default router;

import { Router } from 'express';
import { CitizenController } from '../controllers/citizenController';
import { auth } from '../middlewares/auth';

const router = Router();
const citizenController = new CitizenController();

// GET /api/citizens - Listar ciudadanos activos
router.get('/', auth, citizenController.listar.bind(citizenController));

// POST /api/citizens - Crear un nuevo ciudadano directamente
router.post('/', auth, citizenController.crear.bind(citizenController));

// PUT /api/citizens/:uuid - Actualizar datos de ciudadano por UUID
router.put('/:uuid', auth, citizenController.actualizar.bind(citizenController));

// DELETE /api/citizens/:uuid - Borrado lógico de ciudadano
router.delete('/:uuid', auth, citizenController.eliminar.bind(citizenController));

export default router;

import swaggerJSDoc from 'swagger-jsdoc';

const swaggerDefinition = {
  openapi: '3.0.0',
  info: {
    title: 'SIRC API REST - Registro Ciudadano',
    version: '1.0.0',
    description: 'Documentación oficial e interactiva de la API REST del Sistema de Información de Registro Ciudadano (SIRC). Soporta autenticación de dispositivo único, operaciones CRUD offline y motor de resolución de conflictos LWW.',
    contact: {
      name: 'Equipo de Soporte SIRC',
      email: 'soporte@sirc.gov',
    },
  },
  servers: [
    {
      url: 'http://localhost:3000',
      description: 'Servidor Local de Desarrollo',
    },
  ],
  components: {
    securitySchemes: {
      BearerAuth: {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Introduce el token JWT devuelto por el login',
      },
    },
    schemas: {
      LoginRequest: {
        type: 'object',
        required: ['correo', 'contrasena', 'dispositivo_codigo', 'dispositivo_nombre'],
        properties: {
          correo: { type: 'string', format: 'email', example: 'admin@sirc.gov' },
          contrasena: { type: 'string', example: 'admin12345' },
          dispositivo_codigo: { type: 'string', example: 'uuid-dispositivo-codigo-1' },
          dispositivo_nombre: { type: 'string', example: 'Samsung Galaxy S22' },
          dispositivo_modelo: { type: 'string', example: 'SM-S901B' },
          dispositivo_so: { type: 'string', example: 'Android 13' },
        },
      },
      CitizenRequest: {
        type: 'object',
        required: ['documentoIdentidad', 'nombres', 'apellidos', 'fechaNacimiento'],
        properties: {
          documentoIdentidad: { type: 'string', example: '12345678' },
          nombres: { type: 'string', example: 'Juan Carlos' },
          apellidos: { type: 'string', example: 'Pérez Gómez' },
          fechaNacimiento: { type: 'string', format: 'date-time', example: '1995-05-15T00:00:00.000Z' },
          telefono: { type: 'string', example: '+54911223344' },
          correo: { type: 'string', format: 'email', example: 'juan.perez@email.com' },
        },
      },
      SyncTask: {
        type: 'object',
        required: ['id', 'tablaAfectada', 'registroId', 'operacion', 'payload'],
        properties: {
          id: { type: 'string', format: 'uuid', example: 'uuid-tarea-local-1' },
          tablaAfectada: { type: 'string', example: 'ciudadanos' },
          registroId: { type: 'string', format: 'uuid', example: 'uuid-ciudadano-1' },
          operacion: { type: 'string', enum: ['INSERT', 'UPDATE', 'DELETE'], example: 'INSERT' },
          payload: { 
            type: 'string', 
            description: 'JSON Stringified del ciudadano y sus metadatos LWW',
            example: '{"documento_identidad":"12345678","nombres":"Juan","apellidos":"Perez","fecha_nacimiento":"1995-05-15T00:00:00.000Z","version":1,"metadatos_campos":{"nombres":"2026-07-03T01:00:00.000Z"}}' 
          },
        },
      },
    },
  },
  paths: {
    '/api/auth/login': {
      post: {
        summary: 'Autenticación del Registrador (Dispositivo Único)',
        tags: ['Autenticación'],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/LoginRequest' },
            },
          },
        },
        responses: {
          200: {
            description: 'Autenticación exitosa. Devuelve el JWT Token y el password hash para la caché local',
          },
          401: {
            description: 'Credenciales inválidas o dispositivo bloqueado',
          },
        },
      },
    },
    '/api/auth/logout': {
      post: {
        summary: 'Cierre de sesión en el servidor',
        tags: ['Autenticación'],
        security: [{ BearerAuth: [] }],
        responses: {
          200: {
            description: 'Sesión terminada. El dispositivo queda desvinculado en el servidor',
          },
          401: {
            description: 'Token no autorizado o vencido',
          },
        },
      },
    },
    '/api/auth/register': {
      post: {
        summary: 'Registrar un nuevo usuario (Solo Administrador)',
        tags: ['Autenticación'],
        security: [{ BearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['correo', 'contrasena'],
                properties: {
                  correo: { type: 'string', format: 'email', example: 'juan.perez@sirc.gov' },
                  contrasena: { type: 'string', example: 'registrador12345' },
                  nombre: { type: 'string', example: 'Juan Pérez' },
                  rol: { type: 'string', enum: ['ADMIN', 'REGISTRADOR'], default: 'REGISTRADOR', example: 'REGISTRADOR' }
                }
              }
            }
          }
        },
        responses: {
          201: {
            description: 'Usuario creado exitosamente',
          },
          400: {
            description: 'Campos requeridos faltantes',
          },
          401: {
            description: 'No autorizado (Token faltante o inválido)',
          },
          403: {
            description: 'Prohibido (Se requiere rol ADMIN)',
          },
          409: {
            description: 'El correo electrónico ya está registrado',
          }
        }
      }
    },
    '/api/citizens': {
      get: {
        summary: 'Listar todos los ciudadanos activos',
        tags: ['Ciudadanos'],
        security: [{ BearerAuth: [] }],
        responses: {
          200: {
            description: 'Listado recuperado exitosamente',
          },
        },
      },
      post: {
        summary: 'Registrar un ciudadano de forma directa',
        tags: ['Ciudadanos'],
        security: [{ BearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/CitizenRequest' },
            },
          },
        },
        responses: {
          201: {
            description: 'Ciudadano insertado de forma exitosa en el servidor',
          },
          400: {
            description: 'Formato inválido o documento de identidad ya registrado',
          },
        },
      },
    },
    '/api/citizens/{uuid}': {
      put: {
        summary: 'Actualizar ciudadano por UUID',
        tags: ['Ciudadanos'],
        security: [{ BearerAuth: [] }],
        parameters: [
          {
            name: 'uuid',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/CitizenRequest' },
            },
          },
        },
        responses: {
          200: {
            description: 'Registro actualizado con marcas temporales LWW',
          },
          404: {
            description: 'Ciudadano no encontrado',
          },
        },
      },
      delete: {
        summary: 'Borrado lógico de ciudadano por UUID',
        tags: ['Ciudadanos'],
        security: [{ BearerAuth: [] }],
        parameters: [
          {
            name: 'uuid',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        responses: {
          200: {
            description: 'Borrado lógico realizado exitosamente',
          },
          404: {
            description: 'Ciudadano no encontrado',
          },
        },
      },
    },
    '/api/sync': {
      post: {
        summary: 'Sincronizar cola de cambios local',
        tags: ['Sincronización'],
        security: [{ BearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['tareas'],
                properties: {
                  tareas: {
                    type: 'array',
                    items: { $ref: '#/components/schemas/SyncTask' },
                  },
                },
              },
            },
          },
        },
        responses: {
          200: {
            description: 'Cola de sincronización procesada de forma idempotente. Devuelve un lote con el resultado y ACKs individuales',
          },
        },
      },
    },
  },
};

const options = {
  swaggerDefinition,
  apis: [], // Al declarar paths de forma estática no necesitamos escanear archivos
};

export const swaggerSpec = swaggerJSDoc(options);

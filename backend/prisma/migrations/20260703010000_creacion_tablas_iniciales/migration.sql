-- CreateTable
CREATE TABLE "usuarios" (
    "id" UUID NOT NULL,
    "correo" TEXT NOT NULL,
    "contrasena" TEXT NOT NULL,
    "nombre" TEXT,
    "rol" TEXT NOT NULL DEFAULT 'REGISTRADOR',
    "version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),
    "dispositivo_activo_id" UUID,

    CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "dispositivos" (
    "id" UUID NOT NULL,
    "codigo_unico" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "modelo" TEXT,
    "sistema_operativo" TEXT,
    "version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "dispositivos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ciudadanos" (
    "id" UUID NOT NULL,
    "documento_identidad" TEXT NOT NULL,
    "nombres" TEXT NOT NULL,
    "apellidos" TEXT NOT NULL,
    "fecha_nacimiento" TIMESTAMP(3) NOT NULL,
    "telefono" TEXT,
    "correo" TEXT,
    "estado_sincronizacion" TEXT NOT NULL DEFAULT 'PENDIENTE',
    "registrado_por_usuario_id" UUID NOT NULL,
    "registrado_en_dispositivo_id" UUID NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "metadatos_campos" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "deleted_at" TIMESTAMP(3),

    CONSTRAINT "ciudadanos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "logs_sincronizacion" (
    "id" UUID NOT NULL,
    "dispositivo_id" UUID NOT NULL,
    "usuario_id" UUID NOT NULL,
    "fecha_sincronizacion" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "estado" TEXT NOT NULL,
    "registros_procesados" INTEGER NOT NULL,
    "detalles" TEXT,
    "version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "logs_sincronizacion_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_correo_key" ON "usuarios"("correo");

-- CreateIndex
CREATE UNIQUE INDEX "dispositivos_codigo_unico_key" ON "dispositivos"("codigo_unico");

-- CreateIndex
CREATE UNIQUE INDEX "ciudadanos_documento_identidad_key" ON "ciudadanos"("documento_identidad");

-- AddForeignKey
ALTER TABLE "usuarios" ADD CONSTRAINT "usuarios_dispositivo_activo_id_fkey" FOREIGN KEY ("dispositivo_activo_id") REFERENCES "dispositivos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ciudadanos" ADD CONSTRAINT "ciudadanos_registrado_por_usuario_id_fkey" FOREIGN KEY ("registrado_por_usuario_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ciudadanos" ADD CONSTRAINT "ciudadanos_registrado_en_dispositivo_id_fkey" FOREIGN KEY ("registrado_en_dispositivo_id") REFERENCES "dispositivos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "logs_sincronizacion" ADD CONSTRAINT "logs_sincronizacion_dispositivo_id_fkey" FOREIGN KEY ("dispositivo_id") REFERENCES "dispositivos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "logs_sincronizacion" ADD CONSTRAINT "logs_sincronizacion_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

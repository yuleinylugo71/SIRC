CREATE TABLE "ciudadano_historial" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "ciudadano_id" UUID NOT NULL,
    "version" INTEGER NOT NULL,
    "documento_identidad" TEXT NOT NULL,
    "nombres" TEXT NOT NULL,
    "apellidos" TEXT NOT NULL,
    "fecha_nacimiento" TIMESTAMP(3) NOT NULL,
    "telefono" TEXT,
    "correo" TEXT,
    "estado_sincronizacion" TEXT NOT NULL,
    "registrado_por_usuario_id" UUID NOT NULL,
    "registrado_en_dispositivo_id" UUID NOT NULL,
    "metadatos_campos" JSONB,
    "original_created_at" TIMESTAMP(3) NOT NULL,
    "original_updated_at" TIMESTAMP(3) NOT NULL,
    "snapshot_created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "motivo" TEXT NOT NULL,

    CONSTRAINT "ciudadano_historial_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "ciudadano_historial_ciudadano_id_version_idx"
ON "ciudadano_historial"("ciudadano_id", "version");

ALTER TABLE "ciudadano_historial"
ADD CONSTRAINT "ciudadano_historial_ciudadano_id_fkey"
FOREIGN KEY ("ciudadano_id") REFERENCES "ciudadanos"("id")
ON DELETE RESTRICT ON UPDATE CASCADE;

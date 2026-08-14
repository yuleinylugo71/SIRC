# Despliegue SIRC en Dockploy

Dominio recomendado:

```text
https://sirc.yuleiny.site
```

## Servicios

Crear 3 servicios:

```text
sirc-db
sirc-api
sirc-web
```

## 1. Base de datos

Servicio:

```text
sirc-db
```

Imagen:

```text
postgres:16-alpine
```

Variables:

```env
POSTGRES_DB=sirc
POSTGRES_USER=sirc_user
POSTGRES_PASSWORD=CAMBIA_ESTA_CLAVE
```

Volumen persistente:

```text
/var/lib/postgresql/data
```

No exponer puerto publico.

## 2. Backend API

Servicio:

```text
sirc-api
```

Dockerfile:

```text
Dockerfile.api
```

Puerto interno:

```text
3000
```

Variables:

```env
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://sirc_user:CAMBIA_ESTA_CLAVE@sirc-db:5432/sirc?schema=public
JWT_SECRET=CAMBIA_ESTA_CLAVE_JWT_MINIMO_32_CARACTERES
JWT_EXPIRES_IN=7d
```

Rutas que deben ir al backend:

```text
/api
/api-docs
/health
```

## 3. Landing y app web

Servicio:

```text
sirc-web
```

Dockerfile:

```text
Dockerfile.web
```

Puerto interno:

```text
8080
```

Variables:

```env
NODE_ENV=production
PORT=8080
API_INTERNAL_URL=http://sirc-api:3000
```

Rutas que deben ir a la web:

```text
/
/app
/downloads
```

## Ruteo en Dockploy

Configurar el dominio:

```text
sirc.yuleiny.site
```

Opcion recomendada:

```text
sirc.yuleiny.site -> sirc-web:8080
```

El servicio `sirc-web` reenvia internamente estas rutas al backend `sirc-api`:

```text
/api
/api-docs
/health
```

Por eso no es obligatorio crear reglas por path si Dockploy no las maneja bien.

Si decides hacer ruteo por path desde Dockploy, usa:

```text
sirc.yuleiny.site/         -> sirc-web:8080
sirc.yuleiny.site/app      -> sirc-web:8080
sirc.yuleiny.site/downloads -> sirc-web:8080
sirc.yuleiny.site/api      -> sirc-api:3000
sirc.yuleiny.site/api-docs -> sirc-api:3000
sirc.yuleiny.site/health   -> sirc-api:3000
```

## Importante para Flutter web

El build web debe apuntar al dominio de produccion:

```powershell
cd mobile
flutter build web --release --base-href /app/ --pwa-strategy=none --dart-define=API_BASE_URL=https://sirc.yuleiny.site
```

Despues copiar el build a:

```text
landing/app
```

## URLs finales

```text
https://sirc.yuleiny.site
https://sirc.yuleiny.site/app/
https://sirc.yuleiny.site/downloads/sirc-app-v1.0.apk
https://sirc.yuleiny.site/health
https://sirc.yuleiny.site/api-docs
```

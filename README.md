# SIRC

Sistema de Informacion de Registro Ciudadano.

Aplicacion movil para Android que permite registrar personas de manera offline usando SQLite/Drift y sincronizar los datos contra un backend Node.js con PostgreSQL.

## Ejecutar local en PC

Requisitos:

- Node.js
- PostgreSQL local con la base `sirc_db`
- Flutter
- Android Studio

## Backend local

```powershell
cd C:\Users\Yuleiny\OneDrive\Documentos\SIRC\backend
npm.cmd install
npx.cmd prisma generate
npx.cmd prisma migrate deploy
npm.cmd run build
npm.cmd start
```

El backend queda en:

```text
http://localhost:3000
```

Endpoints utiles:

```text
http://localhost:3000/health
http://localhost:3000/api-docs
```

## Landing local

```powershell
cd C:\Users\Yuleiny\OneDrive\Documentos\SIRC\landing
node server.js
```

La landing queda en:

```text
http://localhost:8080
```

## App movil

```powershell
cd C:\Users\Yuleiny\OneDrive\Documentos\SIRC\mobile
flutter pub get
flutter run
```

En Android Studio, abre la carpeta `mobile` y ejecuta `lib/main.dart` en un emulador Android.

La app ya queda configurada para desarrollo local:

- Android Emulator usa `http://10.0.2.2:3000`
- Flutter Web/Desktop usa `http://localhost:3000`
- Para usar otra URL: `flutter run --dart-define=API_BASE_URL=http://TU_IP:3000`

Usuario inicial:

```text
correo: admin@sirc.gov
clave: admin12345
```

## App web en el PC

Modo desarrollo con Chrome:

```powershell
cd C:\Users\Yuleiny\OneDrive\Documentos\SIRC
powershell -ExecutionPolicy Bypass -File .\start-app-web.ps1
```

La app queda en:

```text
http://localhost:5000
```

Modo integrado en la landing:

```powershell
cd C:\Users\Yuleiny\OneDrive\Documentos\SIRC
powershell -ExecutionPolicy Bypass -File .\publish-app-web-local.ps1
powershell -ExecutionPolicy Bypass -File .\start-local.ps1
```

Luego entra a:

```text
http://localhost:8080/app/
```

## Inicio rapido

Desde la raiz del proyecto:

```powershell
cd C:\Users\Yuleiny\OneDrive\Documentos\SIRC
powershell -ExecutionPolicy Bypass -File .\start-local.ps1
```

Si necesitas reiniciar limpio porque aparece `EADDRINUSE` o "address already in use":

```powershell
cd C:\Users\Yuleiny\OneDrive\Documentos\SIRC
powershell -ExecutionPolicy Bypass -File .\stop-local.ps1
powershell -ExecutionPolicy Bypass -File .\start-local.ps1
```

`EADDRINUSE` significa que el puerto ya esta ocupado. En este proyecto normalmente quiere decir que el backend ya esta corriendo en `3000` o la landing ya esta corriendo en `8080`.

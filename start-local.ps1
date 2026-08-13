param(
  [switch]$SkipInstall
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$backend = Join-Path $root "backend"
$landing = Join-Path $root "landing"
$mobile = Join-Path $root "mobile"

function Test-PortInUse {
  param([int]$Port)

  $connections = netstat -ano | Select-String ":$Port "
  return $null -ne $connections
}

Write-Host "Preparando SIRC local..." -ForegroundColor Cyan

if (-not $SkipInstall) {
  Write-Host "Instalando/verificando dependencias del backend..." -ForegroundColor Cyan
  Push-Location $backend
  npm.cmd install
  npx.cmd prisma generate
  Pop-Location
}

$backendCommand = "Set-Location -LiteralPath '$backend'; npx.cmd prisma migrate deploy; npm.cmd run build; npm.cmd start"
$landingCommand = "Set-Location -LiteralPath '$landing'; node server.js"

if (Test-PortInUse 3000) {
  Write-Host "Backend ya esta corriendo en http://localhost:3000" -ForegroundColor Yellow
} else {
  Start-Process powershell -ArgumentList @("-NoExit", "-Command", $backendCommand)
}

if (Test-PortInUse 8080) {
  Write-Host "Landing ya esta corriendo en http://localhost:8080" -ForegroundColor Yellow
} else {
  Start-Process powershell -ArgumentList @("-NoExit", "-Command", $landingCommand)
}

Write-Host ""
Write-Host "SIRC local iniciado:" -ForegroundColor Green
Write-Host "Backend:  http://localhost:3000/health"
Write-Host "Swagger:  http://localhost:3000/api-docs"
Write-Host "Landing:  http://localhost:8080"
Write-Host ""
Write-Host "Para la app movil en Android Studio:"
Write-Host "1. Abre la carpeta: $mobile"
Write-Host "2. Ejecuta main.dart en un emulador Android."
Write-Host ""
Write-Host "Usuario inicial:"
Write-Host "correo: admin@sirc.gov"
Write-Host "clave:  admin12345"

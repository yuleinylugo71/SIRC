$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$mobile = Join-Path $root "mobile"

Write-Host "Abriendo SIRC App Web en http://localhost:5000 ..." -ForegroundColor Cyan

Push-Location $mobile
flutter pub get
flutter run -d chrome --web-hostname localhost --web-port 5000 --dart-define=API_BASE_URL=http://localhost:3000
Pop-Location

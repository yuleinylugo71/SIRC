$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$mobile = Join-Path $root "mobile"
$target = Join-Path $root "landing\app"

Write-Host "Compilando SIRC App Web..." -ForegroundColor Cyan

Push-Location $mobile
flutter pub get
flutter build web --release --base-href /app/ --pwa-strategy=none --dart-define=API_BASE_URL=https://sirc.yuleiny.site/api
Pop-Location

if (Test-Path $target) {
  Remove-Item -LiteralPath $target -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $target | Out-Null
Copy-Item -Path (Join-Path $mobile "build\web\*") -Destination $target -Recurse -Force

Write-Host "App Web publicada localmente en http://localhost:8080/app/" -ForegroundColor Green

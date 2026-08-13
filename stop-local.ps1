$ErrorActionPreference = "Stop"

function Stop-PortProcess {
  param([int]$Port)

  $lines = netstat -ano | Select-String ":$Port "
  $processIds = @()

  foreach ($line in $lines) {
    $parts = ($line.Line -split "\s+") | Where-Object { $_ }
    if ($parts.Length -ge 5 -and $parts[3] -eq "LISTENING") {
      $processIds += [int]$parts[4]
    }
  }

  $processIds = $processIds | Sort-Object -Unique

  if ($processIds.Count -eq 0) {
    Write-Host "Puerto $Port libre." -ForegroundColor Green
    return
  }

  foreach ($processId in $processIds) {
    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
    if ($process) {
      Write-Host "Deteniendo $($process.ProcessName) PID $processId en puerto $Port..." -ForegroundColor Yellow
      Stop-Process -Id $processId -Force
    }
  }
}

Stop-PortProcess 3000
Stop-PortProcess 8080

Write-Host "Servicios locales de SIRC detenidos." -ForegroundColor Green

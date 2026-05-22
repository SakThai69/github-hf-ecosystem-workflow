[CmdletBinding()]
param(
  [int]$Iterations = 3,
  [switch]$Json,
  [string]$ScriptPath = (Join-Path $PSScriptRoot 'ecosystem-health.ps1')
)

Set-StrictMode -Version Latest

if (-not (Test-Path $ScriptPath)) {
  Write-Error "Health script not found at: $ScriptPath"
  exit 2
}

$logsDir = Join-Path $PSScriptRoot 'logs'
if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir | Out-Null }

# Prefer PowerShell Core (pwsh) if present, fall back to Windows PowerShell.
$psHost = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell.exe' }

function New-LogFileName([int]$i) {
  $ts = Get-Date -Format 'yyyyMMdd-HHmmss'
  Join-Path $logsDir ("ecosystem-health-run{0:D2}-{1}.log" -f $i, $ts)
}

$overallExit = 0

for ($i = 1; $i -le $Iterations; $i++) {
  $logFile = New-LogFileName $i
  Write-Host ("--- Run {0}/{1} ---" -f $i, $Iterations)

  # Note: do not name this $args — that's a PowerShell automatic variable.
  $psArgs = @()
  if ($Json)                                     { $psArgs += '-Json' }
  if ($PSBoundParameters.ContainsKey('Verbose')) { $psArgs += '-Verbose' }

  try {
    & $psHost -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @psArgs *>&1 |
      Tee-Object -FilePath $logFile | Out-Host

    $code = $LASTEXITCODE
    if ($code -ne 0) { $overallExit = 1 }

    Write-Host ("[Exit] {0}" -f $code)
  }
  catch {
    $overallExit = 1
    "Exception: $($_.Exception.Message)" | Out-File -FilePath $logFile -Append -Encoding utf8
    Write-Host ("[Exception] {0}" -f $_.Exception.Message)
  }

  Write-Host ""
}

exit $overallExit

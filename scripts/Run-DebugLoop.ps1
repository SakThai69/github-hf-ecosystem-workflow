[CmdletBinding()]
param(
  [int]$Iterations = 3,
  [switch]$Json,
  [string]$ScriptPath = (Join-Path $PSScriptRoot 'ecosystem-health.ps1')
)

Set-StrictMode -Version Latest

$logsDir = Join-Path $PSScriptRoot 'logs'
if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir | Out-Null }

function New-LogFileName([int]$i) {
  $ts = Get-Date -Format 'yyyyMMdd-HHmmss'
  Join-Path $logsDir ("ecosystem-health-run{0:D2}-{1}.log" -f $i, $ts)
}

$overallExit = 0

for ($i = 1; $i -le $Iterations; $i++) {
  $logFile = New-LogFileName $i
  Write-Host ("--- Run {0}/{1} ---" -f $i, $Iterations)

  $args = @()
  if ($Json)    { $args += '-Json' }
  if ($PSBoundParameters.ContainsKey('Verbose')) { $args += '-Verbose' }

  try {
    # Capture all streams to file + console
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @args *>&1 |
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

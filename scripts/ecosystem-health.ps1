param(
  [switch]$Json
)

$ErrorActionPreference = "Stop"

function Test-Command {
  param([string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-Check {
  param(
    [string]$Name,
    [scriptblock]$Action
  )
  try {
    $output = & $Action 2>&1 | Out-String
    [pscustomobject]@{
      check = $Name
      ok = $true
      detail = $output.Trim()
    }
  } catch {
    [pscustomobject]@{
      check = $Name
      ok = $false
      detail = $_.Exception.Message
    }
  }
}

$results = @()

$results += [pscustomobject]@{
  check = "workspace_git_repo"
  ok = Test-Path ".git"
  detail = if (Test-Path ".git") { "repo detected" } else { "no repo at current path" }
}

$hasGh = Test-Command "gh"
$results += [pscustomobject]@{
  check = "gh_cli_present"
  ok = $hasGh
  detail = if ($hasGh) { "gh found" } else { "gh not found on PATH" }
}

if ($hasGh) {
  $results += Invoke-Check "gh_auth_status" { gh auth status }
}

$hfWrapper = Join-Path $PSScriptRoot "..\hf-safe.cmd"
$hfWrapper = (Resolve-Path $hfWrapper).Path
$results += [pscustomobject]@{
  check = "hf_wrapper_present"
  ok = Test-Path $hfWrapper
  detail = $hfWrapper
}

if (Test-Path $hfWrapper) {
  $results += Invoke-Check "hf_version" { & $hfWrapper version }
  $results += Invoke-Check "hf_auth_whoami" { & $hfWrapper auth whoami }
  $results += Invoke-Check "hf_safe_models_list" { & $hfWrapper models list --search "mcp" --limit 3 }
}

$results += [pscustomobject]@{
  check = "hf_token_env_present"
  ok = [bool]$env:HF_TOKEN
  detail = if ($env:HF_TOKEN) { "HF_TOKEN is set in current shell" } else { "HF_TOKEN not set in current shell (may still be in stored hf auth)" }
}

if ($Json) {
  $results | ConvertTo-Json -Depth 4
  exit 0
}

$failed = $results | Where-Object { -not $_.ok }

Write-Host "=== GitHub + HF ecosystem health ==="
foreach ($r in $results) {
  $icon = if ($r.ok) { "[OK]" } else { "[!!]" }
  Write-Host "$icon $($r.check): $($r.detail)"
}

if ($failed.Count -gt 0) {
  Write-Host ""
  Write-Host "Health status: ATTENTION REQUIRED ($($failed.Count) failing checks)"
  exit 1
}

Write-Host ""
Write-Host "Health status: READY"
exit 0

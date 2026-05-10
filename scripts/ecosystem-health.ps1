#Requires -Version 5.1
<#
.SYNOPSIS
  GitHub + Hugging Face ecosystem health checker.

.PARAMETER Json
  Output results as JSON instead of human-readable text.

.PARAMETER Verbose
  Show extra detail for passing checks (default: only show detail on failure).
#>
param(
  [switch]$Json,
  [switch]$Verbose
)

Set-StrictMode -Version Latest
# NOTE: Do NOT set $ErrorActionPreference = "Stop" at top-level — it aborts the
# entire script on any unhandled error. Each check is wrapped in Invoke-Check
# which handles its own errors. Top-level code uses explicit -ErrorAction.

# ── Helpers ──────────────────────────────────────────────────────────────────

function Test-CommandPresent {
  param([string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-Check {
  <#
    Run $Action, capture stdout+stderr, and return a result object.
    Never throws — failures are surfaced as ok=false with detail.
  #>
  param(
    [string]$Name,
    [string]$Category = "general",
    [scriptblock]$Action
  )
  try {
    $output = (& $Action 2>&1) | Out-String
    [pscustomobject]@{
      check    = $Name
      category = $Category
      ok       = $true
      detail   = $output.Trim()
    }
  }
  catch {
    [pscustomobject]@{
      check    = $Name
      category = $Category
      ok       = $false
      detail   = $_.Exception.Message.Trim()
    }
  }
}

function Write-CheckLine {
  param([pscustomobject]$Result)
  if ($Result.ok) {
    $icon  = "[OK]"
    $color = "Green"
    $msg   = if ($Verbose) { "$icon  $($Result.check): $($Result.detail)" }
             else           { "$icon  $($Result.check)" }
  }
  else {
    $icon  = "[!!]"
    $color = "Red"
    $msg   = "$icon  $($Result.check): $($Result.detail)"
  }
  Write-Host $msg -ForegroundColor $color
}

# ── Resolve hf-safe.cmd path relative to this script ─────────────────────────

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$hfWrapper  = Join-Path $scriptDir "..\hf-safe.cmd"

# Use Test-Path before Resolve-Path — Resolve-Path throws on missing files
$hfWrapperResolved = if (Test-Path $hfWrapper) {
  (Resolve-Path $hfWrapper).Path
}
else {
  $hfWrapper   # keep the raw path so we can report it accurately
}

# ── Run all checks ────────────────────────────────────────────────────────────

$results = [System.Collections.Generic.List[pscustomobject]]::new()

# Workspace
$results.Add([pscustomobject]@{
  check    = "workspace_git_repo"
  category = "workspace"
  ok       = (Test-Path ".git")
  detail   = if (Test-Path ".git") { "Repo found at: $(Resolve-Path '.')" }
             else { "No .git at: $(Resolve-Path '.'). Run: git init" }
})

$results.Add([pscustomobject]@{
  check    = "working_directory"
  category = "workspace"
  ok       = $true
  detail   = (Resolve-Path '.').Path
})

# GitHub CLI
$hasGh = Test-CommandPresent "gh"
$results.Add([pscustomobject]@{
  check    = "gh_cli_present"
  category = "github"
  ok       = $hasGh
  detail   = if ($hasGh) { (gh --version 2>&1 | Select-Object -First 1) }
             else { "gh not found on PATH. Install: https://cli.github.com" }
})

if ($hasGh) {
  $results.Add((Invoke-Check "gh_auth_status" "github" { gh auth status }))
  $results.Add((Invoke-Check "gh_api_user"    "github" { gh api user --jq '.login' }))
}

# Hugging Face CLI wrapper
$results.Add([pscustomobject]@{
  check    = "hf_wrapper_present"
  category = "huggingface"
  ok       = (Test-Path $hfWrapperResolved)
  detail   = $hfWrapperResolved
})

if (Test-Path $hfWrapperResolved) {
  $results.Add((Invoke-Check "hf_version"          "huggingface" { & $hfWrapperResolved version }))
  $results.Add((Invoke-Check "hf_auth_whoami"       "huggingface" { & $hfWrapperResolved auth whoami }))
  $results.Add((Invoke-Check "hf_safe_models_list"  "huggingface" { & $hfWrapperResolved models list --search "mcp" --limit 3 }))
}

# Env / secrets
$tokenSet = [bool]$env:HF_TOKEN
$results.Add([pscustomobject]@{
  check    = "hf_token_env_present"
  category = "secrets"
  ok       = $tokenSet
  detail   = if ($tokenSet) { "HF_TOKEN is set in current shell" }
             else { "HF_TOKEN not set in shell (hf auth login cache may still work)" }
})

# Python (informational — required for HF CLI install)
$hasPy = Test-CommandPresent "python"
$results.Add([pscustomobject]@{
  check    = "python_present"
  category = "deps"
  ok       = $hasPy
  detail   = if ($hasPy) { (python --version 2>&1 | Out-String).Trim() }
             else { "python not found — required to install HF CLI via pip" }
})

# ── Output ────────────────────────────────────────────────────────────────────

if ($Json) {
  $results | ConvertTo-Json -Depth 4
  exit 0
}

$categories = $results | Select-Object -ExpandProperty category -Unique

Write-Host ""
Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  GitHub + HF Ecosystem Health" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════" -ForegroundColor Cyan

foreach ($cat in $categories) {
  Write-Host ""
  Write-Host "  ▸ $($cat.ToUpper())" -ForegroundColor DarkCyan
  $results | Where-Object { $_.category -eq $cat } | ForEach-Object { Write-CheckLine $_ }
}

$failed = $results | Where-Object { -not $_.ok }

Write-Host ""
Write-Host "──────────────────────────────────────────" -ForegroundColor DarkGray

if ($failed.Count -eq 0) {
  Write-Host "  Status: READY ✓  ($($results.Count) checks passed)" -ForegroundColor Green
  Write-Host ""
  exit 0
}
else {
  Write-Host "  Status: ATTENTION REQUIRED — $($failed.Count) failing check(s):" -ForegroundColor Yellow
  $failed | ForEach-Object {
    Write-Host "    • $($_.check)" -ForegroundColor Red
  }
  Write-Host ""
  Write-Host "  See troubleshooting matrix in GITHUB_HF_ECOSYSTEM_PLAYBOOK.md" -ForegroundColor DarkGray
  Write-Host ""
  exit 1
}

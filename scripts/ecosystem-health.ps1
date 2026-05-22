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
    # Capture output (stdout+stderr) without changing formatting behaviour:
    # Keep Out-String formatting, but avoid the extra pipeline stage.
    $raw = & $Action 2>&1
    $detail = (Out-String -InputObject $raw).Trim()

    [pscustomobject]@{
      check    = $Name
      category = $Category
      ok       = $true
      detail   = $detail
    }
  }
  catch {
    [pscustomobject]@{
      check    = $Name
      category = $Category
      ok       = $false
      detail   = ($_.Exception.Message.Trim())
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

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$hfWrapper = Join-Path $scriptDir "..\hf-safe.cmd"

# Use Test-Path before Resolve-Path — Resolve-Path throws on missing files
$hfWrapperResolved = if (Test-Path $hfWrapper) {
  (Resolve-Path $hfWrapper).Path
}
else {
  $hfWrapper   # keep the raw path so we can report it accurately
}

# ── Run all checks ────────────────────────────────────────────────────────────

$results = [System.Collections.Generic.List[pscustomobject]]::new()

# Cache working directory and .git check (avoid repeated calls)
$cwdPath  = (Resolve-Path '.').Path
$hasGit   = Test-Path ".git"

# Workspace
$results.Add([pscustomobject]@{
  check    = "workspace_git_repo"
  category = "workspace"
  ok       = $hasGit
  detail   = if ($hasGit) { "Repo found at: $cwdPath" }
             else { "No .git at: $cwdPath. Run: git init" }
})

$results.Add([pscustomobject]@{
  check    = "working_directory"
  category = "workspace"
  ok       = $true
  detail   = $cwdPath
})

# GitHub CLI
$hasGh = Test-CommandPresent "gh"
$ghVerDetail = if ($hasGh) {
  $ver = (gh --version 2>&1)
  if ($ver -is [System.Array]) { $ver[0] } else { $ver }
}
else {
  "gh not found on PATH. Install: https://cli.github.com"
}

$results.Add([pscustomobject]@{
  check    = "gh_cli_present"
  category = "github"
  ok       = $hasGh
  detail   = $ghVerDetail
})

if ($hasGh) {
  $results.Add((Invoke-Check "gh_auth_status" "github" { gh auth status }))
  $results.Add((Invoke-Check "gh_api_user"    "github" { gh api user --jq '.login' }))
}

# Hugging Face CLI wrapper
$hfWrapperExists = Test-Path $hfWrapperResolved
$results.Add([pscustomobject]@{
  check    = "hf_wrapper_present"
  category = "huggingface"
  ok       = $hfWrapperExists
  detail   = $hfWrapperResolved
})

if ($hfWrapperExists) {
  $results.Add((Invoke-Check "hf_version"         "huggingface" { & $hfWrapperResolved version }))
  $results.Add((Invoke-Check "hf_auth_whoami"      "huggingface" { & $hfWrapperResolved auth whoami }))
  $results.Add((Invoke-Check "hf_safe_models_list" "huggingface" { & $hfWrapperResolved models list --search "mcp" --limit 3 }))
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
$pyDetail = ""

if ($hasPy) {
  try {
    # Pre-initialize $pv to avoid undefined variable reference if execution fails
    $pv = $null
    $pv = & python --version 2>&1
    if ($null -ne $pv) {
      if ($pv -is [System.Array]) {
        $pyDetail = ($pv -join [Environment]::NewLine).Trim()
      } else {
        $pyDetail = ($pv.ToString()).Trim()
      }
    } else {
      $hasPy = $false
      $pyDetail = "python found on PATH but returned no output"
    }
  }
  catch {
    $hasPy = $false
    $pyDetail = "python found on PATH but failed to execute: $($_.Exception.Message)"
  }
}
else {
  $pyDetail = 'python not found — required to install HF CLI via pip'
}

$results.Add([pscustomobject]@{
  check    = "python_present"
  category = "deps"
  ok       = $hasPy
  detail   = $pyDetail
})

# ── Output ────────────────────────────────────────────────────────────────────

if ($Json) {
  $results | ConvertTo-Json -Depth 4
  exit 0
}

# Build stable category order (first-seen order)
$seen = @{}
$categories = New-Object System.Collections.Generic.List[string]
foreach ($r in $results) {
  if (-not $seen.ContainsKey($r.category)) {
    $seen[$r.category] = $true
    $categories.Add($r.category) | Out-Null
  }
}

# Group results by category once (avoid repeated filtering)
$byCategory = @{}
foreach ($r in $results) {
  if (-not $byCategory.ContainsKey($r.category)) {
    $byCategory[$r.category] = [System.Collections.Generic.List[pscustomobject]]::new()
  }
  $byCategory[$r.category].Add($r) | Out-Null
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  GitHub + HF Ecosystem Health" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

foreach ($cat in $categories) {
  Write-Host ""
  Write-Host "  --> $($cat.ToUpper())" -ForegroundColor DarkCyan

  foreach ($item in $byCategory[$cat]) {
    Write-CheckLine $item
  }
}

# Compute failures once without pipeline
$failed = [System.Collections.Generic.List[pscustomobject]]::new()
foreach ($r in $results) {
  if (-not $r.ok) { $failed.Add($r) | Out-Null }
}

Write-Host ""
Write-Host "------------------------------------------" -ForegroundColor DarkGray

if ($failed.Count -eq 0) {
  Write-Host "  Status: READY ($($results.Count) checks passed)" -ForegroundColor Green
  Write-Host ""
  exit 0
}
else {
  Write-Host "  Status: ATTENTION REQUIRED - $($failed.Count) failing check(s):" -ForegroundColor Yellow
  foreach ($f in $failed) {
    Write-Host "    - $($f.check)" -ForegroundColor Red
  }
  Write-Host ""
  Write-Host "  See troubleshooting matrix in GITHUB_HF_ECOSYSTEM_PLAYBOOK.md" -ForegroundColor DarkGray
  Write-Host ""
  exit 1
}

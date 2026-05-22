# 📋 Changelog

All notable changes to this project are documented here.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).  
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added
- `.gitignore` covering secrets, Python caches, HF caches, OS/editor noise, and `scripts/logs/`
- `.github/ISSUE_TEMPLATE/config.yml` to point security reports at the private advisory flow
- Permissions/branches/workflow_dispatch consistency across all CI workflows

### Changed
- Moved `bug_report.md`, `feature_request.md` into `.github/ISSUE_TEMPLATE/` so GitHub auto-picks them up
- Moved `PULL_REQUEST_TEMPLATE.md` into `.github/`
- `hf-safe.cmd` now probes Python 3.10–3.14 user-scripts paths (was: hardcoded to 3.14 only)
- `ecosystem-health.yml`: added `permissions: contents: read`, scoped `pull_request` to `main`, removed redundant nested `pwsh` invocation, bumped `timeout-minutes` to 15

### Fixed
- Removed duplicate `.github/workflows/Ci.yml` (stale blank template — collided with `ci.yml` on the "CI" workflow name)
- `scripts/debug-run.cmd`: enabled `EnableDelayedExpansion` — without it, `!TS!`, `!LOGFILE!`, and `!ERRORLEVEL!` inside the `for /L` loop expanded to empty strings, breaking both log filenames and failure detection
- `scripts/debug-run.cmd`: timestamp now produced via `Get-Date` instead of locale-dependent `%DATE%`/`%TIME%` parsing
- `scripts/Run-DebugLoop.ps1`: stopped shadowing the PowerShell automatic variable `$args`; auto-detects `pwsh` vs `powershell.exe`; pre-flight check that the health script path exists
- README, SECURITY, CONTRIBUTING, CHANGELOG: replaced stale `blank.yml` references with `ci.yml`, and replaced placeholder GitHub paths with the real repo path

### Planned
- HF Spaces health check in `ecosystem-health.ps1`
- SHA-pinned action versions for supply chain hardening
- `requirements.txt` with pinned `huggingface_hub` version

---

## [1.2.0] — 2025-05-10

### Added
- `ecosystem-health.ps1`: `-Verbose` flag to show full detail on passing checks
- `ecosystem-health.ps1`: `gh_api_user` check — verifies GitHub API reachability, not just token presence
- `ecosystem-health.ps1`: `python_present` check — confirms Python is available for HF CLI install
- `ecosystem-health.ps1`: `working_directory` check — displays evaluated path to prevent "wrong folder" confusion
- `ecosystem-health.ps1`: Color-coded output per check (green/red) via `Write-Host -ForegroundColor`
- `ecosystem-health.ps1`: Category grouping (`workspace` / `github` / `huggingface` / `secrets` / `deps`)
- `hf-safe.cmd`: Full actionable install instructions in error output
- `hf-safe.cmd`: `HF_TOKEN` presence warning on both error and success paths
- `hf-safe.cmd`: `EnableDelayedExpansion` for safe variable handling in future extensions
- `ci.yml`: `timeout-minutes: 10` to prevent runaway jobs
- `ci.yml`: `pip` caching via `actions/cache@v4` — reduces install time on repeat runs
- `ci.yml`: Step `id:` fields on all tracked steps for outcome reporting
- `ci.yml`: Dynamic job summary — each row reads real `.outcome` (`success`/`failure`) via `steps.<id>.outcome`
- `ci.yml`: `continue-on-error: true` on version check steps — CLI version drift no longer blocks auth checks
- `ci.yml`: Datasets check added to no-cost metadata step
- `github-hf-no-cost-checks.yml`: Same improvements as `ci.yml` above
- `SECURITY.md`: Full security policy with vulnerability reporting, token rules, CI permissions, dependency pinning, checklist
- `README.md`: Full project documentation with structure diagram, quick start, troubleshooting matrix, setup checklist
- `CONTRIBUTING.md`: Branch naming, commit style, PR process, security rules for contributors
- `.gitignore`: Comprehensive ignore rules for secrets, envs, build artifacts, OS files
- `LICENSE`: MIT license

### Fixed
- `ecosystem-health.ps1`: Removed top-level `$ErrorActionPreference = "Stop"` — previously caused entire script to abort silently on any unhandled error
- `ecosystem-health.ps1`: `Resolve-Path` now guarded by `Test-Path` — previously threw a terminating error if `hf-safe.cmd` was missing
- `ci.yml` / `github-hf-no-cost-checks.yml`: `"on":` now properly quoted — unquoted `on` is parsed as boolean `true` by YAML parsers, breaking `actionlint` and third-party validators
- `ci.yml`: Job summary no longer hardcodes `✅` — previously always showed green regardless of actual step results

---

## [1.1.0] — Initial template release

### Added
- `hf-safe.cmd`: Safe HF CLI wrapper with absolute path fallback
- `scripts/ecosystem-health.ps1`: Basic health checker for gh + hf CLI
- `scripts/ecosystem-health.cmd`: Batch launcher for PS1 script
- `templates/github/workflows/github-hf-no-cost-checks.yml`: Portable CI template
- `GITHUB_HF_ECOSYSTEM_PLAYBOOK.md`: Full local + CI operating model
- `HF_CURSOR_CONTROL_PLANE_PLAYBOOK.md`: HF + Cursor startup and debug guide

---

[Unreleased]: https://github.com/SakThai69/github-hf-ecosystem-workflow/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/SakThai69/github-hf-ecosystem-workflow/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/SakThai69/github-hf-ecosystem-workflow/releases/tag/v1.1.0

# 📋 Changelog

All notable changes to this project are documented here.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).  
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

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
- `blank.yml`: `timeout-minutes: 10` to prevent runaway jobs
- `blank.yml`: `pip` caching via `actions/cache@v4` — reduces install time on repeat runs
- `blank.yml`: Step `id:` fields on all tracked steps for outcome reporting
- `blank.yml`: Dynamic job summary — each row reads real `.outcome` (`success`/`failure`) via `steps.<id>.outcome`
- `blank.yml`: `continue-on-error: true` on version check steps — CLI version drift no longer blocks auth checks
- `blank.yml`: Datasets check added to no-cost metadata step
- `github-hf-no-cost-checks.yml`: Same improvements as `blank.yml` above
- `SECURITY.md`: Full security policy with vulnerability reporting, token rules, CI permissions, dependency pinning, checklist
- `README.md`: Full project documentation with structure diagram, quick start, troubleshooting matrix, setup checklist
- `CONTRIBUTING.md`: Branch naming, commit style, PR process, security rules for contributors
- `.gitignore`: Comprehensive ignore rules for secrets, envs, build artifacts, OS files
- `LICENSE`: MIT license

### Fixed
- `ecosystem-health.ps1`: Removed top-level `$ErrorActionPreference = "Stop"` — previously caused entire script to abort silently on any unhandled error
- `ecosystem-health.ps1`: `Resolve-Path` now guarded by `Test-Path` — previously threw a terminating error if `hf-safe.cmd` was missing
- `blank.yml` / `github-hf-no-cost-checks.yml`: `"on":` now properly quoted — unquoted `on` is parsed as boolean `true` by YAML parsers, breaking `actionlint` and third-party validators
- `blank.yml`: Job summary no longer hardcodes `✅` — previously always showed green regardless of actual step results

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

[Unreleased]: https://github.com/YOUR_USERNAME/YOUR_REPO/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/YOUR_USERNAME/YOUR_REPO/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/YOUR_USERNAME/YOUR_REPO/releases/tag/v1.1.0

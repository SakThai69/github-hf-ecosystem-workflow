# GitHub + Hugging Face Ecosystem Playbook

Practical, no-cost workflow to operate GitHub and Hugging Face together using env-based auth and safe checks.

## Current Workspace State

- Git repository: initialized; CI is wired via `.github/workflows/ci.yml`.
- Existing HF control-plane assets:
  - `HF_CURSOR_CONTROL_PLANE_PLAYBOOK.md`
  - `hf-safe.cmd` (Python user-scripts fallback for `hf.exe`)
- Hugging Face MCP server: configured via Cursor's `mcp.json` using `Bearer ${HF_TOKEN}`.

## Security Model (Env-First)

- Never store tokens in repo files, scripts, or markdown.
- Use environment variables and native credential stores only.
- Recommended variables:
  - `HF_TOKEN` for Hugging Face (read-only preferred for routine checks)
  - `GITHUB_TOKEN` only for CI jobs (scoped by workflow `permissions`)
- Local auth should rely on:
  - `gh auth login` / keyring-managed session
  - `hf auth login` or `HF_TOKEN` env var

PowerShell examples (session-scoped):

```powershell
$env:HF_TOKEN = "<set-temporarily>"
$env:GITHUB_TOKEN = "<only-when-needed>"
```

## Check / Run / Improve / Debug Loop

Run from workspace root with:

```powershell
.\scripts\ecosystem-health.ps1
```

Loop:

1. **Check**: validate tool presence + auth + safe read checks (`gh`, `hf`, HF MCP).
2. **Run**: execute no-cost metadata/list commands only.
3. **Improve**: fix missing auth, path issues, scope mismatches.
4. **Debug**: use troubleshooting matrix below and re-run health script.

## Local Dev Flow (No-Cost)

1. Run `.\scripts\ecosystem-health.ps1`.
2. Confirm:
   - `gh auth status` succeeds.
   - `hf auth whoami` succeeds.
   - HF MCP `hf_whoami` is valid from Cursor tools.
3. Use safe operational commands:
   - `gh repo view OWNER/REPO`
   - `gh issue list --limit 10`
   - `hf models list --search "text-generation" --limit 5`
   - `hf datasets list --search "instruction" --limit 5`
4. If any check fails, apply matrix fixes, then rerun script.

## CI Flow (GitHub Actions, Non-Destructive)

Active workflows in this repo:

- `.github/workflows/ci.yml` — main Linux CI: auth + no-cost HF metadata read.
- `.github/workflows/ecosystem-health.yml` — Windows runner for the PowerShell debug loop.

A portable template (for bootstrapping new repos) is also kept at:

- `templates/github/workflows/github-hf-no-cost-checks.yml`

When setting up CI on a new repo:

1. Copy a template to `.github/workflows/`.
2. Add Actions secret `HF_TOKEN` (read-only token).
3. Push branch and trigger the workflow.

CI policy:

- No uploads/deletes/jobs/endpoints.
- Only version/auth/read-list checks.
- Fail fast on auth or CLI drift.

## Operational Command Set

- **Health baseline**
  - `.\scripts\ecosystem-health.ps1`
- **GitHub auth + capability**
  - `gh auth status`
  - `gh api user`
- **HF auth + capability**
  - `.\hf-safe.cmd auth whoami`
  - `.\hf-safe.cmd models list --search "mcp" --limit 3`
- **MCP verification prompt**
  - "Run `hf_whoami`, then `hub_repo_search` for `text-generation` with a low limit and summarize."

## Troubleshooting Matrix (Auth Mismatch States)

| State | Symptom | Likely Cause | Fix |
|---|---|---|---|
| GH red, HF green | `gh auth status` fails, HF checks pass | GitHub CLI session expired or not logged in | Run `gh auth login`, then `gh auth status` |
| GH green, HF CLI red | GH works, `hf auth whoami` fails | Missing `HF_TOKEN` or stale local token | Run `hf auth login` or set `HF_TOKEN` |
| HF CLI green, HF MCP red | CLI works but MCP tool fails | Cursor process missing env update or MCP config mismatch | Verify `mcp.json` uses `Bearer ${HF_TOKEN}` and restart Cursor |
| Both red | Both CLIs fail | PATH/session corruption | Re-open shell, verify binaries, then re-auth |
| CI red, local green | Workflow fails but local checks pass | Missing `HF_TOKEN` secret in repo or permission mismatch | Add/update Actions secret and confirm workflow permissions |

## Manual Steps Still Required

1. Initialize or open a git repository where CI should run.
2. Copy workflow template into `.github/workflows/`.
3. Add `HF_TOKEN` as GitHub Actions secret in that repository.
4. Run `.\scripts\ecosystem-health.ps1` before first CI run.

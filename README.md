# 🤖 GitHub + Hugging Face Ecosystem

> A production-ready, **no-cost**, read-only automation stack connecting GitHub Actions with the Hugging Face ecosystem — built for AI/ML developers who want safe, reliable CI without surprises.

[![CI](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/blank.yml/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/blank.yml)
[![Security Policy](https://img.shields.io/badge/security-policy-blue?logo=github)](SECURITY.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![HF Token: read-only](https://img.shields.io/badge/HF%20token-read--only-orange?logo=huggingface)](https://huggingface.co/settings/tokens)
[![PowerShell 5.1+](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)](https://learn.microsoft.com/en-us/powershell/)

---

## 📋 Table of Contents

- [✨ Overview](#-overview)
- [🗂️ Repository Structure](#️-repository-structure)
- [⚡ Quick Start](#-quick-start)
- [🔐 Security Model](#-security-model)
- [🛠️ Scripts](#️-scripts)
- [⚙️ GitHub Actions Workflows](#️-github-actions-workflows)
- [🤗 Hugging Face Integration](#-hugging-face-integration)
- [🔄 Check / Run / Improve / Debug Loop](#-check--run--improve--debug-loop)
- [🚨 Troubleshooting](#-troubleshooting)
- [📦 Setup Checklist](#-setup-checklist)
- [📚 References](#-references)

---

## ✨ Overview

This repository provides a **complete operating model** for working with GitHub and Hugging Face together — locally via CLI and MCP, and in CI via GitHub Actions.

```
┌─────────────────────────────────────────────────────────┐
│                  Your Workspace (Local)                  │
│                                                          │
│  ┌─────────────┐    ┌──────────────┐    ┌────────────┐  │
│  │  hf-safe.cmd│───▶│ HF CLI (hf)  │───▶│ HF API     │  │
│  └─────────────┘    └──────────────┘    └────────────┘  │
│         │                                                │
│  ┌──────▼──────────────────────────────────────────┐    │
│  │         ecosystem-health.ps1                    │    │
│  │  workspace · github · huggingface · secrets     │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                          │
                    push / PR
                          │
┌─────────────────────────▼───────────────────────────────┐
│              GitHub Actions (CI)                         │
│                                                          │
│  ✅ Checkout  →  🐍 Python  →  📦 HF CLI               │
│  🔐 GH Auth   →  🤗 HF Auth  →  📊 Metadata Read        │
│  📋 Job Summary (real ✅/❌ per step)                   │
└─────────────────────────────────────────────────────────┘
```

### 🎯 Key Principles

| Principle | Detail |
|---|---|
| 🔒 **Env-first security** | Zero tokens in any file — env vars and credential stores only |
| 💸 **No-cost by default** | Read-only ops only — no GPU, no uploads, no endpoints |
| 🩺 **Health-first** | Run `ecosystem-health.ps1` before every CI push |
| 🚫 **Fail fast** | Auth or CLI drift fails immediately with clear error messages |
| 🔁 **Repeatable** | Every check is idempotent and safe to rerun anytime |

---

## 🗂️ Repository Structure

```
📦 your-repo/
├── 📁 .github/
│   └── 📁 workflows/
│       └── 📄 blank.yml               # ← Main CI workflow (start here)
│
├── 📁 scripts/
│   ├── 📄 ecosystem-health.ps1        # ← Local health checker (PowerShell)
│   └── 📄 ecosystem-health.cmd        # ← Batch launcher for the PS1 script
│
├── 📁 templates/
│   └── 📁 github/
│       └── 📁 workflows/
│           └── 📄 github-hf-no-cost-checks.yml  # ← Standalone CI template
│
├── 📄 hf-safe.cmd                     # ← Safe HF CLI wrapper
├── 📄 SECURITY.md                     # ← Security policy & vulnerability reporting
├── 📄 CONTRIBUTING.md                 # ← Contribution guidelines
├── 📄 CHANGELOG.md                    # ← Version history
├── 📄 .gitignore                      # ← Ignores secrets, local envs, build artifacts
├── 📄 LICENSE                         # ← MIT License
└── 📄 README.md                       # ← You are here
```

---

## ⚡ Quick Start

### 1️⃣ Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
```

### 2️⃣ Add your HF Token as a GitHub Actions secret

```
GitHub repo → Settings → Secrets and variables → Actions → New repository secret

Name:   HF_TOKEN
Value:  hf_xxxxxxxxxxxxxxxxxxxx   ← read-only token from huggingface.co/settings/tokens
```

### 3️⃣ Run the local health check

```powershell
.\scripts\ecosystem-health.ps1
```

Expected output:
```
══════════════════════════════════════════
  GitHub + HF Ecosystem Health
══════════════════════════════════════════

  ▸ WORKSPACE
[OK]  workspace_git_repo
[OK]  working_directory

  ▸ GITHUB
[OK]  gh_cli_present
[OK]  gh_auth_status
[OK]  gh_api_user

  ▸ HUGGINGFACE
[OK]  hf_wrapper_present
[OK]  hf_version
[OK]  hf_auth_whoami
[OK]  hf_safe_models_list

  ▸ SECRETS
[OK]  hf_token_env_present

  ▸ DEPS
[OK]  python_present

──────────────────────────────────────────
  Status: READY ✓  (11 checks passed)
```

### 4️⃣ Push to main — CI runs automatically

```bash
git add .
git commit -m "chore: initial setup"
git push origin main
```

---

## 🔐 Security Model

> Full details in [`SECURITY.md`](SECURITY.md)

### Token Rules

```
✅ DO                              ❌ DON'T
─────────────────────────────      ──────────────────────────────────
Use $env:HF_TOKEN (session)        Hardcode tokens in any file
Use secrets.HF_TOKEN in CI         Commit tokens to git history
Use read-only HF tokens            Grant write/admin token scopes
Rotate on suspected exposure       Log or echo token values
Use Bearer ${HF_TOKEN} in MCP      Store tokens in mcp.json literally
```

### CI Permissions

Every workflow enforces the minimum:

```yaml
permissions:
  contents: read   # read-only — no write, no packages, no deployments
```

### Environment Variables

| Variable | Where | Purpose |
|---|---|---|
| `HF_TOKEN` | Shell session / system env | HF CLI + MCP auth |
| `GITHUB_TOKEN` | CI only (auto-injected) | GH API scoped to `contents: read` |
| `GH_TOKEN` | CI auth step only | Passed via `env:` block, never stored |

---

## 🛠️ Scripts

### `ecosystem-health.ps1`

Full local health checker. Groups checks by category and outputs color-coded results.

```powershell
# Standard run
.\scripts\ecosystem-health.ps1

# With full detail on passing checks
.\scripts\ecosystem-health.ps1 -Verbose

# JSON output (for scripting/CI)
.\scripts\ecosystem-health.ps1 -Json
```

**Check categories:**

| Category | Checks |
|---|---|
| `workspace` | `.git` repo present, working directory path |
| `github` | `gh` CLI present, auth status, API user |
| `huggingface` | `hf-safe.cmd` present, HF version, auth whoami, models list |
| `secrets` | `HF_TOKEN` set in shell |
| `deps` | Python present (required for HF CLI install) |

---

### `hf-safe.cmd`

Safe wrapper for the HF CLI. Tries the absolute Python user-scripts path first, then falls back to `PATH`. Never stores or prints tokens.

```cmd
REM Auth check
.\hf-safe.cmd auth whoami

REM Safe model discovery (no cost)
.\hf-safe.cmd models list --search "text-generation" --limit 5

REM Dataset discovery
.\hf-safe.cmd datasets list --search "instruction" --limit 5
```

**Fallback resolution order:**
```
1. %USERPROFILE%\AppData\Roaming\Python\Python314\Scripts\hf.exe
2. hf on PATH
3. ERROR with install instructions
```

---

## ⚙️ GitHub Actions Workflows

### `blank.yml` — Main CI Workflow

The primary workflow. Triggered on `push`, `pull_request` (both targeting `main`), and `workflow_dispatch`.

**Step execution order:**

```
Checkout
  └─▶ Setup Python 3.x
        └─▶ Cache pip (~/.cache/pip)
              └─▶ Install HF CLI
                    ├─▶ [info] Verify GH CLI version   (continue-on-error)
                    ├─▶ [info] Verify HF CLI version   (continue-on-error)
                    ├─▶ [FAIL] GitHub auth check
                    ├─▶ [FAIL] Hugging Face auth check
                    ├─▶ [FAIL] No-cost HF metadata check
                    ├─▶         Run a one-line script
                    ├─▶         Run a multi-line script
                    └─▶ [always] Write job summary (real ✅/❌)
```

### `github-hf-no-cost-checks.yml` — Standalone Template

Portable version that also triggers on `master` branch. Use this when setting up a new repo.

```bash
cp templates/github/workflows/github-hf-no-cost-checks.yml .github/workflows/
```

---

## 🤗 Hugging Face Integration

### MCP Server (Cursor)

File: `C:\Users\gensa\.cursor\mcp.json`

Required auth pattern:
```json
{
  "Authorization": "Bearer ${HF_TOKEN}"
}
```

> ⚠️ After updating `HF_TOKEN` in your environment, **restart Cursor** — it reads env vars at launch time.

### Common Discovery Commands

```powershell
# 🔍 Find models for a task
hf models list --search "text-generation" --limit 5

# 📚 Find datasets
hf datasets list --search "instruction tuning" --limit 5

# 🚀 Find Spaces
hf spaces list --search "gradio" --limit 5
```

### MCP Prompt Templates

```
# Model discovery
"Find 5 open models for [task] sorted by likes, include links."

# Dataset search
"Search datasets for [topic], return top 5 with license tags."

# Docs lookup
"Search Hugging Face docs for [feature] and summarize exact steps."

# Health verify
"Run hf_whoami, then hub_repo_search for text-generation with limit 3."
```

---

## 🔄 Check / Run / Improve / Debug Loop

```
┌─────────────────────────────────────────┐
│                                         │
│   1. CHECK                              │
│      .\scripts\ecosystem-health.ps1    │
│                                         │
│          ↓ all green?                  │
│                                         │
│   2. RUN (no-cost ops only)            │
│      hf models list / gh issue list    │
│                                         │
│          ↓ issue found?                │
│                                         │
│   3. IMPROVE                           │
│      Fix auth · PATH · token scope     │
│                                         │
│          ↓ still failing?              │
│                                         │
│   4. DEBUG                             │
│      See troubleshooting matrix ↓      │
│      Re-run health script              │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🚨 Troubleshooting

| State | Symptom | Likely Cause | Fix |
|---|---|---|---|
| 🔴 GH · 🟢 HF | `gh auth status` fails | GitHub CLI session expired | `gh auth login` |
| 🟢 GH · 🔴 HF CLI | `hf auth whoami` fails | Missing/stale `HF_TOKEN` | `hf auth login` or set `HF_TOKEN` |
| 🟢 HF CLI · 🔴 MCP | CLI works, MCP tool fails | Cursor missing env update | Verify `mcp.json`, restart Cursor |
| 🔴 Both | All CLIs fail | PATH/session corruption | Re-open shell, verify binaries, re-auth |
| 🔴 CI · 🟢 Local | Workflow fails, local passes | Missing `HF_TOKEN` Actions secret | Add secret → Settings → Secrets → Actions |

### Quick Debug Commands

```powershell
# Check GitHub CLI auth
gh auth status

# Check HF CLI auth (absolute path)
.\hf-safe.cmd auth whoami

# Check HF token is set in shell
echo $env:HF_TOKEN   # PowerShell
echo %HF_TOKEN%      # CMD

# Scan git history for accidentally committed tokens
git log --all -S "hf_" --oneline

# Force re-auth GitHub
gh auth login

# Force re-auth HF
hf auth login
```

---

## 📦 Setup Checklist

Copy this checklist to your repo's first issue or project board:

```markdown
### First-Time Setup

- [ ] Repository cloned locally
- [ ] `gh auth login` completed
- [ ] `hf auth login` completed (or `HF_TOKEN` set in shell)
- [ ] `HF_TOKEN` is read-only scope on huggingface.co/settings/tokens
- [ ] `HF_TOKEN` added as GitHub Actions secret
- [ ] `mcp.json` uses `Bearer ${HF_TOKEN}` (no literal token)
- [ ] `.\scripts\ecosystem-health.ps1` — all checks pass (Status: READY ✓)
- [ ] Pushed to main — CI workflow passes
- [ ] Job summary shows all ✅ in Actions tab
- [ ] No tokens in git history: `git log --all -S "hf_" --oneline` returns nothing
```

---

## 📚 References

### Internal Docs

| File | Purpose |
|---|---|
| [`SECURITY.md`](SECURITY.md) | Vulnerability reporting, token rules, CI permissions |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | How to contribute, branch naming, PR process |
| [`CHANGELOG.md`](CHANGELOG.md) | Version history and release notes |
| [`GITHUB_HF_ECOSYSTEM_PLAYBOOK.md`](GITHUB_HF_ECOSYSTEM_PLAYBOOK.md) | Full operating model reference |
| [`HF_CURSOR_CONTROL_PLANE_PLAYBOOK.md`](HF_CURSOR_CONTROL_PLANE_PLAYBOOK.md) | HF + Cursor-specific startup and debug guide |

### External Links

| Resource | URL |
|---|---|
| GitHub Actions security hardening | https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions |
| Hugging Face token management | https://huggingface.co/settings/tokens |
| GitHub encrypted secrets | https://docs.github.com/en/actions/security-guides/encrypted-secrets |
| GitHub CLI install | https://cli.github.com |
| Hugging Face CLI docs | https://huggingface.co/docs/huggingface_hub/guides/cli |
| actionlint (YAML validator) | https://github.com/rhysd/actionlint |

---

## 📄 License

MIT © [YOUR_NAME]  
See [`LICENSE`](LICENSE) for full terms.

---

<div align="center">

Built with 🤗 Hugging Face · ⚡ GitHub Actions · 🛡️ env-first security

</div>

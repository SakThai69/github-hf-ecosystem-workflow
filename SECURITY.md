# Security Policy

## Overview

This repository operates a **GitHub + Hugging Face ecosystem** with strict no-cost, read-only defaults. All automation follows an env-first security model: no tokens are ever stored in code, scripts, or markdown.

---

## Supported Versions

| Component | Supported |
|---|---|
| `scripts/ecosystem-health.ps1` | ✅ Current |
| `hf-safe.cmd` | ✅ Current |
| `.github/workflows/blank.yml` | ✅ Current |
| `templates/github/workflows/github-hf-no-cost-checks.yml` | ✅ Current |

---

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

To report a vulnerability:

1. Go to the **Security** tab of this repository.
2. Click **"Report a vulnerability"** to open a private advisory.
3. Include as much detail as possible:
   - Affected file(s) and line numbers
   - Steps to reproduce
   - Potential impact
   - Suggested fix (optional)

You will receive an acknowledgement within **48 hours** and a resolution or status update within **7 days**.

---

## Security Model

### Token & Secret Handling

| Rule | Detail |
|---|---|
| Never store tokens in files | No tokens in `.cmd`, `.ps1`, `.yml`, `.md`, or any repo file |
| Never hardcode in `mcp.json` | Auth header must use `Bearer ${HF_TOKEN}` — never a literal token |
| Never log or echo tokens | Redact all token values in logs and screenshots |
| Use least-privilege tokens | Prefer read-only HF tokens for routine checks |
| Rotate on suspected exposure | Immediately invalidate and replace any leaked token |

### Environment Variables

| Variable | Scope | Purpose |
|---|---|---|
| `HF_TOKEN` | Shell session or system env | Hugging Face CLI and MCP auth (read-only preferred) |
| `GITHUB_TOKEN` | CI workflows only | Scoped automatically by `permissions: contents: read` |
| `GH_TOKEN` | CI auth check step only | Passed via `env:` block, never stored |

PowerShell — session-scoped only (never persisted to profile unless explicitly chosen):

```powershell
$env:HF_TOKEN = "<temporary-read-only-token>"
```

### CI Workflow Permissions

All GitHub Actions workflows enforce minimal permissions at the job level:

```yaml
permissions:
  contents: read
```

No workflow in this repository performs uploads, deletes, endpoint creation, or GPU job submission.

---

## Prohibited Operations

The following are **never permitted** in any workflow, script, or prompt in this repository:

- Uploading models, datasets, or files to Hugging Face
- Creating or starting HF Inference Endpoints or Jobs
- Deleting repos, files, or objects on any platform
- Granting write or admin scopes to any token
- Storing tokens in committed files or environment variable exports in dotfiles

---

## Dependency Security

| Dependency | Pinning Policy |
|---|---|
| `actions/checkout` | Pinned to `@v4` |
| `actions/setup-python` | Pinned to `@v5` |
| `actions/cache` | Pinned to `@v4` |
| `huggingface_hub[cli]` | Installed via `pip install --upgrade` (latest stable) |

**Recommendation:** For production environments, pin `huggingface_hub` to a specific version in `requirements.txt` and reference it via `hashFiles` in the pip cache key.

---

## Known Security Considerations

### `hf-safe.cmd` — Absolute Path Fallback

`hf-safe.cmd` tries a hardcoded absolute path (`%USERPROFILE%\AppData\Roaming\Python\Python314\Scripts\hf.exe`) before falling back to `PATH`. This path is user-scoped and non-privileged. If your Python installation is in a different location, update the `HF_FALLBACK` variable accordingly.

### `"on":` YAML Quoting

The workflow trigger key is written as `"on":` (quoted) to prevent YAML parsers from interpreting it as the boolean `true`. This is required for compatibility with `actionlint` and third-party CI validators.

### MCP Server Auth

The Hugging Face MCP server in Cursor must use:

```json
{ "Authorization": "Bearer ${HF_TOKEN}" }
```

Never substitute a literal token string. If Cursor does not pick up an updated `HF_TOKEN`, restart the Cursor process — it reads env vars at launch time.

---

## Security Checklist (Before First CI Run)

- [ ] `HF_TOKEN` added as GitHub Actions secret (Settings → Secrets → Actions)
- [ ] `HF_TOKEN` is read-only scope on Hugging Face
- [ ] No tokens committed to any file in the repository (`git log --all -S "hf_"` to verify)
- [ ] `mcp.json` uses `Bearer ${HF_TOKEN}` — not a literal token
- [ ] `.\scripts\ecosystem-health.ps1` passes all checks locally
- [ ] Workflow `permissions` block is `contents: read` only

---

## References

- [GitHub Actions security hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Hugging Face token management](https://huggingface.co/settings/tokens)
- [GitHub encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- Internal: `GITHUB_HF_ECOSYSTEM_PLAYBOOK.md`
- Internal: `HF_CURSOR_CONTROL_PLANE_PLAYBOOK.md`

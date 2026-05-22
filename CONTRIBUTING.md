# 🤝 Contributing

Thank you for helping improve this ecosystem! This guide covers everything you need to contribute safely and effectively.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [What You Can Contribute](#what-you-can-contribute)
- [Getting Started](#getting-started)
- [Branch Naming](#branch-naming)
- [Commit Style](#commit-style)
- [Pull Request Process](#pull-request-process)
- [Security Rules for Contributors](#security-rules-for-contributors)
- [Testing Locally Before PR](#testing-locally-before-pr)

---

## 🧭 Code of Conduct

Be respectful, constructive, and collaborative. Contributions of all skill levels are welcome.

---

## ✅ What You Can Contribute

| Type | Examples |
|---|---|
| 🐛 Bug fixes | Script errors, YAML issues, broken paths |
| ✨ Improvements | Better error messages, new health checks, additional CI steps |
| 📚 Documentation | Clearer instructions, new troubleshooting entries, playbook updates |
| 🔒 Security hardening | Token handling, permission scoping, secret scanning |
| 🧪 New checks | Additional CLI tools, Python version checks, MCP validation |

---

## 🚀 Getting Started

1. **Fork** this repository
2. **Clone** your fork:
   ```bash
   git clone https://github.com/<your-username>/github-hf-ecosystem-workflow.git
   cd github-hf-ecosystem-workflow
   ```
3. **Run the health check** to confirm your local setup is good:
   ```powershell
   .\scripts\ecosystem-health.ps1
   ```
4. **Create a branch** (see naming below)
5. Make your changes
6. **Test locally** (see section below)
7. Open a **Pull Request**

---

## 🌿 Branch Naming

```
feat/short-description        ← new feature or check
fix/short-description         ← bug fix
docs/short-description        ← documentation only
security/short-description    ← security improvement
chore/short-description       ← maintenance, deps, formatting
```

Examples:
```
feat/add-spaces-health-check
fix/hf-safe-path-fallback
docs/update-troubleshooting-matrix
security/pin-action-shas
```

---

## 📝 Commit Style

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add HF Spaces discovery to health check
fix: resolve hf-safe.cmd PATH fallback on Python 3.12
docs: add MCP restart note to troubleshooting matrix
security: quote 'on' trigger key to prevent YAML boolean parse
chore: pin actions/cache to @v4
```

---

## 🔃 Pull Request Process

1. Ensure `.\scripts\ecosystem-health.ps1` passes locally
2. Ensure the CI workflow passes on your fork
3. Fill in the PR template (auto-populated)
4. Link any related issues
5. Request review from a maintainer

PRs that introduce tokens, hardcoded credentials, or billable HF operations will be **closed immediately**.

---

## 🔐 Security Rules for Contributors

These are non-negotiable:

- **Never** commit tokens, secrets, or credentials in any file
- **Never** add steps that upload, write, or delete from HF
- **Never** increase workflow permissions beyond `contents: read`
- **Always** use `${{ secrets.HF_TOKEN }}` — never a literal token
- **Always** run `git log --all -S "hf_" --oneline` before opening a PR to verify no tokens slipped in

If you discover a security vulnerability, report it via the **Security tab** (private advisory) — not a public issue. See [`SECURITY.md`](SECURITY.md).

---

## 🧪 Testing Locally Before PR

### Scripts

```powershell
# Run full health check
.\scripts\ecosystem-health.ps1 -Verbose

# Run JSON output check (for scripting)
.\scripts\ecosystem-health.ps1 -Json | ConvertFrom-Json

# Test hf-safe wrapper
.\hf-safe.cmd auth whoami
.\hf-safe.cmd models list --search "mcp" --limit 3
```

### Workflow YAML

Validate YAML syntax before pushing:

```bash
# Using Python (available on most systems)
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))" && echo "VALID"

# Using actionlint (recommended)
# https://github.com/rhysd/actionlint
actionlint .github/workflows/*.yml
```

### Checklist Before Opening a PR

- [ ] `ecosystem-health.ps1` passes (Status: READY ✓)
- [ ] No tokens in any modified file
- [ ] YAML files parse without errors
- [ ] CI passes on your fork
- [ ] Commit messages follow Conventional Commits style
- [ ] `git log --all -S "hf_" --oneline` returns nothing

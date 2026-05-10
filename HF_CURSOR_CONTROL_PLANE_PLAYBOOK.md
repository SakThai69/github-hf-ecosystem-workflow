# Hugging Face in Cursor: Safe Control Plane Playbook

For a unified GitHub + Hugging Face operating model, see `GITHUB_HF_ECOSYSTEM_PLAYBOOK.md`.

This playbook keeps Hugging Face chat-driven workflows reliable, low-risk, and no-cost by default.

## 1) Startup checks (2-3 minutes)

1. Confirm MCP config is environment-based (no hardcoded token):
   - Check `C:\Users\gensa\.cursor\mcp.json`
   - Expected auth header pattern: `Bearer ${HF_TOKEN}`
2. Confirm CLI path and version:
   - `C:\Users\gensa\AppData\Roaming\Python\Python314\Scripts\hf.exe version`
3. Confirm CLI auth:
   - `C:\Users\gensa\AppData\Roaming\Python\Python314\Scripts\hf.exe auth whoami`
4. Confirm MCP auth:
   - Run MCP tool: `hf_whoami`
5. Confirm a no-cost read action:
   - CLI: `hf-safe.cmd models ls --search "mcp" --limit 3`
   - MCP: `hub_repo_search` or `hf_doc_search`

### Consistent CLI invocation

- Prefer `hf-safe.cmd` from the workspace root.
- `hf-safe.cmd` first tries:
  - `C:\Users\gensa\AppData\Roaming\Python\Python314\Scripts\hf.exe`
  - then plain `hf` from `PATH`.
- This avoids shell-to-shell PATH drift without storing secrets.

## 2) No-cost operating modes (default)

- Use read-only/discovery actions only:
  - `whoami`, `search`, `list`, `doc lookup`, metadata inspection.
- Avoid billable operations unless explicitly approved:
  - No Jobs/GPU training runs
  - No endpoint creation
  - No uploads, repo writes, or deletes
- Keep limits low on queries (`limit: 3-20`) to reduce noise and accidental heavy requests.

## 3) Common control-plane prompts/commands

### Models
- MCP prompt:
  - "Find 5 open models for [task] sorted by likes, include links."
- CLI:
  - `hf models list --search "text-generation" --limit 5`

### Datasets
- MCP prompt:
  - "Search datasets for [topic], return top 5 with license tags and links."
- CLI:
  - `hf datasets list --search "instruction tuning" --limit 5`

### Spaces
- MCP prompt:
  - "Find Spaces for [use case], show recently updated first."
- CLI:
  - `hf spaces list --search "gradio" --limit 5`

### Docs / API references
- MCP prompt:
  - "Search Hugging Face docs for [feature] and summarize exact steps."
- MCP tool:
  - `hf_doc_search` with concise query terms.

## 4) Debugging matrix

### CLI red, MCP green

Symptoms:
- `hf` command missing or auth failure, but MCP `hf_whoami` works.

Actions:
1. Run CLI with absolute path:
   - `C:\Users\gensa\AppData\Roaming\Python\Python314\Scripts\hf.exe auth whoami`
   - or use `hf-safe.cmd auth whoami`
2. If command not found from shell, add user scripts directory to `PATH`.
3. Re-auth CLI if needed:
   - `hf auth login` (interactive)

Likely cause:
- PATH issue or local CLI token state mismatch.

### CLI green, MCP red

Symptoms:
- CLI works, but MCP auth/read tools fail.

Actions:
1. Validate `C:\Users\gensa\.cursor\mcp.json` syntax and server URL.
2. Ensure token is env-based and loaded in Cursor environment:
   - `HF_TOKEN` set in user/system env (never hardcoded in config files).
3. Restart Cursor after env changes so MCP server picks up updated env.
4. Re-run MCP `hf_whoami`, then a read query.

Likely cause:
- Cursor process not seeing updated env vars, or MCP config mismatch.

## 5) Do not leak secrets

- Never paste tokens in chat, code files, or commit history.
- Never hardcode tokens in `mcp.json`, scripts, or markdown.
- Use environment variables (`HF_TOKEN`) and rotate tokens if exposure is suspected.
- Redact token values in logs and screenshots.
- Prefer least-privilege tokens (read-only when possible).

## 6) Optional hardening step

To make `hf` available in all new PowerShell sessions, add this to your PowerShell profile:

`$env:Path += ";C:\Users\gensa\AppData\Roaming\Python\Python314\Scripts"`

(Use persistent profile update only if desired; this is not required for MCP operation.)

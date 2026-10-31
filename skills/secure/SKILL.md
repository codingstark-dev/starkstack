---
name: secure
description: "Security audit of the user's own repo: threat model, all scanners, manual OWASP/bug-bounty review, then issue → fix → PR per finding."
argument-hint: "[scope] [--report-only]"
disable-model-invocation: true
---

# /starkstack:secure

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/07-security.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/secscan.sh` first. `--report-only` skips fixes/issues. Public repo + Critical/High → private advisory, not a public issue.

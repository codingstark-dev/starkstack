---
name: hotfix
description: "Production incident or urgent fix: mitigate first (rollback/flag), confirm recovery, root-cause fix from the deployed tag, postmortem."
argument-hint: "<symptom>"
disable-model-invocation: true
---

# /starkstack:hotfix

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/playbooks.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Run the **Hotfix / Incident** playbook. Mitigation before root cause.

## Live context
- Branch: !`git branch --show-current 2>/dev/null || true`
- Status: !`git status --short 2>/dev/null | head -30 || true`
- Recent: !`git log --oneline -8 2>/dev/null || true`

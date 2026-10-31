---
name: onboard
description: "Map an existing codebase read-only: architecture, entry points, modules, data model, conventions, risks, glossary seed."
argument-hint: "[path]"
disable-model-invocation: true
---

# /starkstack:onboard

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/playbooks.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Run the **Onboard / map** playbook. Output `.starkstack/codebase-map.md`. No code changes.

## Live context
- Stack: !`bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/detect.sh 2>/dev/null || true`

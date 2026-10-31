---
name: handoff
description: "Write a handoff so another session or agent can resume exactly; or resume from one with 'pickup'."
argument-hint: "[pickup]"
disable-model-invocation: true
---

# /starkstack:handoff

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/09-retro.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

No args → write `.starkstack/handoff.md`. `pickup` → rebuild state from handoff, decisions.log, git and open PRs, restate the plan, then continue.

## Live context
- Branch: !`git branch --show-current 2>/dev/null || true`
- Status: !`git status --short 2>/dev/null | head -30 || true`
- Recent: !`git log --oneline -8 2>/dev/null || true`

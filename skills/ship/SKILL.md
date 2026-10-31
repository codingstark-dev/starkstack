---
name: ship
description: "Ship the current branch: preflight, Conventional Commit, PR with evidence and rollback, then babysit CI and review threads."
argument-hint: "[--stack]"
disable-model-invocation: true
---

# /starkstack:ship

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/08-ship.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Stop at merge-ready and ask before merging unless --auto was granted.

## Live context
- Branch: !`git branch --show-current 2>/dev/null || true`
- Status: !`git status --short 2>/dev/null | head -30 || true`
- Recent: !`git log --oneline -8 2>/dev/null || true`

---
name: build
description: "Execute the spec wave by wave with numbered builder agents in parallel worktrees using TDD."
argument-hint: "[wave | ticket id]"
disable-model-invocation: true
---

# /starkstack:build

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/04-build.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Spawn one agent per ticket in the wave in a single message. Finish with `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/preflight.sh` and log the output.

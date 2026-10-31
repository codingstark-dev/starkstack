---
name: learn
description: "Record, list or prune durable project learnings that override starkstack defaults."
argument-hint: "[lesson | list | prune]"
disable-model-invocation: true
---

# /starkstack:learn

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/09-retro.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Run the Learn section against `.starkstack/learnings.md`.

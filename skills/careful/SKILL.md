---
name: careful
description: "Safety controls: show guard status, freeze edits to a directory, or unfreeze."
argument-hint: "[status | freeze <dir>... | unfreeze]"
disable-model-invocation: true
---

# /starkstack:careful

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/principles.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

The guard hook always blocks destructive git/fs/infra commands and secret commits. `freeze <dir>` writes the allowed path prefixes (one per line) to `.starkstack/freeze` so Edit/Write outside them is blocked; `unfreeze` deletes that file; `status` shows both.

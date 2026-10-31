---
name: research
description: "Research the latest stack, libraries, pricing and market for an idea or decision; produces an HTML or MD report with layman explanations."
argument-hint: "[topic] [--md]"
disable-model-invocation: true
---

# /starkstack:research

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/01-research.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Ask the intake questions you need (max 5); skipped answers become logged defaults. Default output is HTML; `--md` for Markdown. Fan out `researcher` agents per question.

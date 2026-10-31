---
name: autoplan
description: "Run CEO, Design, DX, Security and Eng reviews on the spec, scoring each 0–10 and fixing gaps before code."
argument-hint: "[spec path]"
disable-model-invocation: true
---

# /starkstack:autoplan

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/03-plan-review.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Surface only taste decisions to the user. Append the scorecard to spec.md. Gate: all ≥ 7 or accepted.

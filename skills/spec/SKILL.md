---
name: spec
description: "Write the PRD, architecture and tracer-bullet ticket board with numbered agents and dependency waves."
argument-hint: "[feature] [--github]"
disable-model-invocation: true
---

# /starkstack:spec

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/02-spec.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Output `.starkstack/spec.md` from the template. `--github` mirrors it as an Epic + sub-issues (labels agent:/wave:/size:).

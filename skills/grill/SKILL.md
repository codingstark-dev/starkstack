---
name: grill
description: "Interview the user about a plan until every design branch is resolved; updates GLOSSARY.md and ADRs."
argument-hint: "[plan or topic]"
disable-model-invocation: true
---

# /starkstack:grill

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/00-intake.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Run §5 Grilling: one branch at a time, riskiest first, 2–3 options each with your recommendation. Write answers to GLOSSARY.md / ADRs as you go. Stop when remaining unknowns wouldn't change the architecture.

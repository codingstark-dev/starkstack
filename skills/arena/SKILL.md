---
name: arena
description: "Compare 2–3 competing designs or implementations in separate worktrees, judged by a separate agent against a private rubric."
argument-hint: "<design question>"
disable-model-invocation: true
---

# /starkstack:arena

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/playbooks.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Run the **Prototype / Arena** playbook; finish with an ADR and delete the prototypes.

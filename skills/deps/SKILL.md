---
name: deps
description: "Upgrade outdated or vulnerable dependencies safely: batch minors, one PR per major with changelog review."
argument-hint: "[package | --security-only]"
disable-model-invocation: true
---

# /starkstack:deps

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/playbooks.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Run the **Dependency upgrade** playbook.

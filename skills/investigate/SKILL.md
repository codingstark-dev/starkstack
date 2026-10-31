---
name: investigate
description: "Root-cause a bug or explain how/why code works; reproduce first, no fix before the cause is proven."
argument-hint: "<bug | question>"
disable-model-invocation: true
---

# /starkstack:investigate

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/playbooks.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Bugs → **Bug fix** playbook (Iron Law, stop after 3 failed fixes). Questions → **Investigation** playbook (read-only, facts vs inference).

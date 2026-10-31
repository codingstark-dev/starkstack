---
name: qa
description: "QA pass: test plan from acceptance criteria, Playwright e2e, real-browser exploratory testing, a11y and performance."
argument-hint: "[url | feature]"
disable-model-invocation: true
---

# /starkstack:qa

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/06-qa.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Write `.starkstack/qa-report.md`. Create a project `verify-<app>` skill if missing.

---
name: review
description: "Staff-engineer code review of the current branch or a PR: spec + standards, model panel for risky diffs, blast radius."
argument-hint: "[PR number]"
disable-model-invocation: true
---

# /starkstack:review

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/05-review.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Use `reviewer` agents (different models for risky diffs). Bucket findings act-on / consider / noted / dismissed.

## Live context
- Diff stat: !`git diff --stat origin/main...HEAD 2>/dev/null | tail -20 || true`

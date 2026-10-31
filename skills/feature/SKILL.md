---
name: feature
description: "Add a feature to an EXISTING codebase without breaking anything: baseline snapshot, compatibility matrix across APIs, agents, links, data and integrations, additive design behind a flag, regression gate."
argument-hint: "<feature description>"
disable-model-invocation: true
---

# /starkstack:feature

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/10-feature.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Run the **Brownfield feature** playbook end to end. Don't start building until the baseline and compatibility matrix gates pass.

## Live context
- Stack: !`bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/detect.sh 2>/dev/null || true`
- Branch: !`git branch --show-current 2>/dev/null || true`
- Status: !`git status --short 2>/dev/null | head -30 || true`
- Recent: !`git log --oneline -8 2>/dev/null || true`

---
name: migrate
description: "Migrate a codebase to a new stack, framework, database or host: migration docs, characterization tests, strangler-fig cutover, verified data migration, then removal of obsolete code and infra."
argument-hint: "<from> -> <to>"
disable-model-invocation: true
---

# /starkstack:migrate

Read `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/SKILL.md` (router, gates, defaults), then `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/references/11-migrate.md`, and run it for: **$ARGUMENTS**

Scripts: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/` · Templates: `${CLAUDE_PLUGIN_ROOT}/skills/starkstack/assets/` · State: `.starkstack/` (run `bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/init.sh` if missing).

Run the **Migration** playbook. Write `docs/migration/` and get approval before any cutover. Use the `migration-lead` agent. Destructive steps always need confirmation.

## Live context
- Stack: !`bash ${CLAUDE_PLUGIN_ROOT}/skills/starkstack/scripts/detect.sh 2>/dev/null || true`

---
name: starkstack
description: A whole-engineer operating mode — a virtual team of Researcher, Spec Architect, Plan Reviewers, numbered Builder agents, Code Reviewer, QA Tester, Security Tester (AppSec/bug-bounty), Release Engineer and Tech Writer, run as gated playbooks with evidence. Use it for any non-trivial engineering work — building a product, feature, MVP, API or app; researching a stack or market; writing specs, PRDs or task boards; adding features to an existing codebase without breaking it; migrating to a new stack or database; fixing bugs; refactors; performance; code review; QA; security scans and audits; raising GitHub issues, fix PRs, CI, merge and deploy; retros and docs — even when the user just says "let's build X", "plan this", "fix this bug", "audit my repo", "ship it", or names a phase like /research, /spec, /qa, /secure or /ship. Skip it for one-line answers and trivial edits.
---

# starkstack — one engineer, every role

A full software team, run as **playbooks** with **gates** and **evidence**.
It borrows the best ideas from the most-used skill packs, follows **your**
stack and conventions (see Defaults), and ships through GitHub.

- From **gstack**: one role per command, scored plan reviews, CSO audits,
  canary checks, retros.
- From **pstack**: playbooks copied into the task list, model panels, arenas,
  blast radius, decision logs, verify-app skills.
- From **Matt Pocock's skills**: grilling, a shared glossary, ADRs,
  tracer-bullet tickets, TDD on vertical slices.
- From **superpowers**: brainstorm before building, written plans, subagent
  development, verification before completion, worktrees.

Arguments: `$ARGUMENTS`

## 1 · Route the request to a playbook

Read `references/playbooks.md` and pick the playbook that matches the request:

| Request looks like… | Playbook |
|---|---|
| "build X" from scratch, new product or MVP | **Greenfield** (full pipeline) |
| add a feature to an **existing** codebase | **Brownfield feature** → `references/10-feature.md` |
| move to a new stack, framework, DB or host; replace a library | **Migration** → `references/11-migrate.md` |
| understand a codebase you just opened | **Onboard / map** |
| bug, error, failing test, "broken" | **Bug fix** |
| production is down or a hotfix is needed | **Hotfix / Incident** |
| restructure or clean up (same stack) | **Refactor** |
| outdated or vulnerable dependencies | **Dependency upgrade** |
| slow, latency, bundle size, cost | **Performance** |
| "audit", "scan", "is this secure" | **Security audit** |
| "how does X work", "why is X like this" | **Investigation** (read-only) |
| "should we use A or B", unsure design | **Prototype / Arena** |
| a single phase name (/qa, /ship, …) | that phase only |

**Copy the chosen playbook's steps into the task list exactly as written**
(TaskCreate, or a visible checklist if there's no task tool). If you skip a
step, leave it in the list and record why, for example "skipped: no UI in this
change". The written list is what stops a long run from silently dropping the
boring steps, and it's how the user sees progress when they step away.

Flags:
- `--fast` compresses research and plan review for small changes.
- `--auto` grants auto-merge and deploy on green CI (otherwise ask).

## 2 · Intake (every playbook starts here)

Read `references/00-intake.md`. In short:

- Inspect the repo first.
- Ask at most 5 questions in one batch.
- If a question is skipped, take the default and log it as `ASSUMED`.
- Never block waiting on an answer.

Then run `scripts/init.sh` to create the `.starkstack/` working state.

## 3 · Run the phases

Read **only** the reference for the phase you're in, to keep context lean.

| # | Phase | Role | Reference |
|---|---|---|---|
| 1 | Research | Staff engineer + market analyst | `references/01-research.md` |
| 2 | Spec | Engineering manager | `references/02-spec.md` |
| 3 | Plan review | CEO, Eng, Design, DX, Security reviewers | `references/03-plan-review.md` |
| 4 | Build | Numbered builder agents | `references/04-build.md` |
| 5 | Code review | Staff engineer panel | `references/05-review.md` |
| 6 | QA | QA lead | `references/06-qa.md` |
| 7 | Security | CSO / bug-bounty hunter | `references/07-security.md` |
| 8 | Ship | Release engineer + SRE | `references/08-ship.md` |
| 9 | Retro & learn | Eng manager + tech writer | `references/09-retro.md` |
| F | Brownfield feature | Compatibility engineer | `references/10-feature.md` |
| M | Migration | Migration lead + DBA | `references/11-migrate.md` |

Slash commands (`/starkstack:<name>`):

- **Pipeline:** `research`, `grill`, `spec`, `autoplan`, `build`
- **Quality:** `review`, `qa`, `secure`
- **Delivery:** `ship`, `land`, `retro`
- **Existing codebases:** `onboard`, `feature`, `migrate`, `deps`, `hotfix`
- **Debugging and decisions:** `investigate`, `arena`
- **Session and safety:** `handoff`, `learn`, `careful`

Each one is a thin entry point that runs the matching playbook from here.

Templates live in `assets/` and helper scripts in `scripts/`. In Claude Code
these paths are relative to `${CLAUDE_SKILL_DIR}`.

- `scripts/detect.sh` fingerprints the stack.
- `scripts/preflight.sh` runs typecheck, lint, test and build for whatever
  stack it finds.
- `scripts/secscan.sh` runs every available scanner.
- `scripts/guard.sh` and `scripts/freeze-check.sh` are the safety hooks.
- `scripts/golden.sh` records API responses and later diffs against them,
  to prove behaviour didn't change.
- `scripts/linkcheck.py` crawls the site and finds broken or lost links.

Run the scripts; don't re-derive them.

## 4 · Gates (don't advance until the gate passes)

| From → To | Gate |
|---|---|
| Research → Spec | A recommended stack with reasons, a runner-up, and dated sources |
| Spec → Plan review | Every ticket has an owner agent, a blocking edge, outputs and acceptance criteria |
| Plan review → Build | Every review dimension scores ≥ 7/10, or the user accepts the gap |
| Build → Review | `preflight.sh` is green; output pasted into the decision log |
| Review → QA | No unresolved "act on" findings |
| QA → Security | No open P0/P1 bugs |
| Security → Ship | No open Critical/High findings, or risk accepted in `decisions.md` |
| Ship → Retro | CI green on main, PRs merged or awaiting approval, rollback path written |

At each gate, send a 3-line status:

1. What's done.
2. What's next.
3. Any decision the user owns.

Then keep moving unless the decision is his.

## 5 · Defaults: the user's stack comes first

Resolve the stack in this order. The first match wins.

1. What the user says in this request.
2. **The existing codebase.** In brownfield work, always follow what the repo
   already uses (`scripts/detect.sh`). Never introduce a second framework
   that does the same job.
3. **Project defaults:** `.starkstack/defaults.md`.
4. **User defaults:** `~/.claude/starkstack/defaults.md`, which applies to
   all projects.
5. **Learned overrides** in `.starkstack/learnings.md`.
6. **Research:** the best fit for this product, found in Phase 1.
7. **Fallback:** `references/defaults.md`. This is a modern, edge-first
   starter stack.

If neither defaults file exists, offer once to create
`~/.claude/starkstack/defaults.md` from `assets/defaults.md` after intake. It
has a short template: languages, API, web, platform, database, infrastructure
as code, testing, CI, conventions. Saving it means future runs start with the
user's own stack.

## 6 · Principles

Read `references/principles.md` once at the start of any multi-step run. The
short version:

- **Think before code.** Grill the user and the plan; a wrong spec costs more
  than a slow one.
- **Less code.** Delete before adding. Make the smallest change that's
  complete.
- **Prove it.** "Done", "fixed" and "passing" each need command output in the
  decision log. Verify on the real interface, not just unit tests.
- **Small units.** One ticket, one branch, one PR. One finding, one issue, one
  fix PR.
- **Guard the context.** Send bulk reading and parallel work to subagents
  (`agents/`). Give parallel writers their own worktrees.
- **Two audiences.** Every report has the technical detail plus a "What this
  means" line in plain words.
- **Reversible by default.** The guard hook blocks destructive git, secret
  commits and pushes straight to main. Ask before merging or deploying unless
  `--auto` was given.

## 7 · Decision log

Append one line per meaningful decision or result to
`.starkstack/decisions.log` (tab-separated):

```
time	phase	decision	reason	evidence	result
```

This makes runs auditable and resumable. `/starkstack:handoff` and session
pickup rebuild state from it.

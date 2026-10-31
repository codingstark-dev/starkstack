# Phase 0 — Intake

## 1. Look before asking
If a repo is present:

- Run `scripts/detect.sh`.
- Skim the README, manifests and CI config.
- Read `.starkstack/` if it exists. That's the state from a previous run, so
  resume from it.
- Read `GLOSSARY.md` and `docs/adr/` if they exist.
- Read the user's defaults, `.starkstack/defaults.md` and then
  `~/.claude/starkstack/defaults.md`, if they exist. If neither exists and
  this is greenfield work, add "preferred stack?" to the questions. Its
  default answer is "research picks it".

Never ask a question the code already answers.

## 2. Ask in one batch (max 5)
Use AskUserQuestion when available. Each question gets a recommended default
listed first:

1. **Outcome:** what are we building or fixing, for whom, and what does
   "done" look like?
2. **Constraints:** deadline, budget, tech you must use or avoid,
   compliance (PII, payments, region).
3. **Research output:** HTML report (default) or Markdown?
4. **Autonomy:**
   - Default: open issues and PRs freely, ask before merging or deploying.
   - `--auto`: merge and deploy on green CI.
   - Read-only: report only.
5. **Anything that must not break or change** (for existing codebases).

## 3. Unanswered questions are not blockers
If a question is skipped, or the user says "you decide", take the default and
write it to `.starkstack/decisions.md`:

```
ASSUMED (2026-10-31): research output = HTML — user skipped; revisit if needed
```

Assumptions are cheap to revise once they're written down. Waiting costs
momentum.

## 4. Initialise state
Run `scripts/init.sh`. It creates:

```
.starkstack/decisions.md   decisions.log   learnings.md   handoff.md
GLOSSARY.md (if missing)
```

Add `.starkstack/` to `.gitignore` unless the user wants it committed. For
teams, committing it is useful.

## 5. Grilling (for anything bigger than a small change)
After the first answers, interview until every branch is resolved:

- Ask about one design branch at a time, starting with the riskiest.
- For each, offer 2–3 concrete options with your recommendation and why.
- Write each answer to the glossary or as an ADR as you go.
- Stop when the remaining unknowns wouldn't change the architecture.

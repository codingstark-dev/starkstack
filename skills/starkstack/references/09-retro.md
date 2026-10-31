# Phase 9 — Docs, retro, learn, handoff

## Docs (tech-writer)
- **`README.md`:**
  - what it is (one line)
  - quickstart in 5 commands or fewer
  - an environment-variables table
  - scripts
  - architecture diagram
- **`docs/api.md`:** every route with method, path, auth, request, response
  and errors.
- **`docs/runbook.md`:** deploy, rollback, rotating secrets, common incidents
  and their fixes, on-call checks.
- **`docs/adr/`:** check that every hard decision from this run is recorded.
- **`CHANGELOG.md`:** updated.

Update docs in the same PR as the code where possible. Docs that lag behind
the code are worse than no docs.

## Retro (`/starkstack:retro`)
Write `.starkstack/retro.md` from `assets/retro.md`, using real numbers from
`git log`, `gh pr list --state merged` and `decisions.log`:

- **Shipped:** features, PRs, issues closed
- **Numbers:** tickets, commits, lines added and removed, tests added, bugs
  by severity, security findings fixed, CI pass rate
- **What went well / what went badly:** where you looped back, and why
- **Assumptions:** which `ASSUMED` defaults held and which broke
- **Next:** the top 3 follow-ups, opened as issues if allowed
- **In plain words:** 3 sentences for an investor or co-founder

## Learn (`/starkstack:learn`)
Append durable lessons to `.starkstack/learnings.md` as
`- [YYYY-MM-DD] <lesson> (evidence: …)`.

Good lessons are reusable:

- "D1: use `batch()` for multi-row insert; 10× faster"
- "This repo's auth middleware is `requireUser`, not `auth`"

When the same correction has come up twice, propose promoting it into the
project defaults (`.starkstack/defaults.md`), the user's global defaults
(`~/.claude/starkstack/defaults.md`, ask first), or the project's `CLAUDE.md`.

`/starkstack:learn prune` removes lessons that are stale or contradicted.

## Handoff (`/starkstack:handoff`)
Write `.starkstack/handoff.md` from `assets/handoff.md`:

- goal
- current phase and ticket
- branch and uncommitted state
- open PRs and issues
- decisions made
- blockers
- the exact next 3 steps

A fresh agent or session should be able to resume from this file alone.

**Session pickup:** read `handoff.md`, `decisions.log`, `git status`,
`git log -10` and `gh pr list --author @me`, then restate the plan before
acting.

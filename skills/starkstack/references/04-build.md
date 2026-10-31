# Phase 4 — Build

**Role:** the dev team, executing the spec one wave at a time.

## Execution
- **With the Agent tool:** spawn one subagent per ticket in the current
  wave, all in a single message so they run concurrently. Use the matching
  agent from `agents/`. Give each subagent:
  - the ticket block
  - the spec sections it needs, `GLOSSARY.md` and the relevant ADRs
  - the files it **may** touch (disjoint sets across parallel agents)
  - the acceptance criteria and the exact verify command

  Builders run with `isolation: worktree`, so parallel writers can't collide.
- **Without subagents:** do the tickets in wave order, announcing each hat
  ("Agent 3 · db-engineer: …").
- **Branching:** one ticket → `feat/T-07-bookings-api` → small commits →
  merged into the integration branch, or opened as its own PR.

## TDD loop (backend-dev, frontend-dev, db-engineer)
Work in vertical slices: one behaviour at a time, through every layer.

1. **Red:** write a failing test from one acceptance criterion and run it to
   see it fail.
2. **Green:** write the minimum code that makes it pass.
3. **Refactor:** remove duplication and sharpen names, keeping tests green.
4. Repeat for the next criterion.

Skip TDD only for pure UI styling or throwaway prototypes, and log the skip.

## Per-agent standards
- **designer:**
  - Commit to a visual direction (type scale, palette, spacing tokens) and
    record it in `DESIGN.md`.
  - Mobile-first. Contrast ≥ 4.5:1. Visible focus states.
  - Design every state: empty, loading, error.
- **architect:** contract before implementation; ADRs for non-obvious
  choices; shared types generated from the contract.
- **db-engineer:**
  - Versioned, reversible migrations (`wrangler d1 migrations`, drizzle-kit).
  - An index for every query path.
  - Seed script for local dev. No PII in fixtures.
- **backend-dev:**
  - Validate at the boundary (Valibot or Zod).
  - Typed errors mapped to HTTP codes.
  - Idempotency keys on mutations that can be retried.
  - Structured logs with no secrets.
- **frontend-dev:**
  - Typed API client from the contract.
  - Optimistic UI only where rollback is handled.
  - Code-split routes.
- **devops:**
  - Local, preview-per-PR and production environments.
  - Secrets via `wrangler secret`, SST or alchemy secrets; never in code.
  - CI: install → typecheck → lint → test → build. Pin Actions to a SHA and
    use `permissions: contents: read` by default.
- **test-engineer:**
  - Contract tests from the API spec.
  - Fixtures and factories.
  - Aim for meaningful coverage of business logic, not a coverage number.

## When stuck: investigate, don't guess
1. Reproduce reliably.
2. Minimise the case (bisect if needed).
3. Form one hypothesis.
4. Instrument or log to test it.
5. Fix the root cause and add a regression test.

After 3 failed fixes, stop. Write up what you learned in `decisions.log` and
ask.

## Verification before completion
Before saying a ticket is done:

1. Run `scripts/preflight.sh`.
2. Paste the summary into `decisions.log`.
3. Tick the ticket in `spec.md`.

"Should pass" is not evidence.

## Gate
`preflight.sh` is green on the integration branch, and every ticket in the
wave is ticked with evidence.

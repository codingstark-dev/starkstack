# Phase 2 — Spec Architect

**Role:** engineering manager. Turns research into a spec and a ticket board
where every ticket has an owner agent and a blocking edge.

## Steps
1. **Grill** (see `00-intake.md` §5):
   - Resolve the riskiest assumptions.
   - Update `GLOSSARY.md`.
   - Write an ADR for each hard decision (`assets/adr.md`).
2. **PRD:**
   - problem, users and jobs-to-be-done
   - user stories
   - non-goals
   - success metrics (one North Star metric plus guardrail metrics)
3. **Architecture:**
   - components (Mermaid diagram)
   - API contract (method, path, auth, request/response schema, errors)
   - data model and migrations
   - auth and permissions matrix
   - environments, deploy target, observability (logs, metrics, alerts)
4. **Tracer-bullet tickets.** The first ticket is a thin end-to-end slice
   through every layer: UI → API → DB → deploy. Later tickets thicken it. A
   working skeleton early surfaces integration problems while they're cheap
   to fix.
5. **Assign agents and blocking edges, then group the tickets into waves.**
6. **Save** to `.starkstack/spec.md` using `assets/spec.md`.
7. **Optional GitHub mirror** (ask first, or do it if autonomy allows):
   - one Epic issue whose body is the spec
   - one sub-issue per ticket, labelled `agent:<n>`, `wave:<n>`, `size:<S|M|L>`
   - freeze the spec into `docs/specs/<name>.md` in the first ticket's PR

## Agent roster
These match `agents/` in the plugin. Add or drop agents to fit the project.

| # | Agent | Owns |
|---|---|---|
| 1 | `designer` | flows, wireframes, design tokens, `DESIGN.md` |
| 2 | `architect` | service boundaries, API contract, auth, ADRs |
| 3 | `db-engineer` | schema, migrations, indexes, seed data, data backfills |
| 4 | `backend-dev` | routes, business logic, integrations, queues |
| 5 | `frontend-dev` | pages, components, state, typed API client |
| 6 | `devops` | infrastructure as code, environments, secrets, CI/CD, observability |
| 7 | `test-engineer` | contract, unit and integration tests, fixtures |
| 8 | `qa-tester` | end-to-end, browser, exploratory, accessibility and performance |
| 9 | `security-tester` | threat model, scans, fixes |
| 10 | `reviewer` | code review, blast radius |
| 11 | `release-engineer` | PRs, CI babysitting, merge, release, canary |
| 12 | `tech-writer` | README, API docs, runbook, changelog |

Optional specialists:

- AI/ML: RAG, voice agents, evals
- Web3: contracts, x402
- Mobile: Swift, Dart
- Performance
- Migration lead

## Ticket format
```
- [ ] T-07 · Agent 4 backend-dev · POST /bookings
      blocked_by: T-03 (schema), T-05 (contract)   blocks: T-09
      inputs: spec §4.2 · outputs: src/routes/bookings.ts, tests/bookings.test.ts
      acceptance: 201 creates; 409 double-book; 401 unauth; 422 invalid; tests green
      size: M · risk: med (money path)
```

A ticket without acceptance criteria isn't ready. The builder can't know when
it's done, and QA can't verify it.

## Waves
```
Wave 1  designer · architect · devops (repo, CI, preview env)   + T-01 tracer bullet
Wave 2  db-engineer · test-engineer (contract tests)
Wave 3  backend-dev ∥ frontend-dev  (parallel, separate worktrees)
Wave 4  reviewer → qa-tester → security-tester → release-engineer → tech-writer
```

## Gate
Every ticket has an agent, blocking edges, outputs and acceptance criteria.
The waves are drawn. The plan has been shown to the user. Proceed unless they
object.

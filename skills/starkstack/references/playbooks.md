# Playbooks

Copy the chosen playbook into the task list exactly as written. If you skip a
step, keep it in the list and mark it `skipped: <reason>`.

Steps marked **(gate)** must pass before you continue (see the gates table in
SKILL.md).

---

## Greenfield (full pipeline)
1. Intake: inspect the repo, ask the questions, run `init.sh`, log assumptions — `00-intake.md`
2. Research the stack, market and competitors; write the report in HTML or MD — `01-research.md` **(gate)**
3. Grill the plan: list the riskiest assumptions and ask about them; update `GLOSSARY.md` — `02-spec.md`
4. Write the spec: PRD, architecture, API contract, data model — `02-spec.md`
5. Break the spec into tracer-bullet tickets with agents, blocking edges and waves — `02-spec.md` **(gate)**
6. Run the plan reviews: CEO, Eng, Design, DX, Security, each scored 0–10 — `03-plan-review.md` **(gate)**
7. Build wave by wave with TDD, one branch per ticket — `04-build.md`
8. Run preflight (typecheck, lint, test, build) and paste the output into the decision log **(gate)**
9. Code review: model panel plus blast radius — `05-review.md` **(gate)**
10. QA: test plan, automated suites, browser pass, accessibility and performance — `06-qa.md` **(gate)**
11. Security: threat model, scanners, manual review, then issue → fix → PR for each finding — `07-security.md` **(gate)**
12. Ship: PRs, babysit CI, merge, release, deploy, canary — `08-ship.md` **(gate)**
13. Docs, retro and learnings — `09-retro.md`

## Brownfield feature (existing codebase — don't break anything)
Full detail: `10-feature.md`.
1. Intake: the feature, who it's for, what must not change
2. Map the codebase if `.starkstack/codebase-map.md` is missing or stale (Onboard playbook)
3. Baseline: preflight green on main; snapshot current behaviour (contract tests, golden API responses, e2e smoke, screenshots of key pages) **(gate)**
4. Impact analysis: touch points, callers, contracts, links and routes, data, background jobs, other agents and integrations — fill in the compatibility matrix **(gate)**
5. Design the feature to fit existing conventions; additive changes only (expand → migrate → contract); behind a feature flag
6. Spec, tickets and agents — `02-spec.md`; plan review (Eng + Security) — `03-plan-review.md` **(gate)**
7. Build with TDD — `04-build.md`
8. Regression gate: the baseline snapshot still matches, every row of the compatibility matrix is verified, link check passes, and the cross-agent contract checks pass **(gate)**
9. Code review with blast radius — `05-review.md`; QA — `06-qa.md`; Security on the new surface — `07-security.md`
10. Ship behind the flag, canary, then ramp the flag; document the flag's removal date — `08-ship.md`

## Migration (stack, framework, DB, host or library)
Full detail: `11-migrate.md`.
1. Intake: from → to, why (the pain), constraints, allowed downtime, deadline
2. Research the target: parity gaps, gotchas, and cost — `01-research.md` (shortened) **(gate)**
3. Inventory everything that touches the old stack: code, data, configs, env and secrets, CI, DNS and routes, cron jobs, webhooks, third-party integrations, docs
4. Write `docs/migration/` (plan, mapping table, data plan, rollback plan, runbook, deprecation list) **(gate: user approves the plan)**
5. Pin behaviour with characterization tests and golden outputs that will run against **both** stacks
6. Strangler-fig cutover: route by route or module by module behind a router or flag; never one big switch
7. Data: schema translation → dual-write or CDC → backfill → verify (counts, checksums, sampled diffs) → read switch → write switch
8. Parity gate: golden tests pass on the new stack, performance is at least as good, and error rates are equal or lower **(gate)**
9. Cut over, canary, and keep the rollback path warm for the agreed soak period
10. Decommission: remove dead code, dependencies, env vars, secrets, infrastructure, DNS and docs for the old stack — each removal its own PR
11. Update README, ADR, runbook and `learnings.md`; retro

## Onboard / map an existing codebase (read-only)
1. Run `scripts/detect.sh`; read the README, manifests, CI and infrastructure config
2. Send Explore subagents to each top-level area (routes/API, data, frontend, jobs, infra, integrations)
3. Write `.starkstack/codebase-map.md`: architecture diagram, entry points, module map, data model, external dependencies, conventions (naming, errors, testing), how to run, risky areas, plus a glossary seed for `GLOSSARY.md`
4. List quick wins and tech debt, ranked; no code changes

## Hotfix / Incident
1. Triage: severity, blast radius, start time, what changed recently (`git log`, latest deploys)
2. Mitigate first: rollback, feature flag off, or scale; restoring service beats a root-cause fix
3. Confirm recovery with metrics and logs
4. Then run the Bug fix playbook on a `hotfix/<slug>` branch from the deployed tag
5. Write a blameless postmortem in `docs/postmortems/` (timeline, impact, root cause, action items as issues)

## Dependency upgrade
1. Inventory outdated and vulnerable packages (`bun outdated`, `npm outdated`, `osv-scanner`, `cargo outdated`)
2. Group them by risk: patch/minor in batches, majors one per PR
3. For each major: read the changelog or migration guide, then upgrade, fix, run preflight, and do a QA smoke test
4. Ship as small PRs; record any notable breaking-change handling in `learnings.md`

## Bug fix
1. Intake: get the symptom, expected behaviour, environment and a repro if one exists
2. **Reproduce first.** Write a failing test, script or browser step that shows the bug. If you can't reproduce it, stop and report what you tried.
3. Minimise the repro, then bisect with `git bisect` if it's a regression
4. Form one hypothesis, instrument the code, confirm the root cause (Iron Law: no fix before the cause is known)
5. Fix the root cause with the smallest change
6. Show the failing test now passes; run the full preflight **(gate)**
7. Blast radius: list callers and other paths that are affected, and check the riskiest one by running it
8. Ship: branch `fix/<slug>`, then PR with before/after evidence and `Fixes #n`
9. Stop rule: after 3 failed fix attempts, stop, write up what you learned, and ask

## Refactor / Migration
1. Intake and goal: what gets simpler, and how you'll measure it
2. Pin current behaviour with characterization tests, golden outputs or screenshots before touching anything
3. Write a refactor plan as a sequence of small steps that each keep everything green
4. Run plan review (Eng only) **(gate)**
5. Do the steps, running preflight after each one; one commit per step
6. Re-run the characterization tests; any difference is a failure unless the user approves it
7. Code review and blast radius, then ship as a PR stack if the change is large

## Performance
1. Define the metric and the target (p95 latency, LCP, bundle KB, $/month)
2. Measure a baseline three times and record it
3. Profile to find the actual hot spot before optimising
4. Hill-climb: hypothesis → change → measure → keep or discard → log each cycle
5. Stop when the target is met or after 5 cycles with no gain
6. Report before/after with the numbers; ship

## Security audit (existing repo)
1. Intake: scope (repo, staging URL), and whether the repo is public or private
2. Threat model — `07-security.md` §1
3. Run `scripts/secscan.sh` and triage the results; drop false positives with a reason
4. Manual review against the checklist — `07-security.md` §3
5. Repo hardening review: branch protection, Actions permissions, Dependabot, secret scanning
6. For each finding, highest severity first: write it up, open an issue or advisory, add a test, fix it, open a PR
7. Write the security report: scanned / found / fixed / accepted / not covered, plus a plain-words summary **(gate)**
8. Ship the fix PRs — `08-ship.md`

## Investigation (read-only — no code changes)
1. Restate the question and what a good answer contains
2. **How:** trace runtime behaviour (entry points, call graph, data flow). For big systems, send Explore subagents to each subsystem.
3. **Why:** check history with `git log -S`, `git blame`, linked PRs and issues, and ADRs. Keep facts separate from inference.
4. Answer with a diagram and a plain-words summary; say what you couldn't find

## Prototype / Arena (pick between designs)
1. Write the design question and a rubric. Keep the rubric private from the builders so they can't game it.
2. Build 2–3 throwaway candidates in separate worktrees, each with a short "why I rejected the alternatives" note
3. A separate judge agent scores them against the rubric
4. Pick a base, borrow the best ideas from the others, write an ADR, delete the prototypes

## Long-running / autonomous
- Loop until a checkable condition passes (tests green, metric hit, queue empty). Each cycle makes one justified change, verifies it and logs it.
- Pause safely at a clean boundary: commit, update `handoff.md`, and stop.
- Session pickup: rebuild state from `handoff.md`, `decisions.log`, git branch and status, and open PRs before doing anything new.

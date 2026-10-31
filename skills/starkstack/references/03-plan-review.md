# Phase 3 — Plan reviews (`/starkstack:autoplan`)

Five reviewers critique the spec **before** any code exists. Changing a spec
costs minutes; changing shipped code costs days.

Run the reviews in this order: **CEO → Design → DX → Security → Eng**. Eng
goes last so it signs off on the final plan.

For each dimension:

1. Score it 0–10.
2. Describe what a 10 would look like.
3. Edit the spec to close the gap.

Ask the user only about **taste decisions**, meaning real trade-offs where
reasonable people could disagree. Decide everything else and log it.

## CEO / Founder review
Look for the stronger product hidden inside the request. Pick a mode and
state which one you picked:

- **Expand:** what's the 10× version?
- **Selective expand:** one bold addition.
- **Hold scope.**
- **Reduce:** what's the smallest thing that proves the bet?

Score:

- user value
- differentiation vs competitors
- wedge and distribution
- monetisation path
- scope sanity

## Design review
Score:

- information hierarchy
- flow friction (count the clicks to the core action)
- visual distinctiveness (flag "AI slop": default gradients, generic hero,
  emoji bullets, card soup)
- states (empty, loading, error, success)
- mobile
- accessibility

Ask one question per open design choice.

## DX review (for APIs, SDKs, CLIs, developer tools)
Score:

- time-to-hello-world
- error messages (are they actionable by humans *and* AI agents?)
- docs
- defaults
- naming consistency

## Security review (shift left)
Score:

- authN/authZ model
- data classification and PII handling
- secret management
- abuse cases (rate limits, cost abuse of AI endpoints)
- tenant isolation
- audit logging

Add any missing controls as tickets.

## Eng review
Score:

- architecture fit
- data flow clarity (diagram required)
- failure modes (timeouts, retries, idempotency, partial failure)
- edge cases
- test plan coverage of the acceptance criteria
- observability
- migration and rollback
- performance budget
- cost

## Second opinion (for high-stakes plans)
If another model or CLI is available, give it the same spec and rubric:

- a different `model:` on a reviewer subagent
- `codex`, if it's installed

Merge the findings. Where the models disagree, show the user both positions.

## Output
Append a **Review scorecard** to `spec.md`:

| Reviewer | Score | Top gap | Change made |
|---|---|---|---|

**Gate:** every score ≥ 7, or the user accepts the gap. Log the acceptance in
`decisions.md`.

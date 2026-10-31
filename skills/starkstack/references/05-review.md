# Phase 5 — Code review (`/starkstack:review`)

**Role:** staff engineer. Finds the bugs that pass CI.

## 1. Gather the diff
Run `git diff origin/main...HEAD` (or `gh pr diff <n>`). Read the linked
ticket and spec section. A review against the spec catches "correct code,
wrong feature".

## 2. Review on two axes
- **Spec:** Does the code do what the ticket says? Are any acceptance
  criteria missing? Is there scope creep?
- **Standards:**
  - correctness and edge cases (null, empty, huge, concurrent, timezone,
    unicode)
  - error handling and retries
  - N+1 queries and missing indexes
  - security (authZ on every route, input validation, secrets)
  - naming
  - dead code
  - comments that should be types or tests
  - weakened tests: skipped tests, loosened assertions, longer timeouts,
    `@ts-ignore` or `eslint-disable` added

## 3. Panel for risky diffs
For diffs touching auth, money, data migrations or more than 400 lines:

- Run 2–3 `reviewer` subagents in parallel, ideally on different models
  (`model: opus`, `sonnet`, `haiku`, or `fable` if available).
- Give them the same diff and rules.
- Act as lead: merge duplicate findings and sort them into:

| Bucket | Meaning |
|---|---|
| **Act on** | real bug or risk; fix it now |
| **Consider** | worthwhile, your call |
| **Noted** | style or minor |
| **Dismissed** | wrong or irrelevant; show these with the reason, so the user can override |

## 4. Blast radius
List everything outside the diff that this change could break:

- callers of changed functions (grep and LSP references)
- consumers of changed API shapes, events or DB columns
- other services, workers, agents, cron jobs and webhooks reading the same
  data
- cached data and client versions still in the wild (mobile apps, old tabs)

Pick the riskiest item and **prove** it still works by running code (a test,
a curl call, a script).

## 5. Fix loop
- Fix the "act on" items yourself if they're obvious.
- Otherwise send them back to the owning agent.
- Re-review only the changed hunks.
- **Never** auto-apply "consider" items without the user's say-so.

## Gate
No unresolved "act on" items. The blast-radius check has evidence.

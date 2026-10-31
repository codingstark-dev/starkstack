# Migration (`/starkstack:migrate`)

**Role:** migration lead and DBA. Moves a working system from one stack to
another without losing data, users or SEO, then removes what's left of the
old stack.

Examples:

- Express → Hono on Workers
- Vercel → Cloudflare
- Postgres → D1 (or the reverse)
- Next.js → TanStack Start
- REST → typed RPC
- Firebase auth → Better Auth or Lucia
- JS → TS
- a deprecated SDK → its replacement

## 1. Intake
- From → to, and **why**: name the actual pain (cost, performance, DX,
  lock-in, end of life).
- Allowed downtime (default: zero), data volume, deadline, freeze windows.
- Does it migrate in one go, or module by module? Default: module by module.

## 2. Target research (short form of `01-research.md`)
- Feature-parity gaps, plus the replacement for each gap.
- Known migration gotchas, from the official migration guides and the
  changelogs.
- Limits on the target: Workers CPU and memory, D1 size and row limits,
  request-size caps, cold starts.
- Cost before and after.

**Gate:** no parity gap is left without a plan.

## 3. Inventory (everything that touches the old stack)
Build `docs/migration/inventory.md`:

- code modules, routes, middleware, jobs and cron, workers, scripts
- data: databases, tables, row counts, blob storage, caches, search indexes
- config: environment variables, secrets, feature flags, per-environment
  overrides
- infrastructure: DNS, CDN, domains, TLS, queues, buckets, IAM, CI/CD
  pipelines
- integrations: webhooks in and out, OAuth apps (redirect URIs!), email
  sending domains, payment providers, analytics, AI providers, other agents
- docs, runbooks, dashboards and alerts that reference the old stack

## 4. Migration docs (`docs/migration/`) — the user approves these before any cutover
| File | Contents |
|---|---|
| `plan.md` | goal, scope, phases, timeline, owners (agents), success criteria, go/no-go checklist |
| `mapping.md` | old concept → new concept table (e.g. Express middleware → Hono middleware; `pg` query → D1 prepared statement; S3 → R2) |
| `data-plan.md` | schema translation, type mapping, dual-write or CDC approach, backfill, verification, cutover order |
| `rollback.md` | the rollback trigger for each phase and the exact commands; how long the old stack stays warm |
| `runbook.md` | step-by-step cutover script with checkpoints |
| `deprecation.md` | everything to delete once the soak period ends, each with an owner and a date |

Also write an ADR (`docs/adr/NNNN-migrate-<from>-to-<to>.md`).

## 5. Characterization tests
Before migrating anything, capture the old behaviour as tests that can run
against **both** stacks: same requests in, compare the responses (golden
files, ignoring volatile fields). This is the parity oracle for the whole
migration.

1. Run `scripts/golden.sh record <old-url>`.
2. Run `scripts/golden.sh diff <new-url>`.
3. Run `scripts/linkcheck.py <old-url> --save …`, then
   `scripts/linkcheck.py <new-url> --compare …`. This catches lost routes and
   missing 301 redirects.

## 6. Strangler-fig cutover
- Put a router or proxy in front (a Worker is ideal) that sends each route to
  the old or the new backend.
- Migrate one module or route group at a time: build it, run the parity
  tests, shadow traffic (compare without serving), then serve 1% → 10% →
  100%.
- Each module is its own ticket, PR and canary.
- Never do a big-bang rewrite unless the system is tiny and the user
  explicitly asks for one.

## 7. Database migration (the risky part)
1. **Schema translation:**
   - Map the types: Postgres `jsonb` → D1 `TEXT` + JSON functions; `serial`
     → `INTEGER PRIMARY KEY`; timestamps → ISO TEXT or unix INTEGER.
   - Recreate the indexes and constraints.
   - Write the result as versioned migrations.
2. **Expand:** create the new schema. No reads yet.
3. **Dual-write** (or CDC): the app writes to old and new. Old remains the
   source of truth. Log every dual-write failure.
4. **Backfill:**
   - in batches, idempotent and resumable
   - checkpointed (Queues or Workflows on Cloudflare)
   - throttled to protect production
5. **Verify:**
   - row counts per table
   - checksums or hashes per batch
   - random-sample field diffs
   - foreign-key integrity
   - application-level golden queries

   Any mismatch stops the cutover.
6. **Switch reads** to the new DB, behind a flag. Watch error rates and
   latency.
7. **Switch writes.** New becomes the source of truth. Keep the reverse sync
   or old-DB writes during the soak period, so rollback stays possible.
8. **Contract:** stop the dual-write, archive the old DB as a snapshot with a
   retention date, then decommission it.

Destructive steps (dropping tables, deleting buckets, deleting a DB) are
**always** confirmed with the user, even with `--auto`. Take a backup or
snapshot first and write its location in `rollback.md`.

## 8. Parity gate (before full cutover)
- [ ] Characterization tests pass against the new stack
- [ ] Data verification is clean
- [ ] p95 latency and error rate equal or better
- [ ] All links, redirects and SEO URLs resolve (crawl old vs new; 301s where
      paths changed)
- [ ] OAuth redirect URIs, webhooks and DNS updated and tested
- [ ] Monitoring and alerts point at the new stack
- [ ] Rollback rehearsed at least once

## 9. Decommission (removing obsolete code)
After the soak period (default 7–14 days with no rollback), work through
`deprecation.md`. Each item is its own small PR:

- delete dead code paths, adapters, the routing proxy branches and old tests
- remove unused dependencies (`knip`, `depcheck`, `cargo udeps`), then
  rebuild and test
- remove old environment variables and secrets; **rotate** any shared
  credentials
- tear down old infrastructure, DNS records, buckets and CI jobs (confirm
  each with the user)
- update README, runbook, architecture diagrams, `GLOSSARY.md` and
  `learnings.md`

## 10. Done
Retro (`09-retro.md`) covering:

- what the migration actually cost vs the plan
- incidents
- performance and cost before vs after
- an "In plain words" summary

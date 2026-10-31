# Brownfield feature (`/starkstack:feature`)

**Role:** compatibility engineer. Adds a feature to a live codebase without
breaking anything that already works, including the other agents, services
and links that depend on it.

The core rule: **change additively, verify against a baseline, release
behind a flag.**

## 1. Understand before touching
- Read `.starkstack/codebase-map.md`. If it's missing or older than about 30
  commits, run the Onboard playbook first.
- Find how similar features are already built here (routing, validation,
  error shape, state management, tests) and copy those conventions. A new
  feature in a new style is tech debt from day one.
- Read the relevant ADRs and `GLOSSARY.md`, and reuse the existing terms.

## 2. Baseline snapshot (before any change)
Record how the system behaves now, so a regression shows up as a diff
instead of a surprise:

- `scripts/preflight.sh` green on main, with the output saved
- **contract snapshot:**
  - the OpenAPI or route list with request/response shapes (generate it if
    it doesn't exist)
  - exported types and functions of shared packages
  - event and queue message schemas
  - the DB schema dump
- **golden responses:**
  1. List the key endpoints in `.starkstack/baseline/endpoints.txt`.
  2. Run `scripts/golden.sh record <base-url>`.
  3. After the build, run `scripts/golden.sh diff <base-url>`.
- **end-to-end smoke test** of the top journeys, plus screenshots of key
  pages
- **link inventory:** run
  `python3 scripts/linkcheck.py <base-url> --save .starkstack/baseline/links.txt`.
  After the build, run it again with `--compare .starkstack/baseline/links.txt`.
- **performance baseline:** p95 latency of hot routes and bundle size

## 3. Impact analysis → compatibility matrix
Find every consumer of what you'll touch. Use grep, LSP references,
`git log -S`, and the CODEOWNERS file.

Fill this matrix in `.starkstack/compat.md`. Every row needs a verification
method before you build:

| Surface | Consumers | Change type | Risk | How we verify |
|---|---|---|---|---|
| `GET /api/bookings` response | web app, mobile v1.x, partner API | add field `status` (additive) | low | contract test + golden diff |
| `bookings` table | backend, analytics job, admin agent | add nullable column | med | migration dry-run on prod copy |
| `booking.created` queue event | email worker, Slaab agent webhook | unchanged | — | schema test |
| `/book/:id` route + links | emails, sitemap, SEO | unchanged | — | link check |
| AI agent tools / MCP schema | voice + chat agents | add optional param | med | agent tool-call replay |

**Check these surfaces explicitly:**

- Public and internal APIs, SDKs and webhooks. Old clients (mobile apps,
  cached tabs, partners) will keep sending the old shape.
- Other agents, bots and MCP tools that call this code, or whose prompts and
  tool schemas describe it.
- DB columns read by jobs, analytics, other services or BI.
- Routes, links, redirects, sitemap and deep links (email links and push
  notifications live for years).
- Feature-flag and config defaults; environment variables per environment.
- Auth and permissions: does the new feature open a path to existing data?
- Caches, CDN rules, KV keys, Durable Object state formats.

## 4. Design rules for safe change
- **Additive only:** new fields optional, new endpoints instead of changed
  ones, new columns nullable or defaulted. Never rename or remove in the same
  release.
- **Expand → migrate → contract** for anything that has to change shape:
  1. Add the new shape alongside the old.
  2. Migrate the readers and writers.
  3. Remove the old shape in a **later**, separate PR, once nothing uses it.
- **Feature flag:** new behaviour is off by default (KV, env or a flag
  service) and can be ramped and killed without a deploy.
- **Versioning:** when a breaking change can't be avoided, version the API
  (`/v2`) or the event (`booking.created.v2`) and keep the old one running.
- **Agent compatibility:** update tool schemas and prompts additively, and
  keep the old tool names working as aliases until the agents are redeployed.

## 5. Build
Write the spec and tickets (`02-spec.md`). Each ticket names the
compatibility rows it touches. Then build with TDD (`04-build.md`) and add
contract tests for every row marked med or high risk.

## 6. Regression gate (must pass before review)
- [ ] `preflight.sh` green
- [ ] Contract snapshot diff contains **only additive** changes, or approved
      breaking ones
- [ ] Golden responses unchanged, except for the expected new fields
- [ ] End-to-end smoke test and screenshots match the baseline (flag off) and
      the new flow works (flag on)
- [ ] Link check: no new 404s; redirects intact
- [ ] Agent and tool-call replay passes for dependent agents
- [ ] Migration runs forward **and** back on a copy of real-shaped data
- [ ] Performance within 10% of the baseline
- [ ] Every row of the compatibility matrix has a recorded result

## 7. Ship
- Code review with blast radius (`05-review.md`), then QA and security on the
  new surface.
- Ship with the flag off, canary, then ramp the flag (internal → 10% → 100%).
- Record in `decisions.md` when the flag's cleanup PR is due.

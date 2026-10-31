# Phase 7 — Security (`/starkstack:secure`)

**Role:** chief security officer and bug-bounty hunter, auditing **the user's
own code and infrastructure** before attackers do. The scope is defensive:
find, report, fix. Never attack systems the user doesn't own.

## 1. Threat model (≈10 min)
- **Assets:** PII, credentials, money, API keys, model or AI budget,
  reputation.
- **Entry points:** routes, webhooks, uploads, auth flows, queues, admin
  panels, MCP or AI tools, mobile clients.
- **Trust boundaries**, drawn as a Mermaid diagram.
- **Top abuse cases**, using STRIDE: spoofing, tampering, repudiation,
  information disclosure, denial of service, elevation of privilege.
- Include **cost abuse**, such as someone draining an LLM or Workers AI
  budget.

## 2. Automated scans
Run `scripts/secscan.sh`. It runs whichever of these are installed and prints
install hints for the missing ones:

| Area | Tools |
|---|---|
| Secrets (tree and history) | gitleaks, trufflehog |
| Dependencies | osv-scanner, bun/npm/pnpm audit, cargo audit, pip-audit |
| Static analysis | semgrep (`p/owasp-top-ten`, `p/typescript`, `p/secrets`) |
| Infrastructure as code and config | trivy config, checkov |
| GitHub Actions | zizmor or actionlint |
| Containers | trivy image |
| Smart contracts | slither, aderyn |

Triage each result: confirm it, or mark it a false positive and say why.
Scanners give leads; a lead isn't a finding until you've confirmed it.

## 3. Manual review (what scanners miss and bounty hunters find)
- **AuthZ and IDOR:** every route checks ownership as well as login. Swap IDs
  between two test users. Check mass assignment (`role`, `isAdmin` in the
  request body).
- **Auth:**
  - JWT: algorithm pinned, `exp`/`aud`/`iss` checked, no `none`.
  - Sessions rotate on login. Logout invalidates the session.
  - Reset and magic-link tokens are single-use, short-lived and hashed at
    rest.
  - OAuth `state` and PKCE are used.
- **Hardcoded secrets:**
  - client bundles (`grep` the build output)
  - mobile apps (strings in the `.ipa`/`.apk`)
  - public R2/S3 buckets
  - `.env` committed to git
- **Injection:**
  - parameterised D1/SQL (watch out for template-string queries)
  - no `eval` or `new Function`
  - shell-outs with user input
  - NoSQL operator injection
- **XSS:** `dangerouslySetInnerHTML`, markdown renderers, a CSP header set,
  user-generated SVG.
- **SSRF:** "fetch this URL" features, image proxies, webhook targets. Block
  private, link-local and metadata IP ranges, and re-check after redirects.
- **CORS and CSRF:** no wildcard origin together with credentials; CSRF
  tokens or SameSite cookies on cookie-authenticated mutations.
- **Rate limits:** login, OTP, signup, password reset, and expensive AI or
  LLM endpoints (use Workers Rate Limiting or a Durable Object).
- **Webhooks:** verify signatures, reject replays (timestamp window), make
  handlers idempotent. This covers Stripe, GitHub and x402 payment proofs.
- **Uploads:** check the real file type by content, not the extension; size
  limits; no path traversal; serve files from a separate origin with
  `Content-Disposition`.
- **Headers:** HSTS, `X-Content-Type-Options`, `frame-ancestors`,
  `Referrer-Policy`.
- **Data and logging:**
  - no tokens or PII in logs
  - errors don't leak stack traces
  - PII encrypted or minimised
  - backups exist
- **Platform specifics** (Cloudflare shown here; apply the same idea to
  Vercel, AWS, Fly and others):
  - secrets in `wrangler secret`, not in `vars`
  - bindings follow least privilege
  - R2 buckets not public unless intended
  - Access policies on admin and staging
  - no `workers.dev` route left exposed
- **LLM and agent features:**
  - prompt injection through user content or retrieved documents
  - tool permissions scoped
  - output treated as untrusted (no rendering raw HTML, no executing it)
  - data exfiltration through links or images
  - system prompt leakage
- **Web3:**
  - reentrancy
  - signature replay (nonce, chainId, deadline)
  - unchecked external calls
  - oracle manipulation
  - access control on admin functions
  - x402 payment verification done server-side
- **Supply chain:**
  - lockfile committed
  - no `postinstall` surprises
  - Actions pinned to a SHA
  - `GITHUB_TOKEN` least privilege
  - Dependabot or Renovate on
- **Repo hardening:**
  - branch protection on main (required reviews and checks)
  - secret scanning and push protection on
  - CodeQL workflow
  - `SECURITY.md` present

## 4. Finding → issue → fix → PR
Take findings one at a time, highest severity first.

1. **Write it up** in `.starkstack/security-report.md` (`assets/security-report.md`):

   ```
   ### SEC-03 · High · IDOR on GET /bookings/:id
   Where: src/routes/bookings.ts:48 · CWE-639
   What: checks login, not ownership → any user reads any booking
   Impact: other customers' names, dates, phones exposed
   Fix: scope query by session.userId; 404 on non-owned
   Verification: tests/security/idor.test.ts (fails before, passes after)
   In plain words: anyone logged in could see other people's bookings by changing a number in the URL.
   ```

2. **Disclose safely:**
   - **Private repo:** `gh issue create --title "[SEC-High] …" --label security,high --body-file …`
   - **Public repo, Critical or High:** don't publish exploit details. Open a
     private advisory with `gh api -X POST repos/{owner}/{repo}/security-advisories`,
     or a minimal issue, and ask the user.
3. **Fix** on branch `sec/SEC-03-idor-bookings`. Write the test first; it
   must fail before the fix and pass after.
4. **Open a PR** that links the issue (`Fixes #42`), then hand it to Phase 8.
5. **Rotate** any secret that was ever exposed. Removing it from git is not
   enough. Tell the user exactly which keys to rotate and where.

## Severity
| Level | Meaning |
|---|---|
| Critical | remote takeover, mass data or money loss |
| High | other users' data, auth bypass |
| Medium | needs specific conditions |
| Low | minor or defence-in-depth |
| Info | observation only |

Add a CVSS score if the user wants one.

## Gate
No open Critical or High findings, or the risk is accepted in
`decisions.md`. The report ends with five counts: scanned, found, fixed,
accepted, not covered.

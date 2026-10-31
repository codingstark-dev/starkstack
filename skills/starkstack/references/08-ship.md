# Phase 8 — Ship (`/starkstack:ship`, `/starkstack:land`)

**Role:** release engineer and SRE. Owns the path from branch to production.

## Prerequisites
Check that `gh auth status` succeeds and the repo has a remote. If not, tell
the user exactly what to run (`gh auth login`) and continue with the
local-only steps.

## /ship: branch → PR
1. **Sync:** `git fetch && git rebase origin/main`.
   - Use `--force-with-lease` only on your own feature branch.
   - Never force-push main. The guard hook enforces this.
2. **Pre-flight:**
   - `scripts/preflight.sh`
   - `gitleaks protect --staged`
   - check that docs are updated for any changed behaviour
3. **Commit** using Conventional Commits:
   `feat(bookings): …`, `fix(sec): …`, `perf: …`, `refactor: …`, `chore(ci): …`.
4. **Open the PR:**
   `gh pr create --base main --title "<type(scope): summary>" --body-file .starkstack/pr-body.md --label <type>`
   Build the body from `assets/pr-body.md`:
   - summary
   - why
   - changes
   - before/after evidence
   - how it was tested (pasted output)
   - merge-danger rating: low, med or high
   - rollback steps
   - `Fixes #n`
   - an "In plain words" line
5. **Stacks:** for large work, open a stack of small PRs, each based on the
   previous one. Land only the verified, contiguous bottom part of the stack.

## Babysit until merge-ready
Loop until the PR is ready or blocked:

- **Conflicts:** rebase and re-run preflight.
- **CI:** `gh pr checks <n> --watch`. If it's red, run
  `gh run view <id> --log-failed`, fix the root cause and push. Never skip or
  disable a check to get green.
- **Review threads:** for each comment, check it technically before acting.
  Don't agree just to be polite, and don't apply it blindly. Fix it, or reply
  with your reasoning.

## /land: merge → deploy → verify
1. **Merge:**
   - Default: report "PR #57 is green, merge-danger low — merge?" and wait
     for a yes.
   - With `--auto`: once checks are green and there are no unresolved
     threads, run `gh pr merge <n> --squash --delete-branch`.
   - Never bypass branch protection.
2. **Release:**
   - semver bump
   - `CHANGELOG.md` entries grouped into feat, fix, security and perf
   - `gh release create vX.Y.Z --generate-notes`
3. **Deploy** through the project's pipeline: `wrangler deploy`,
   `alchemy deploy` or `sst deploy --stage production`. A production deploy
   is a merge-level decision.
4. **Canary** (5–10 minutes):
   - hit `/health` and the top 3 routes
   - `wrangler tail` or the logs for new errors
   - compare the error rate and p95 latency with before the deploy
   - check the browser console on key pages
5. **Rollback, if needed:** `wrangler rollback`, `wrangler versions deploy`
   back to the previous version, or redeploy the previous tag. Always write
   the exact rollback command in the PR or release notes **before** deploying.
6. **Close the loop:**
   - confirm the linked issues closed
   - tick the ticket in `spec.md`
   - add a line to `decisions.log`

## Gate
- CI green on main
- PRs merged, or awaiting the user's approval
- release notes written
- canary clean
- rollback command documented

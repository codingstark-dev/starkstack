#!/usr/bin/env bash
# Fingerprint the repo's stack. Prints a short report (key: value) for the agent to read.
set -u
cd "${1:-.}" || exit 1
has() { [ -e "$1" ]; }
dep() { has package.json && grep -q "\"$1\"" package.json; }
out() { printf '%-14s %s\n' "$1:" "$2"; }

pm="none"
has bun.lockb && pm=bun; has bun.lock && pm=bun
has pnpm-lock.yaml && pm=pnpm; has yarn.lock && pm=yarn
[ "$pm" = none ] && has package-lock.json && pm=npm
[ "$pm" = none ] && has package.json && pm=npm
out "js-pm" "$pm"

langs=""
has package.json && langs="$langs js"
{ has tsconfig.json || ls */tsconfig.json >/dev/null 2>&1; } && langs="$langs ts"
has Cargo.toml && langs="$langs rust"
{ has pyproject.toml || has requirements.txt; } && langs="$langs python"
has go.mod && langs="$langs go"
{ has Package.swift || ls *.xcodeproj >/dev/null 2>&1; } && langs="$langs swift"
has pubspec.yaml && langs="$langs dart"
{ has foundry.toml || has hardhat.config.ts || has hardhat.config.js || has Anchor.toml; } && langs="$langs solidity/solana"
out "languages" "${langs# }"

fw=""
for d in next @tanstack/react-start @tanstack/start hono elysia express fastify react vue svelte astro remix drizzle-orm prisma @pipecat-ai/client-js x402 viem @solana/web3.js; do dep "$d" && fw="$fw $d"; done
out "frameworks" "${fw# }"

infra=""
{ has wrangler.toml || has wrangler.jsonc || has wrangler.json || ls */wrangler.* >/dev/null 2>&1; } && infra="$infra cloudflare"
{ has alchemy.run.ts || dep alchemy; } && infra="$infra alchemy"
{ has sst.config.ts; } && infra="$infra sst"
has turbo.json && infra="$infra turborepo"
has vercel.json && infra="$infra vercel"
{ has Dockerfile || has docker-compose.yml || has compose.yaml; } && infra="$infra docker"
ls *.tf >/dev/null 2>&1 && infra="$infra terraform"
out "infra" "${infra# }"

tests=""
{ dep vitest; } && tests="$tests vitest"; { dep jest; } && tests="$tests jest"
{ dep @playwright/test; } && tests="$tests playwright"
[ "$pm" = bun ] && tests="$tests bun-test?"
has Cargo.toml && tests="$tests cargo-test"; has pyproject.toml && tests="$tests pytest?"
out "tests" "${tests# }"

ci=""; ls .github/workflows/*.y*ml >/dev/null 2>&1 && ci="github-actions($(ls .github/workflows | wc -l | tr -d ' '))"
out "ci" "${ci:-none}"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  out "git-branch" "$(git branch --show-current 2>/dev/null)"
  out "git-remote" "$(git remote get-url origin 2>/dev/null || echo none)"
  out "git-dirty" "$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ') files"
  out "commits" "$(git rev-list --count HEAD 2>/dev/null || echo 0)"
else
  out "git" "not a repo"
fi

docs=""; for f in README.md CLAUDE.md AGENTS.md GLOSSARY.md DESIGN.md SECURITY.md CHANGELOG.md docs/adr .starkstack; do has "$f" && docs="$docs $f"; done
out "docs" "${docs# }"
for t in gh jq gitleaks trufflehog semgrep osv-scanner trivy zizmor wrangler playwright; do command -v "$t" >/dev/null 2>&1 && tools="${tools:-} $t"; done
out "tools" "${tools# }"

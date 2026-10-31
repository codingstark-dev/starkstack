#!/usr/bin/env bash
# Run every available security scanner on the repo; save raw output to .starkstack/scans/ and print a summary.
# Missing tools are listed with install hints, never silently skipped.
set -u
cd "${1:-.}" || exit 1
out=".starkstack/scans"; mkdir -p "$out"
summary=(); missing=()
have() { command -v "$1" >/dev/null 2>&1; }
scan() { # name, outfile, command
  local name="$1" file="$2"; shift 2
  echo "▶ $name"
  bash -c "$*" >"$out/$file" 2>&1; local rc=$?
  local lines; lines=$(wc -l <"$out/$file" | tr -d ' ')
  summary+=("$(printf '%-14s exit=%-3s %6s lines → %s' "$name" "$rc" "$lines" "$out/$file")")
}

# Secrets
if have gitleaks; then scan gitleaks gitleaks.json "gitleaks detect --redact --no-banner --report-format json --report-path $out/gitleaks.json; true"
else missing+=("gitleaks  → brew install gitleaks"); fi
if have trufflehog; then scan trufflehog trufflehog.txt "trufflehog git file://. --only-verified --no-update"
else missing+=("trufflehog → brew install trufflehog"); fi

# Dependencies
if have osv-scanner; then scan osv osv.txt "osv-scanner scan source -r ."
else missing+=("osv-scanner → brew install osv-scanner"); fi
if [ -f package.json ]; then
  if [ -f bun.lock ] || [ -f bun.lockb ]; then have bun && scan bun-audit bun-audit.txt "bun audit"
  elif [ -f pnpm-lock.yaml ]; then have pnpm && scan pnpm-audit pnpm-audit.txt "pnpm audit --prod"
  else have npm && scan npm-audit npm-audit.txt "npm audit --omit=dev"; fi
fi
[ -f Cargo.toml ] && { have cargo-audit && scan cargo-audit cargo-audit.txt "cargo audit" || missing+=("cargo-audit → cargo install cargo-audit"); }
{ [ -f requirements.txt ] || [ -f pyproject.toml ]; } && { have pip-audit && scan pip-audit pip-audit.txt "pip-audit" || missing+=("pip-audit → pipx install pip-audit"); }

# SAST
if have semgrep; then scan semgrep semgrep.txt "semgrep scan --config p/owasp-top-ten --config p/secrets --config p/typescript --metrics=off --quiet"
else missing+=("semgrep → brew install semgrep  (or pipx install semgrep)"); fi

# IaC / config / CI
if have trivy; then scan trivy-config trivy-config.txt "trivy config --quiet ."; scan trivy-fs trivy-fs.txt "trivy fs --quiet --scanners vuln,secret,misconfig ."
else missing+=("trivy → brew install trivy"); fi
if ls .github/workflows/*.y*ml >/dev/null 2>&1; then
  if have zizmor; then scan zizmor zizmor.txt "zizmor .github/workflows"
  else missing+=("zizmor (GitHub Actions audit) → pipx install zizmor"); fi
fi

# Smart contracts
if [ -f foundry.toml ] || ls contracts/*.sol >/dev/null 2>&1; then
  have slither && scan slither slither.txt "slither . " || missing+=("slither → pipx install slither-analyzer")
fi

# Cheap built-in checks (no tools needed)
{
  echo "## .env files tracked by git"; git ls-files 2>/dev/null | grep -E '(^|/)\.env($|\.)' | grep -v example || echo "none"
  echo; echo "## wrangler vars that look like secrets"; v="$(grep -nsiE '^\s*[A-Z_]*(SECRET|TOKEN|KEY|PASSWORD)[A-Z_]*\s*=' wrangler.toml */wrangler.toml 2>/dev/null)"; echo "${v:-none}"
  echo; echo "## raw SQL built from template strings (check for injection)"; grep -RnE '(prepare|query|exec)\(\s*`[^`]*\$\{' --include='*.ts' --include='*.js' . 2>/dev/null | grep -v node_modules | head -50 || true
  echo; echo "## dangerouslySetInnerHTML / eval / new Function"; grep -RnE 'dangerouslySetInnerHTML|[^a-zA-Z]eval\(|new Function\(' --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' . 2>/dev/null | grep -v node_modules | head -50 || true
  echo; echo "## CORS wildcard"; grep -RnE "origin:\s*['\"]\*['\"]|Access-Control-Allow-Origin['\"]?\s*[:,]\s*['\"]\*" --include='*.ts' --include='*.js' . 2>/dev/null | grep -v node_modules | head -20 || true
  echo; echo "## GitHub Actions not pinned to SHA"; grep -RnE 'uses:\s*[^ ]+@(v?[0-9]+|main|master)\s*$' .github/workflows 2>/dev/null || echo "none / no workflows"
  echo; echo "## workflows without explicit permissions"; for w in .github/workflows/*.y*ml; do [ -f "$w" ] && ! grep -q '^permissions:' "$w" && echo "$w"; done 2>/dev/null; true
} > "$out/builtin.txt" 2>&1
summary+=("$(printf '%-14s %16s → %s' builtin "grep checks" "$out/builtin.txt")")

echo; echo "== starkstack secscan =="; printf '%s\n' "${summary[@]}"
if [ ${#missing[@]} -gt 0 ]; then echo; echo "Not installed (coverage gap — mention in report):"; printf '  - %s\n' "${missing[@]}"; fi
echo; echo "Next: triage every result (confirm or false-positive with reason) — scanners give leads, not findings."

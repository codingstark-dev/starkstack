#!/usr/bin/env bash
# Run typecheck → lint → test → build for whatever stack is present. Prints a PASS/FAIL table; exit 1 on any failure.
# Usage: preflight.sh [dir] [--quick]   (--quick skips build)
set -u
dir="${1:-.}"; [ "${1:-}" = "--quick" ] && dir="."
quick=0; for a in "$@"; do [ "$a" = "--quick" ] && quick=1; done
cd "$dir" || exit 1
results=(); fail=0
log="$(mktemp)"

run() { # name, command
  local name="$1"; shift
  printf '▶ %s: %s\n' "$name" "$*"
  if bash -c "$*" >"$log" 2>&1; then results+=("PASS  $name"); else results+=("FAIL  $name"); fail=1; echo "---- $name output (last 40 lines) ----"; tail -40 "$log"; fi
}
script_exists() { [ -f package.json ] && grep -Eq "\"$1\"[[:space:]]*:" package.json; }

pm=npm; { [ -f bun.lockb ] || [ -f bun.lock ]; } && pm=bun; [ -f pnpm-lock.yaml ] && pm=pnpm; [ -f yarn.lock ] && pm=yarn
r() { case "$pm" in bun) echo "bun run $1";; pnpm) echo "pnpm run $1";; yarn) echo "yarn $1";; *) echo "npm run $1";; esac; }

if [ -f package.json ]; then
  [ -d node_modules ] || run install "$pm install"
  if script_exists typecheck; then run typecheck "$(r typecheck)"
  elif script_exists check-types; then run typecheck "$(r check-types)"
  elif [ -f tsconfig.json ]; then run typecheck "npx --no-install tsc --noEmit"; fi
  script_exists lint && run lint "$(r lint)"
  if script_exists test; then run test "$(r test)"; elif [ "$pm" = bun ]; then run test "bun test"; fi
  [ $quick -eq 0 ] && script_exists build && run build "$(r build)"
fi
if [ -f Cargo.toml ]; then
  run cargo-check "cargo check --all-targets"
  run clippy "cargo clippy --all-targets -- -D warnings"
  run cargo-test "cargo test"
fi
if [ -f pyproject.toml ] || [ -f requirements.txt ]; then
  command -v ruff >/dev/null && run ruff "ruff check ."
  command -v pytest >/dev/null && run pytest "pytest -q"
fi
[ -f go.mod ] && { run go-vet "go vet ./..."; run go-test "go test ./..."; }
[ -f pubspec.yaml ] && command -v flutter >/dev/null && { run dart-analyze "flutter analyze"; run flutter-test "flutter test"; }
[ -f foundry.toml ] && command -v forge >/dev/null && run forge-test "forge test"

echo; echo "== starkstack preflight =="
[ ${#results[@]} -eq 0 ] && echo "No recognised checks found — add typecheck/lint/test/build scripts." && exit 1
printf '%s\n' "${results[@]}"
[ $fail -eq 0 ] && echo "RESULT: PASS" || echo "RESULT: FAIL"
rm -f "$log"; exit $fail

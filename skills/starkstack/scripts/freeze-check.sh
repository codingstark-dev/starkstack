#!/usr/bin/env bash
# starkstack freeze — PreToolUse hook for Edit|Write.
# If .starkstack/freeze exists, only paths matching a line in it (prefix match, relative to repo root) may be edited.
# Enable with /starkstack:careful freeze <dir>; disable by deleting .starkstack/freeze.
set -u
input="$(cat)"
root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
f="$root/.starkstack/freeze"
[ -f "$f" ] || exit 0

if command -v jq >/dev/null 2>&1; then
  p="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty')"
else
  p="$(printf '%s' "$input" | python3 -c 'import sys,json;t=json.load(sys.stdin).get("tool_input",{});print(t.get("file_path") or t.get("path") or "")')"
fi
[ -z "$p" ] && exit 0
rel="${p#"$root"/}"
case "$rel" in .starkstack/*) exit 0 ;; esac

while IFS= read -r allow || [ -n "$allow" ]; do
  allow="${allow%%#*}"; allow="$(printf '%s' "$allow" | tr -d '[:space:]')"
  [ -z "$allow" ] && continue
  case "$rel" in "$allow"*) exit 0 ;; esac
done < "$f"

echo "starkstack freeze: '$rel' is outside the frozen scope ($(tr '\n' ' ' < "$f")). Ask the user to widen it, or remove .starkstack/freeze." >&2
exit 2

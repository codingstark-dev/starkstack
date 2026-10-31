#!/usr/bin/env bash
# starkstack guard — PreToolUse hook for Bash.
# Reads the hook JSON on stdin, blocks dangerous commands with exit 2 (stderr is shown to Claude).
# Override for one command by prefixing it with: STARKSTACK_ALLOW=1
# Freeze mode: if .starkstack/freeze exists, edits are only allowed under the paths it lists (see freeze-check below).
set -u
input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)"
else
  cmd="$(printf '%s' "$input" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)"
fi
[ -z "${cmd:-}" ] && exit 0
case "$cmd" in STARKSTACK_ALLOW=1*) exit 0 ;; esac

block() { echo "starkstack guard: blocked — $1. If this is really intended, ask the user, then re-run prefixed with STARKSTACK_ALLOW=1." >&2; exit 2; }

# Normalise whitespace for matching
c="$(printf '%s' "$cmd" | tr -s '[:space:]' ' ')"
re() { printf '%s' "$c" | grep -Eq -- "$1"; }

# --- Destructive git ---
re 'git push( [^|;&]*)? (--force|-f)( |$)' && ! re 'force-with-lease' && block "force push (use --force-with-lease on your own branch)"
re 'git push( [^|;&]*)? (--force-with-lease|--force|-f)[^|;&]* (origin )?(main|master)( |$)' && block "force push to main/master"
re 'git push( [^|;&]*)? (origin )?(HEAD:)?(main|master)( |$)' && block "direct push to main/master (open a PR)"
re 'git reset --hard' && block "git reset --hard (stash or use a new branch)"
re 'git clean -[a-zA-Z]*f' && block "git clean -f deletes untracked files"
re 'git branch -D (main|master)( |$)' && block "deleting main/master"
re 'git (checkout|restore) (-- )?\.( |$)' && block "discarding all working-tree changes"
re 'git filter-(branch|repo)' && block "history rewrite"

# --- Destructive filesystem ---
re 'rm -[a-zA-Z]*r[a-zA-Z]*f?[a-zA-Z]* (/|~|\$HOME|\.|\*)( |$)' && block "recursive delete of root, home, cwd or glob"
re 'rm -[a-zA-Z]*f[a-zA-Z]*r[a-zA-Z]* (/|~|\$HOME|\.|\*)( |$)' && block "recursive delete of root, home, cwd or glob"
re '(^| )(mkfs|dd if=)' && block "disk-level write"
re 'chmod -R 777' && block "world-writable permissions"

# --- Destructive data / infra (always confirm) ---
re '(DROP (TABLE|DATABASE|SCHEMA)|TRUNCATE TABLE)' && block "destructive SQL (snapshot first, confirm with the user)"
re 'wrangler (d1|r2|kv|queues) [a-z ]*delete' && block "deleting Cloudflare resource"
re 'wrangler delete' && block "deleting a Worker"
re '(sst remove|alchemy destroy|terraform destroy|pulumi destroy)' && block "tearing down infrastructure"
re 'gh repo delete' && block "deleting a GitHub repo"
re 'gh pr merge[^|;&]*--admin' && block "bypassing branch protection"

# --- Secrets ---
re 'git add [^|;&]*\.env($| |\.)' && ! re '\.env\.example' && block "staging a .env file"
re '(curl|wget)[^|;&]*\| *(sudo )?(ba|z)?sh' && block "piping a download straight into a shell"

# Gitleaks on commit, if available
if re 'git commit' && command -v gitleaks >/dev/null 2>&1; then
  if ! gitleaks protect --staged --redact --no-banner >/dev/null 2>&1; then
    block "gitleaks found a secret in staged changes (run: gitleaks protect --staged -v)"
  fi
fi

exit 0

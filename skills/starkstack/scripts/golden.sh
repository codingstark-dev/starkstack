#!/usr/bin/env bash
# Golden-response snapshots for brownfield features and migrations.
#   golden.sh record <base-url> [endpoints-file]   → saves responses to .starkstack/baseline/golden/
#   golden.sh diff   <base-url> [endpoints-file]   → re-fetches and diffs against the recording (exit 1 on drift)
# endpoints-file (default .starkstack/baseline/endpoints.txt): one per line, "METHOD /path [json-body]"; '#' comments ok.
# Auth: one extra header for a TEST user, e.g. STARKSTACK_HEADER="Authorization: Bearer <test-token>".
# Volatile JSON keys stripped before compare: STARKSTACK_IGNORE="id,createdAt,updatedAt,requestId,timestamp"
set -u
mode="${1:-}"; base="${2:-}"; list="${3:-.starkstack/baseline/endpoints.txt}"
[ -z "$mode" ] || [ -z "$base" ] && { sed -n '2,7p' "$0"; exit 2; }
[ -f "$list" ] || { echo "No endpoints file at $list — create it (e.g. 'GET /api/health')."; exit 2; }
dir=.starkstack/baseline/golden; mkdir -p "$dir"
ignore="${STARKSTACK_IGNORE:-id,createdAt,updatedAt,requestId,timestamp,date}"
drift=0

normalise() { python3 -c '
import sys,json
ign=set(sys.argv[1].split(","))
raw=sys.stdin.read()
def strip(o):
    if isinstance(o,dict): return {k:strip(v) for k,v in sorted(o.items()) if k not in ign}
    if isinstance(o,list): return [strip(x) for x in o]
    return o
try: print(json.dumps(strip(json.loads(raw)),indent=2,ensure_ascii=False))
except Exception: print(raw)
' "$ignore"; }

while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"; [ -z "${line// }" ] && continue
  method="$(echo "$line" | awk '{print $1}')"; path="$(echo "$line" | awk '{print $2}')"; body="$(echo "$line" | cut -d' ' -f3-)"
  [ "$body" = "$line" ] && body=""
  key="$(echo "$method$path" | tr -c 'A-Za-z0-9' '_')"
  args=(-s -o /tmp/ss_body -w '%{http_code}' -X "$method")
  [ -n "$body" ] && args+=(-H 'content-type: application/json' --data "$body")
  [ -n "${STARKSTACK_HEADER:-}" ] && args+=(-H "$STARKSTACK_HEADER")
  status="$(curl "${args[@]}" "$base$path")"
  current="$(printf 'STATUS %s\n' "$status"; normalise < /tmp/ss_body)"
  if [ "$mode" = record ]; then printf '%s\n' "$current" > "$dir/$key.txt"; echo "recorded $method $path ($status)"
  else
    if [ ! -f "$dir/$key.txt" ]; then echo "NEW      $method $path ($status) — no baseline"; continue; fi
    if diff -u "$dir/$key.txt" <(printf '%s\n' "$current") > /tmp/ss_diff; then echo "SAME     $method $path"
    else echo "DRIFT    $method $path"; sed 's/^/    /' /tmp/ss_diff | head -40; drift=1; fi
  fi
done < "$list"
rm -f /tmp/ss_body /tmp/ss_diff
[ "$mode" = diff ] && { [ $drift -eq 0 ] && echo "golden: no drift" || echo "golden: DRIFT found — confirm every change is intended (additive) before proceeding"; }
exit $drift

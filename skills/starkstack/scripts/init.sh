#!/usr/bin/env bash
# Create .starkstack/ working state (idempotent).
set -u
cd "${1:-.}" || exit 1
d=.starkstack; mkdir -p "$d/baseline" "$d/scans"
today="$(date +%Y-%m-%d)"
[ -f "$d/decisions.md" ] || printf '# Decisions & assumptions\n\n<!-- ASSUMED (%s): … — reason; revisit when … -->\n' "$today" > "$d/decisions.md"
[ -f "$d/decisions.log" ] || printf 'time\tphase\tdecision\treason\tevidence\tresult\n' > "$d/decisions.log"
[ -f "$d/learnings.md" ] || printf '# Learnings (overrides starkstack defaults)\n\n' > "$d/learnings.md"
[ -f "$d/handoff.md" ] || printf '# Handoff\n\n_No session handed off yet._\n' > "$d/handoff.md"
[ -f GLOSSARY.md ] || printf '# Glossary\n\n| Term | Meaning | Not to be confused with |\n|---|---|---|\n' > GLOSSARY.md
if [ -f .gitignore ] && ! grep -q '^\.starkstack/' .gitignore; then
  printf '\n# starkstack working state (remove this line to share it with the team)\n.starkstack/\n' >> .gitignore
fi
printf '%s\tintake\tinit .starkstack\t-\tinit.sh\tok\n' "$(date -u +%FT%TZ)" >> "$d/decisions.log"
echo "starkstack: state ready in $d/ (decisions.md, decisions.log, learnings.md, handoff.md, baseline/, scans/)"

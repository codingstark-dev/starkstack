# starkstack

**One engineer, every role.** starkstack is a Claude Code plugin that runs a full software team as gated playbooks. Each step leaves evidence behind, so you can check it was actually done.

```
intake → research → spec (numbered agents) → plan reviews → build (TDD, parallel worktrees)
       → code review → QA → security → ship → canary → retro
```

It also covers existing codebases:

- **`/starkstack:feature`** adds a feature without breaking anything.
- **`/starkstack:migrate`** moves the project off a stack you're leaving.

In plain words: you describe what you want. starkstack researches it, plans it, builds it with a team of specialist agents, tests it, security-checks it, and opens the GitHub issues and PRs. It explains every report in plain language too, so non-engineers can follow along.

## Install

**Claude Code (plugin, recommended).** Push this folder to `github.com/codingstark-dev/starkstack`, then run:

```
/plugin marketplace add codingstark-dev/starkstack
/plugin install starkstack@starkstack
```

**Local, without a marketplace:**

```
claude --plugin-dir ./starkstack
```

**Skill only (claude.ai or any agent):** upload `starkstack.skill`, or copy `skills/starkstack/` into `~/.claude/skills/`.

**Optional tools.** Everything works without these, but the security scans cover more ground with them:

```
brew install gh jq gitleaks trufflehog osv-scanner semgrep trivy && pipx install zizmor
```

## Make it yours

starkstack follows your stack, not a fixed one. It decides in this order, and the first match wins:

1. What you say in the request
2. What the repo already uses
3. `.starkstack/defaults.md` in the project
4. `~/.claude/starkstack/defaults.md`, which applies to all your projects
5. Learnings from earlier runs
6. Research
7. A modern edge-first fallback

To set your defaults once, copy `skills/starkstack/assets/defaults.md` to `~/.claude/starkstack/defaults.md` and fill it in.

## Commands

| Command | What it does |
|---|---|
| `/starkstack <idea>` | Picks the right playbook and runs the whole pipeline |
| `/starkstack:research` | Researches the stack, market and pricing; writes an HTML or MD report with plain-words summaries |
| `/starkstack:grill` | Interviews you until the plan has no open branches; updates the glossary and ADRs |
| `/starkstack:spec` | Writes the PRD, architecture and a tracer-bullet ticket board with numbered agents and waves (`--github` mirrors it as an Epic and sub-issues) |
| `/starkstack:autoplan` | Runs CEO, Design, DX, Security and Eng reviews, each scored 0–10; the gate is ≥ 7 |
| `/starkstack:build` | Runs one agent per ticket, in parallel worktrees, test-first |
| `/starkstack:review` | Reviews against the spec and standards, runs a model panel and a blast-radius check |
| `/starkstack:qa` | Runs e2e tests, does a real-browser pass, checks accessibility and performance, writes a `verify-<app>` skill |
| `/starkstack:secure` | Builds a threat model, runs the scanners, does a manual OWASP / bug-bounty review, then raises an issue (or advisory), a fix and a PR for each finding |
| `/starkstack:ship` | Runs preflight, commits, opens a PR with evidence, and watches CI and review threads |
| `/starkstack:land` | Merges, releases, deploys, runs a canary check and documents the rollback |
| `/starkstack:retro` | Writes a retro with real numbers and promotes learnings |
| `/starkstack:onboard` | Maps an existing codebase (read-only) |
| `/starkstack:feature` | Adds a brownfield feature: takes a baseline, builds a compatibility matrix (APIs, agents, links, data, integrations), keeps changes additive behind a flag, and runs a regression gate |
| `/starkstack:migrate` | Migrates a stack: writes migration docs, adds characterization tests, cuts over strangler-fig style, migrates data with dual-write, backfill and verification, then removes obsolete code |
| `/starkstack:deps` | Upgrades dependencies safely |
| `/starkstack:hotfix` | Handles an incident: mitigate, fix, postmortem |
| `/starkstack:investigate` | Finds a root cause, or explains how or why something works |
| `/starkstack:arena` | Builds competing designs, judged against a private rubric |
| `/starkstack:handoff` | Writes a handoff or picks one up to resume a session |
| `/starkstack:learn` | Records, lists or prunes project learnings |
| `/starkstack:careful` | Shows guard status, or freezes and unfreezes edits to a folder |

Flags:

- `--auto` merges and deploys on green CI.
- `--fast` runs a shortened pipeline for small changes.

## Agents (`agents/`)

| Agent | Role |
|---|---|
| researcher | Researches the stack and market |
| 1 · designer | Design |
| 2 · architect | System architecture |
| 3 · db-engineer | Database work |
| 4 · backend-dev | Backend code |
| 5 · frontend-dev | Frontend code |
| 6 · devops | Infrastructure and deploys |
| 7 · test-engineer | Tests |
| 8 · qa-tester | QA |
| 9 · security-tester | Security review |
| 10 · reviewer | Code review |
| 11 · release-engineer | Releases |
| 12 · tech-writer | Documentation |
| migration-lead | Runs migrations |

The builder agents run in isolated git worktrees, so parallel work can't collide.

## Safety (`hooks/`)

The `guard.sh` hook is a PreToolUse hook on Bash. It blocks:

- force-pushes and direct pushes to main
- `reset --hard`, `clean -f` and history rewrites
- `rm -rf` on root, home or the current directory
- destructive SQL
- Cloudflare resource deletes and infrastructure teardown
- `gh pr merge --admin`
- staging `.env` files
- `curl | sh`
- commits that gitleaks flags

To run one blocked command deliberately, prefix it with `STARKSTACK_ALLOW=1`.

The `freeze-check.sh` hook limits edits to the folders you freeze with `/starkstack:careful freeze <dir>`.

## Scripts (`skills/starkstack/scripts/`)

| Script | What it does |
|---|---|
| `init.sh` | Creates the `.starkstack/` working state |
| `detect.sh` | Fingerprints the stack |
| `preflight.sh` | Runs typecheck, lint, test and build for any stack |
| `secscan.sh` | Runs every available scanner and the built-in grep checks |
| `golden.sh` | Records API responses, then diffs against them later |
| `linkcheck.py` | Crawls the site and reports broken or lost links |

## Working state (`.starkstack/`)

| File | Holds |
|---|---|
| `decisions.md` | Assumptions and accepted risks |
| `decisions.log` | Audit trail (TSV) |
| `research.html` | The research report |
| `spec.md` | The spec and ticket board |
| `compat.md` | The compatibility matrix |
| `qa-report.md` | QA results |
| `security-report.md` | Security findings |
| `handoff.md` | Handoff notes for the next session |
| `learnings.md` | Project learnings |
| `baseline/` | Baseline snapshots |
| `scans/` | Scanner output |

## Credits

starkstack takes ideas from four open-source skill packs:

| Source | Ideas taken |
|---|---|
| [garrytan/gstack](https://github.com/garrytan/gstack) | Role commands, scored plan reviews, CSO, canary, retro |
| pstack by Lauren Tan (@poteto), from Cursor's plugin collection | Playbook routing, model panels, arena, blast radius, decision logs, verify-app skills |
| [mattpocock/skills](https://github.com/mattpocock/skills) | Grilling, glossary, ADRs, tracer-bullet tickets, TDD |
| [obra/superpowers](https://github.com/obra/superpowers) | Brainstorm-to-plan-to-subagent development, verification before completion, worktrees |

MIT.

# Phase 1 — Researcher

**Role:** staff engineer and market analyst. Reads everything new before the
team commits to a stack.

## Steps
1. **Frame 4–6 questions** from intake. Typical ones:
   - What's the best current stack for *this* product?
   - What changed in the last 12 months (versions, deprecations, pricing,
     limits)?
   - Who are the competitors and what do they ship?
   - What are users in this space starting to expect?
   - What are the risks: lock-in, cost at scale, compliance, security?
2. **Fan out.** With the Agent tool, run one `researcher` subagent per
   question in parallel, each told to return findings with source URLs and
   dates. Without subagents, research the questions one at a time.
   - Use one search per distinct item. Combined queries come back shallow.
   - Prefer official docs, changelogs, GitHub releases, pricing pages and
     status pages over listicles.
   - Use context7 or docs MCPs for library APIs if they're connected.
3. **Score options** against the user's resolved defaults (SKILL.md §5), 1–5 on each of:
   - fit for this product
   - speed to ship
   - cost at 1k and 100k users
   - scale ceiling
   - ecosystem maturity
   - lock-in
   - security posture
   - team familiarity
4. **Recommend** one option. Name the runner-up and the condition under which
   you'd switch to it.
5. **Write the report** in the chosen format.
   - HTML: fill in `assets/research.html`.
   - MD: use the same section order.
   - Save to `.starkstack/research.html` (or `.md`).
   - In claude.ai, publish the HTML as an artifact.

## Report sections (in this order)
1. **TL;DR**: recommendation, why, and the biggest risk
2. **In plain words**: one paragraph a non-engineer co-founder or investor
   would understand
3. **Market snapshot**: trends, competitors table, gaps and opportunities
4. **Stack options**: scored table and a verdict
5. **Recommended architecture**: Mermaid diagram plus a component list
6. **Cost model**: monthly cost at roughly 1k, 10k and 100k users, with
   assumptions stated
7. **Risks and mitigations**
8. **Assumptions and open questions**: copy these into `decisions.md`
9. **Sources**: linked and dated

End every technical section with a line starting **"What this means:"**,
written in plain words.

## Quality bar
- Every version number, price and limit has a source from this session, dated
  "as of Mon YYYY".
- Paraphrase sources. If you couldn't verify something, say "unverified"
  rather than guess.
- Keep the report readable in about 5 minutes. Put deep detail in collapsible
  `<details>` blocks.

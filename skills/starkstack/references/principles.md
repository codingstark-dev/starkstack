# Principles

Apply these when a task triggers them. If you cite a principle, say what
decision it changed. Naming it without that is decoration.

## Alignment
- **Grill before you build.** Interview until every branch of the design is
  resolved or explicitly assumed. Misalignment is the most common agent
  failure.
- **Shared language.** Keep domain terms in `GLOSSARY.md` and use them in
  code, tickets and reports. That makes the output shorter and keeps it from
  drifting.
- **Record hard decisions.** Write an ADR whenever someone would later ask
  "why is it like this?"

## Less code
- **Subtract before you add.** Can you delete, reuse or configure instead of
  writing new code?
- **Smallest complete change.** No speculative abstractions, flags or
  options.
- **Minimise reader load.** Use clear names and few concepts. Comments
  explain *why*, never *what*. If a comment states a constraint, turn it into
  a type, a check or a test.

## Architecture
- **Model the domain.** Types mirror real concepts; make illegal states
  unrepresentable.
- **Boundary discipline.** Validate and parse at the edges (HTTP, queues,
  webhooks, LLM output). Inside the boundary, trust the types.
- **Deep modules.** Small interfaces with real functionality behind them and
  clean seams. Shallow pass-through layers add cost without value.
- **Idempotent operations.** Retries, webhooks and queues will deliver twice.
- **Platform-native.** Use the primitives of the platform you're on (edge
  workers, managed DB, queues, object storage) before adding new services.
  Keep state close to users; avoid a central bottleneck.

## Proof
- **Prove it works.** Run it on the real interface: browser, CLI, API call.
  Unit tests alone don't prove a feature.
- **Fix root causes.** A fix with no explained cause is a guess.
- **Verifiable units.** Order work so each step can be checked on its own.
- **Evidence before claims.** Never write "done", "fixed" or "passing"
  without the command output that shows it.

## Delegation
- **Guard the context window.** Send bulk reading, searching and parallel
  exploration to subagents, and keep only their conclusions.
- **Separate before parallelising.** Parallel writers get separate worktrees
  or disjoint file sets.
- **Model diversity over personas.** For reviews that matter, ask different
  models, not the same model in different hats.

## Safety
- **Reversible by default.** Branches over main, PRs over pushes, soft delete
  over hard delete.
- **Secrets never touch git.** Use platform secret stores only, and rotate
  any secret that was ever exposed.
- **Least privilege.** Scope tokens, Actions permissions, bindings and IAM to
  exactly what's needed.

# Fallback stack

Use this only when nothing outranks it in the resolution order in SKILL.md §5
(the user's words, the existing repo, a defaults file, learnings, research).

The stack is modern, edge-first and quick to ship. Research may replace any
part of it.

- **Language:** TypeScript (strict). Use Rust or Go for CLIs and hot paths,
  Swift or Kotlin for native mobile, Flutter or React Native for
  cross-platform apps.
- **Runtime and API:** Bun or Node with Hono, which runs on Workers, Bun,
  Node and Deno. Validate input with Zod or Valibot at the boundary.
- **Web:** React with Next.js, TanStack Start or Astro (for content sites),
  plus Tailwind. Give it a distinctive design, not a template.
- **Platform:** Cloudflare (Workers, D1, R2, KV, Durable Objects, Queues),
  Vercel, Fly.io or AWS. Pick the one that fits the workload and the user's
  existing accounts.
- **Database:** Postgres (Neon, Supabase or RDS) for relational workloads at
  scale, SQLite or D1 for edge and small apps. Use Drizzle or Prisma for
  migrations.
- **Auth:** Better Auth, Clerk or the platform's own auth. Never roll your
  own crypto.
- **Infrastructure as code:** SST, alchemy, Terraform or Pulumi. Turborepo or
  Nx for monorepos.
- **AI features:** a provider SDK behind a thin adapter, RAG on pgvector or a
  managed vector store, and evals for anything that uses an LLM.
- **Quality:** Vitest or bun test, Playwright for end-to-end, ESLint or Biome,
  GitHub Actions, Conventional Commits, the `gh` CLI.

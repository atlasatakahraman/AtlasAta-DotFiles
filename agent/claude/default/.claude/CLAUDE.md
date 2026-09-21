# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

# Knowledge vault — C:\obsidian\root

My knowledge base lives in an Obsidian vault at `C:\obsidian\root`. My repositories are checked out
at `C:\dev\<remote-name>\` — they left the vault on 2026-09-06; `10-Repos/` is an index of them.
It holds who I am, my hard rules, my repo wikis, and my Rust/Tauri knowledge.

**Before answering anything about my preferences, my rules, my projects, my repos, or my past
decisions: query the vault.** Not guess, not ask me again, not answer from the prompt alone.
This fires on *questions* too, not only on edits — "how would X work in my monorepo" is a vault
query before it is an answer.

- `00-Meta\00-MOC-Root.md` — index of everything
- `00-Meta\Identity.md` — who I am, what I know, how to talk to me
- `00-Meta\Hard-Rules.md` — bun, shadcn, deps, licensing, Tauri/Wayland, tooling
- `00-Meta\Retrieval-Protocol.md` — long form of the rules below

## Retrieval — hard rules

Tiers run **in order**. Do not skip down. Do not start at the bottom.

| # | Tier | Use for |
|---|---|---|
| 0 | The `UserPromptSubmit` hook's injected note names — **vault notes only** | Breadcrumbs. A snippet is not the note — follow the name into tier 1. |
| 1 | `00-MOC-Root.md` → the `00-MOC-*.md` it points to → the note | "where is X". Most questions end here. |
| 2 | `ctx_search(queries: [...])` — **only in a session launched in the vault** | "what did I write about X". Batch every question into one call. Anywhere else, skip it: see Tools. |
| 3 | `graphify query "<q>" --budget 1500` | "how does X connect to Y". Free, AST-only, bounded. |
| 4 | Native `Read` of **one named file** | Only when 1–3 failed. |

**Stop-check:** about to `Read` or `Bash` a `C:\obsidian\root` path without having run tiers 1–3?
That is the violation. Go back to the MOC.

**Never sweep the vault.** No `ls`, `find`, `grep`, `glob`, or `dir` over vault directories — the
MOC answers "where is X" in one hop, and a sweep burns context re-deriving what it already says.
**Never sweep `C:\dev` blind either** — that is where `node_modules/` and `target/` live now.

A vault note's median size is ~1.8 KB and 69% are under 4 KB (measured 2026-09-21) — once a tier
has *named* the file, native `Read` on that one file is correct and cheaper than a ctx round trip.

## Tools — hard rules

Full table: `00-Meta\Hard-Rules.md#Tooling`. The non-negotiable subset:

- **`ctx_search` searches the project the session was *launched* in.** Its `project` parameter does
  not redirect it (measured 2026-09-21, context-mode v1.0.169): from a session launched outside the
  vault, `project: "global"` returns `"Knowledge base is empty"` and `project: "C:\obsidian\root"`
  returns only that session's own events — never vault notes, even with a complete index. It
  worked on 2026-08-22; context-mode's behaviour changed. **Outside the vault, use tier 0 then a
  `Read` of the named note.**
- **Retrieval health, zero tokens:** `bun --bun ~/.claude/hooks/brain-doctor.mjs --pretty` — asserts
  the vault index is complete and six vault-shaped questions return the right note.
- **`ctx_execute` / `ctx_execute_file` instead of Bash + Read** whenever output will be filtered,
  counted, parsed, or aggregated. Bash stays right for short fixed output and for mutating state
  (git, mkdir, mv).
- **`ctx_fetch_and_index` instead of `WebFetch`.** `WebSearch` is used directly — it returns titles
  + URLs, there is nothing to sandbox. Pattern: `WebSearch` to find → `ctx_fetch_and_index` to read
  → `ctx_search` to re-query.
- **Context7 for library/framework/API docs** — versioned, skips page fetching. Never `WebSearch`
  for API syntax, config, or migration steps.
- **All file writes are native `Write` / `Edit`.** `ctx_execute` sandboxes the filesystem and
  discards it; nothing written there persists.
- **`graphify update .`** to rebuild — free, AST only, no tokens. `/graphify . --update` is the
  semantic pass and **costs tokens**: a deliberate act, never routine maintenance.
- Break-even for context-mode over `Read` is **~4 KB / ~1,100 tokens**. Above it the win is large
  (88× on a 96 KB file). Below it, plain `Read` is cheaper.
- **`bunx --bun`, never bare `bunx`.** Without the flag bunx honours a package's
  `#!/usr/bin/env node` shebang and hands execution to node, whose resolver then fails on the temp
  install — `ERR_MODULE_NOT_FOUND` for a transitive dep the package clearly ships. Verified
  2026-08-24 with `bunx shadcn`, which died on `Cannot find package 'zod'`; `bunx --bun shadcn@latest`
  works.

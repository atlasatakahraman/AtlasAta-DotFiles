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

Identity and the full Hard-Rules are loaded here, whole, every session. Never move either behind a
link or into a hook: a hook's context is cut to a 2,000-char preview past 10,000 chars, and a cap
that kept it under once dropped the rules (2026-10-09). `brain-doctor`'s `priming` check guards both.

@C:/obsidian/root/00-Meta/Identity.md
@C:/obsidian/root/00-Meta/Hard-Rules.md

## Retrieval — hard rules

Tiers run **in order**. Do not skip down. Do not start at the bottom.

| # | Tier | Use for |
|---|---|---|
| 0 | The `UserPromptSubmit` hook's injected notes — **vault notes only** | Breadcrumbs, sometimes with the passage itself. A snippet is not the note — follow the name into tier 1. |
| 1 | `00-MOC-Root.md` → the `00-MOC-*.md` it points to → the note | "where is X". Most questions end here. |
| 2 | `knowledge find "<q>"` — **from any folder** | "what did I write about X": ranked notes, each with its best passage. One call per question. |
| 3 | `knowledge graph <note> [<other note>]` | "how does X connect to Y": a note's links in and out, or the path between two. Free, ~25 ms. |
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

- **`knowledge find` and `knowledge graph` read the vault index wherever the session was
  launched** (`~/.cargo/bin/knowledge`, vault audit Stage 3). `knowledge find "<q>" --repo [<name>]`
  searches the checkouts' docs, `--captures` what was kept or fetched in the last 14 days (Stage 4).
- **Retrieval health, zero tokens:** `bun --bun ~/.claude/hooks/brain-doctor.mjs --pretty` — asserts
  the vault index is complete and 33 vault-shaped questions return the right note.
- **Work tools: `knowledge keep`, `knowledge fetch`.** Pipe a large output through
  `<cmd> | knowledge keep "<label>" --q "<what you need>"` instead of reading it whole: it is
  stored, and only the matching sections print (2,000 chars at most). Bash stays right for short
  fixed output and for mutating state (git, mkdir, mv).
- **`knowledge fetch <url> --q "<q>"` instead of `WebFetch`:** the page as Markdown, private
  addresses refused. `WebSearch` is used directly — it returns titles + URLs. Pattern: `WebSearch`
  to find → `knowledge fetch` to read → `knowledge find "<q>" --captures` to re-query.
- **Context7 for library/framework/API docs** — versioned, skips page fetching. Never `WebSearch`
  for API syntax, config, or migration steps.
- **All file writes are native `Write` / `Edit`.**
- **graphify is for the repos' code graphs**, merged by `bun --bun ~/.claude/hooks/brain-graph.mjs`
  into what the graphify MCP serves; the vault's links are `knowledge graph`'s. `/graphify . --update`
  is the semantic pass and **costs tokens**: a deliberate act, never routine maintenance.
- `keep` prints at most 2,000 chars, so an output or file under that is cheaper read whole.
- **`bunx --bun`, never bare `bunx`.** Without the flag bunx honours a package's
  `#!/usr/bin/env node` shebang and hands execution to node, whose resolver then fails on the temp
  install — `ERR_MODULE_NOT_FOUND` for a transitive dep the package clearly ships. Verified
  2026-08-24 with `bunx shadcn`, which died on `Cannot find package 'zod'`; `bunx --bun shadcn@latest`
  works.

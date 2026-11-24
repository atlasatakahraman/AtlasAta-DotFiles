# Knowledge vault — C:\obsidian\root

My knowledge base lives in an Obsidian vault at `C:\obsidian\root`. My repositories are checked out
at `C:\dev\<remote-name>\` — they left the vault on 2026-09-06; `10-Repos/` is an index of them.

**Before answering anything about my preferences, my rules, my projects, my repos, or my past
decisions: query the vault.** Not guess, not ask me again, not answer from the prompt alone.
This fires on *questions* too, not only on edits — "how would X work in my monorepo" is a vault
query before it is an answer.

- `00-Meta\00-MOC-Root.md` — index of everything
- `00-Meta\Retrieval-Protocol.md` — long form of the rules below

Identity and the full Hard-Rules are loaded here, whole, every session. Never move either behind a
link or into a hook: a hook's context is cut to a 2,000-char preview past 10,000 chars, and a cap
that kept it under once dropped the rules (2026-10-09). `knowledge doctor`'s `priming` check guards both.

@C:/obsidian/root/00-Meta/Identity.md
@C:/obsidian/root/00-Meta/Hard-Rules.md

## Retrieval — hard rules

Tiers run **in order**. Do not skip down. Do not start at the bottom. Tools: [[Hard-Rules#Tooling]].

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

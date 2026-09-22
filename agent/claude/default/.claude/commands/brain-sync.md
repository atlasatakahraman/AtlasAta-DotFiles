---
description: Refresh the brain - rebuild graphs, re-index, prune phantoms, verify links
---

Bring the brain's indexes back in step with what is on disk. Run in order:

1. **Rebuild the vault graph** — free, AST only, no LLM, no tokens:

```bash
cd /c/obsidian/root && graphify update . --force
```

`--force` is required whenever the rebuild is smaller than the stored graph; without it graphify
refuses to shrink. See [[Conventions]].

2. **Rebuild any repo graph you have touched, then re-merge.** The checkouts live at
   `C:\dev\<remote-name>\` since 2026-09-06 ([[0012-repos-leave-the-vault-index-stays]]) and each
   carries its own `graphify-out/`, built on demand:

```bash
cd /c/dev/<Repo> && graphify update .
```

```bash
cd /c/obsidian/root && graphify merge-graphs graphify-out/graph.json /c/dev/*/graphify-out/graph.json --out graphify-out/merged-graph.json
```

**`merged-graph.json` is what `.mcp.json` serves — not `graph.json`.** Step 1 alone leaves the
served graph stale. The `brain-reindex` hook re-merges automatically after each vault rebuild, so
this step matters when a *repo* graph changed.

3. **Re-index for full-text search:** `bun --bun ~/.claude/hooks/brain-doctor.mjs --repair --pretty`
   re-indexes the vault with the same arguments `brain-reindex` uses (source `brain-vault`),
   rebuilds the graph and hubs, then runs the ten checks.

   To make a repo's code searchable by `ctx_search` in a session launched in that repo.
   `brain-inject` does not read repo DBs: it is scoped to the vault's DB since 2026-09-21.

```bash
bun --bun ~/.claude/plugins/cache/context-mode/context-mode/1.0.169/cli.bundle.mjs index C:/dev/<Repo> --source repo:<Repo> --ext .ts,.tsx,.rs,.md --max-depth 8 --max-files 800
```

4. **Prune phantom index entries.** `context-mode index` is **additive** — it never removes
   entries for files that have been deleted or renamed, so retired notes stay searchable and keep
   being injected into prompts. Report first:

```bash
bun --bun ~/.claude/hooks/brain-prune.mjs
```

Then, if the list looks right:

```bash
bun --bun ~/.claude/hooks/brain-prune.mjs --apply
```

It only considers sources whose label ends in an absolute path that no longer exists. Web sources
(`name::https://…`) and command captures (`batch:…`) are never candidates. Each run backs the
database up to `%TEMP%` before writing and runs `PRAGMA integrity_check` after. A database that
errors is reported as an error and exits non-zero — never as "clean".

This one deletes, unlike the `/brain-lint` idea in [[2026-08-22-brain-memory-compiler]] which
reports and never deletes. Different case: that proposes retiring articles *not retrieved in 90
days*, a heuristic that can discard useful notes. Here the file is already gone from disk — the
index entry is a lie with no information value, and removing it cannot lose knowledge.

5. **Verify referential integrity** — every `[[wikilink]]` resolves, every `checkout:`/`docs:`
   pointer exists on disk. Exits non-zero if anything is broken:

```bash
bun --bun ~/.claude/hooks/brain-verify.mjs
```

**Do not re-derive this check as a shell one-liner.** It was got wrong twice in one run that way —
once from case-sensitivity (Obsidian resolves `[[TheAtlas-Media]]` to `theatlas-media.md`), once
from shell escaping mangling a regex so it skipped three files and printed a confident wrong
count. The script handles case-insensitivity, frontmatter `aliases:`, code-fence stripping (bash
`[[ ... ]]` conditionals are indistinguishable from wikilinks), and treats `80-Assets/` copies as
link targets but not as vault notes.

The deliberate-dangling allowlist lives in the vault — any MOC's **"Known gaps — don't chase
these"** section — not in the script. Add a link there to silence it, with the reason.

6. Report only what changed: node/edge delta, phantoms pruned, and any newly broken links.

**Do not run `/graphify . --update`** unless the user explicitly asks — that is the semantic pass
over docs and images, it dispatches subagents, and it costs real tokens. `graphify update .` is
the routine one.

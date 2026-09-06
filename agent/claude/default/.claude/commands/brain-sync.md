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

3. **Re-index for full-text search:** `/context-mode:ctx-index C:\obsidian\root`

   To make a repo's code searchable — and injectable by `brain-inject`, which iterates every
   content DB:

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

5. **Verify links.** Check every `[[wikilink]]` in `00-Brain/`, `20-Knowledge/` and the
   `10-Repos/*.md` pointer pages resolves to a real note. **Strip code fences first** — the
   dotfiles `agent/` tree contains bash `[[ ... ]]` conditionals that look identical to wikilinks
   and produced ~50 phantom failures. That tree now lives at `C:\dev\AtlasAta-DotFiles`, outside
   the vault, so a vault scan should not reach it at all — if it still appears, something is
   scanning too widely.

6. **Check the pointers resolve.** Every `checkout:` path in `10-Repos/*.md` frontmatter must
   exist on disk. A dead pointer is the index failing at its one job.

7. Report only what changed: node/edge delta, phantoms pruned, and any newly broken links.

Known-dangling and deliberately left alone: `[[claude-tooling]]`, `[[project-ecosystem]]`.
They mark notes worth writing.

**Do not run `/graphify . --update`** unless the user explicitly asks — that is the semantic pass
over docs and images, it dispatches subagents, and it costs real tokens. `graphify update .` is
the routine one.

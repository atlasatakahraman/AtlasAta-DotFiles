# brain: structure

A new folder in the vault. Rare — the existing top-level layout is deliberate and mostly closed.

## Before creating anything

Ask: does this belong in an existing folder? A new top-level directory is almost always wrong.
`20-Knowledge/` takes new *categories* readily; the numbered top level does not grow casually.

## new

1. Name it to sort correctly. Numbered top-level (`00-`…`90-`) is reserved and full;
   `20-Knowledge/` subfolders are plain PascalCase or single words.
2. Create `00-MOC-<Scope>.md` immediately — a folder without a MOC is invisible at retrieval tier 1:

```yaml
---
type: moc
tags: [moc, <scope>]
created: <today>
updated: <today>
status: active
---
```

3. Link the new MOC from its parent MOC, and ultimately from `00-Meta/00-MOC-Root.md`.
4. Update `00-Meta/Conventions.md` "Where things live" if the rule is not obvious from the name.

## edit — reorganising

- Moving notes is safe: Obsidian resolves wikilinks by **name**, not path.
- What *does* break: MOC link lists, and `.graphifyignore` / `.gitignore` path rules.
- After any move, re-run the link check and `graphify update .`.
- **Check `.gitignore` before assuming the graph is broken** — it feeds `.graphifyignore`.

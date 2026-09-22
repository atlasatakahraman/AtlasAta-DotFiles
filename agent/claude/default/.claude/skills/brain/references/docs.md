# brain: docs

A reusable knowledge note. Not repo-specific — anything tied to one repo belongs in that repo's
`docs/`, not here.

## new

1. **Category** → `20-Knowledge/{Rust,Tauri,Case-Studies,Web,Tooling}/`. If none fit, ask before
   inventing a new folder — that is `/brain new structure`.
2. **Filename** kebab-case, `.md`. Existing numbered notes keep their prefixes.
3. **Frontmatter:**

```yaml
---
type: doc
tags: [rust, tauri]          # required, lowercase
aliases: [Alt Name]          # optional, how else you'd search for it
created: <today>
updated: <today>
status: active
---
```

4. **Body.** One concept per note. If it needs two MOC entries, it is two notes.
   Lead with what the reader needs, not with background. Code blocks over prose where the code
   is the answer.
5. **Link it from `20-Knowledge/00-MOC-Knowledge.md`** under its category. A note missing from the
   MOC is unreachable at retrieval tier 1.
6. Add `[[wikilinks]]` to related notes. Dangling links are fine — they mark future notes.

## edit

- Bump `updated:`. Never touch `created:`.
- Preserve `prev:`/`next:`/`parent:` chains — the migrated notes use them for learning paths.
- Superseding: set `status: superseded` on the old note and link forward to the replacement.
  Do not delete; the links pointing at it still resolve.
- Renaming breaks nothing (Obsidian resolves by name) but check the MOC entry still matches.

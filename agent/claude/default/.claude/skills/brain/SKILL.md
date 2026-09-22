---
name: brain
description: Use when creating or editing anything in the second brain vault at C:\obsidian\root - a new folder or structure, a repo/project page, a documentation note, a slash command, a commit, a task or todo, a hook, or a plan. Also use when asked to record a decision, log a session, or write something into the vault. Triggers on "/brain new", "/brain edit", "add this to the brain", "record this decision", "document this".
---

# brain

Router for writing to the second brain at `C:\obsidian\root`.

```
/brain new  <kind> [name]
/brain edit <kind> [name]
```

## Before writing anything

1. Read `C:\obsidian\root\00-Meta\Conventions.md` — frontmatter schema, naming, where things live.
2. Read `00-Meta\Hard-Rules.md` if the change touches code, deps, components, or licensing.
3. Check the target doesn't already exist: `ctx_search`, or `graphify query`.

**Never duplicate a repo's own docs into the vault.** A repo's `docs/` *is* its documentation;
vault pages link inward. `agents-doc-drift.yml` in TheAtlas-Media depends on this.

## Kinds

Load **only** the reference file for the kind being invoked. Do not read the others.

| kind | reference |
|---|---|
| `structure` | `references/structure.md` |
| `repo` | `references/repo.md` |
| `docs` | `references/docs.md` |
| `command` | `references/command.md` |
| `commit` | `references/commit.md` |
| `task` | `references/task.md` |
| `hook` | `references/hook.md` |
| `plan` | `references/plan.md` |

If the kind is ambiguous, ask — do not guess between `docs` and `repo`.

## Always, for every kind

- Frontmatter on every note. `type` and `created` required; `updated` on every edit.
- Wikilinks `[[name]]` for cross-references. A markdown path link is invisible to the graph.
- Link the new note from its folder MOC, or it is unreachable at retrieval tier 1.
- After a batch of changes, `graphify update .` in the vault — free, AST only.
- Commit on `main`. **No feature or chore branches** (`00-Meta/Hard-Rules.md`).

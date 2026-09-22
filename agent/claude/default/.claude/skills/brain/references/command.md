# brain: command

A slash command in `~/.claude/commands/<name>.md` (user scope — works in every project).

## Command or skill?

| | Use |
|---|---|
| You always type it, deterministic steps | **command** — zero passive context cost |
| The agent should invoke it on intent | **skill** — but every skill's description loads into every session |

Default to **command**. Skills are a standing tax; this vault deliberately has one router skill
rather than sixteen.

## new

```markdown
---
description: One line. This is what the agent matches on.
---

Steps, imperative. Reference absolute paths - the command runs from any cwd.
```

- Name it for what it does: `brain-usage`, not `usage`.
- `$ARGUMENTS` interpolates what the user typed after the command.
- Keep it short. A command that needs 200 lines of instruction wants to be a skill.

## edit

Changing `description:` changes when the agent reaches for it — the highest-leverage line in
the file. Test by asking for the thing in your own words and seeing whether it fires.

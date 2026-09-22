# brain: task

Uses the `obsidian-tasks-plugin` format already installed in the vault. Do not invent a syntax.

## new

Tasks live in today's daily note, `30-Sessions/YYYY/MM/YYYY-MM-DD.md`.
**Rollover is 05:00 TST** — a session starting 02:00 belongs to the previous day's note.

```markdown
- [ ] Fix the labeler.yml v5 schema [[theatlas-media]] 📅 2026-08-22 ⏫
```

- `[[wikilink]]` the repo or note it belongs to — that is what makes it findable later
- `📅 YYYY-MM-DD` due · `⏫` high `🔼` medium `🔽` low · `🔁` recurring
- One action per task. "Fix CI" is not a task; "rewrite labeler.yml in v5 schema" is.

## edit

- Complete: `- [x]` with `✅ YYYY-MM-DD`. The plugin queries on this.
- Reschedule: change `📅`, don't delete and recreate — you lose the link context.
- A task open for weeks is either not a task or not real. Say so rather than rescheduling silently.

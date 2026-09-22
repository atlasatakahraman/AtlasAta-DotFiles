---
description: Write today's session note into the brain's 30-Sessions/
---

Write or append to `30-Sessions/YYYY/MM/YYYY-MM-DD.md`.

**Rollover is 05:00 TST.** A session that started at 02:00 belongs to the *previous* day's note.
Compute the date accordingly rather than using today's date blindly.

Frontmatter if creating: `type: session`, `project: brain`, `status: active`, `created`/`updated`.

Capture, in this order:

1. **What was worked on** — one line per thread, `[[wikilinked]]` to the repo or note
2. **Decisions made**, and why. A decision without its reasoning is not worth recording.
3. **What broke**, and whether it was fixed or left
4. **Open threads** — what the next session needs to pick up

Keep it terse and factual. This is a log, not a narrative — no summary of the conversation, no
restating what the code does.

If a decision here deserves to outlive the session, promote it: an ADR in the repo's `Decisions/`,
or a note in `20-Knowledge/`. Link to it from the session note rather than duplicating it.

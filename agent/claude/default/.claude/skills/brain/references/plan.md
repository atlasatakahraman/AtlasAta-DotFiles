# brain: plan

**Delegates.** Plan mode already writes plans to `~/.claude/plans/*.md`. Harvest those — do not
re-author from memory.

## new

1. Find the source: `~/.claude/plans/` for a plan-mode plan, or the conversation.
2. **Where it goes — always the vault**, one repo or many (user instruction, 2026-09-20):
   `40-Plans/YYYY-MM-DD-<slug>/YYYY-MM-DD-<slug>.md` — a folder note, never `plan.md`: every
   basename in the vault is unique. Beside it as needed: `YYYY-MM-DD-<slug>-spec.md`,
   `-implementation.md`, `stages/`, `evidence/`. Never inside a checkout.
3. Frontmatter `type: plan`, `status: draft`, and `project: <repo>` when it concerns one repo.
4. Keep the **Context** section — why, not just what. A plan without its reasoning is unreviewable
   six months later.
5. Run `bun --bun ~/.claude/hooks/brain-hubs.mjs` so it appears in `40-Plans/00-MOC-Plans.md`.

## edit — recording the outcome

This is the part that gets skipped and is worth the most.

- `status: active` while executing, `complete` when done, `superseded` when replaced.
- Add an **Outcome** section: what actually happened, what the plan got wrong, what you'd do
  differently. A plan with no outcome teaches nothing on re-read.
- Findings that outlived the plan get promoted to a `20-Knowledge/` note and linked.

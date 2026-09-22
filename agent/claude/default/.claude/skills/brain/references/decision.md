# brain: decision

Record a decision as an ADR, and keep the ledger (`50-Ops/decisions.jsonl`) in step.

## new — a decision made now (tier 1)

1. **Scope.** One repo → `60-Decisions/Repos/<Remote-Name>/`. The vault, its hooks, or how the
   agent must behave → `60-Decisions/Identity/`.
2. **Number** = the highest `NNNN` in that folder + 1. List the folder first; never reuse one.
   The basename must still be unique across the vault — the slug makes it so.
3. **Check it is new.** Search the folder and `00-MOC-Decisions.md`. If this decision already has
   an ADR, **edit that ADR** — two notes for one decision is worse than none.
4. **Write** `<NNNN>-<slug>.md`: frontmatter per `00-Meta/Conventions.md` (`type: decision`,
   `aliases: [ADR-<NNNN>]`), H1 `<NNNN> — <Title>`, then **Decision**, **Why**, **Rejected**
   (alternatives and why not), **Consequences**, **Related** (wikilinks). One decision per file.
5. **Add it** to the table in `60-Decisions/00-MOC-Decisions.md`.
6. **Ledger:** `bun --bun ~/.claude/hooks/brain-ledger.mjs add --tier 1 --question "<the question>" --answer "<the decision>" --promoted "<vault-relative path>"`

## new --ledger — promote captured answers (tier 2)

1. `bun --bun ~/.claude/hooks/brain-ledger.mjs list` — the verbatim questions and chosen answers
   captured from `AskUserQuestion`, with the options that were `offered` and any `note`.
2. Go through them **with the user**, one at a time. For each:
   - a real decision → write the ADR (steps 1–5 above), then
     `brain-ledger.mjs promote <src> "<vault-relative path>"`. The options not chosen are the
     starting point for **Rejected**; ask for the reasons rather than inventing them.
   - several entries that are one decision → one ADR, promote each `src` to the same path
   - not a decision (a preference already recorded, a one-off) →
     `brain-ledger.mjs promote <src> not-a-decision`
3. The captured answer is the user's literal choice — quote it; do not reword what they chose.

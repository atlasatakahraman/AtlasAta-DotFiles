# brain: commit

**Delegates.** The `commit-commands:commit` skill already does commits well — use it, then write
the vault side. Do not reimplement commit logic here.

## new

1. Invoke `commit-commands:commit` (or `commit-commands:commit-push-pr` if pushing).
2. **`main` only.** No feature or chore branches — `00-Meta/Hard-Rules.md`.
3. Append to `50-Ops/Commits/YYYY-MM.md`: date, repo, short SHA, subject line.
4. If the commit made a decision worth keeping, that is a separate `/brain new plan` or an ADR in
   `60-Decisions/<Repo-Name>/` — a commit message is not a decision record.
   ADRs are central, never inside `10-Repos/<repo>/`; the vault gitignores `10-Repos/*/`.

## Scope discipline

Commit only what the task named. If unrelated changes are dirty, leave them unstaged and say so —
do not sweep the user's in-progress work into your commit.

## edit

Amending is for unpushed commits fixing your own noise. Prefer a new commit otherwise.

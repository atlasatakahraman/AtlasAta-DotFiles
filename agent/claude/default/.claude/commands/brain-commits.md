---
description: Record every commit across the vault and all repos into 50-Ops/Commits/ (one note per commit)
---

Run the stateless commit recorder over the whole of the current month, then report.

1. `bun --bun ~/.claude/hooks/brain-commit.mjs --backfill <YYYY-MM>-01 --dry-run` — show the user
   how many notes would be written.
2. On confirmation, run it again without `--dry-run`.
3. Report: notes written, per repo. A repo with no commits this month gets one line saying so — an
   absent repo is ambiguous between "quiet" and "broken". The month index
   `50-Ops/Commits/commits-<YYYY-MM>.md` is regenerated automatically — **never write it by hand**;
   it is rebuilt from the notes on every record and a hand edit is lost on the next commit.
4. Commit the new notes in the vault with a body saying which range was recorded and why.
5. Report every repo's dirty count and ahead/behind state — uncommitted work is work at risk. A repo
   quiet in the log but with a large dirty count is the opposite of quiet; call that out.

```bash
cd /c/dev && for r in $(ls -d */ | tr -d '/'); do
  [ -d "$r/.git" ] || continue
  printf "%-20s dirty=%-4s %s\n" "$r" "$(git -C "$r" status --porcelain | wc -l)" "$(git -C "$r" status -sb | head -1 | grep -oE 'ahead [0-9]+|behind [0-9]+' | tr '\n' ' ')"
done
```

The recorder is idempotent: re-running it never duplicates a note.

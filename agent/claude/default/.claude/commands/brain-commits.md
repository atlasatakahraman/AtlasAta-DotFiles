---
description: Write a commit digest across the vault and all repos into 50-Ops/Commits/
---

Collect commits for the current month. The checkouts live at `C:\dev\<remote-name>\` since
2026-09-06 ([[0012-repos-leave-the-vault-index-stays]]) — **enumerate the directory, never a
hardcoded list**, or a repo added later is silently missing from every digest:

```bash
SINCE=$(date +%Y-%m-01)
echo "## root — the vault"
git -C /c/obsidian/root log --since="$SINCE" --pretty="- %ad \`%h\` %s" --date=short
cd /c/dev && for r in $(ls -d */ | tr -d '/'); do
  [ -d "$r/.git" ] || continue
  echo "## $r ($(git -C "$r" log --since="$SINCE" --oneline | wc -l))"
  git -C "$r" log --since="$SINCE" --pretty="- %ad \`%h\` %s" --date=short
done
```

Write to `50-Ops/Commits/YYYY-MM.md` with frontmatter (`type: commits`, `project: brain`,
`status: active`). Group by repo, newest first.

**Do not trust the auto-recorded entries already in that file as complete.** `brain-commit` is
`PostToolUse(Bash)` with `async: true` and only ever sees commits made *through the Bash tool* —
commits from your own terminal are invisible to it by design, and async drops more. On 2026-09-07
it had captured 1 of the vault's 9 commits. `git log` is authoritative; the hook is a convenience.

If a repo has no commits this month, say so in one line rather than omitting it — an absent repo
is ambiguous between "quiet" and "broken".

Do not include uncommitted work in the digest, but **do** report every repo's dirty count and
ahead/behind state at the bottom, since that is work at risk:

```bash
cd /c/dev && for r in $(ls -d */ | tr -d '/'); do
  printf "%-20s dirty=%-4s %s\n" "$r" "$(git -C "$r" status --porcelain | wc -l)" "$(git -C "$r" status -sb | head -1 | grep -oE 'ahead [0-9]+|behind [0-9]+' | tr '\n' ' ')"
done
```

A repo that is quiet in the log but has a large dirty count is the opposite of quiet — call that
out explicitly rather than leaving the two facts in separate sections.

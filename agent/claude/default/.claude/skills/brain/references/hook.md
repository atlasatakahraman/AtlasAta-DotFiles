# brain: hook

**Delegates.** The `update-config` skill owns `settings.json` — hooks, permissions, env. Use it.

## new

1. Invoke `update-config` with what should fire and when.
2. **Preserve existing hooks.** `~/.claude/settings.json` already has a `SessionStart` hook running
   `context-mode-cache-heal.mjs`. Add to the `hooks` object; never overwrite it.
3. Hook scripts live in `~/.claude/hooks/`.
4. Document what it does in `20-Knowledge/Tooling/`, or it becomes unexplainable magic in six months.

## Keep hooks small

A hook fires on every matching event in every project. Anything slow or chatty is felt constantly.
One line of output, or none.

## edit

Disabling: remove the entry from `settings.json`, keep the script. Deleting the script makes a
stale reference fail loudly on every session start.

// brain-capture.mjs - SessionEnd + PreCompact. No parsing, no API. Under 100ms.
// Spec: C:\obsidian\root\40-Plans\2026-08-22-brain-memory-compiler.md
import { copyFileSync, existsSync, statSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { spawn } from "node:child_process";
import { guard, readStdin, logicalDate, HOOKS, VAULT } from "./brain-lib.mjs";

guard(); // MUST be first - without this, flush's own `claude -p` re-fires this hook.

// process.execPath is bun.exe; --bun forces the bun runtime, per 00-Brain/Hard-Rules.
const detach = (tag, ...argv) => {
  const c = spawn(process.execPath, ["--bun", ...argv], {
    detached: true,
    stdio: "ignore",
    windowsHide: true,
    env: { ...process.env, CLAUDE_INVOKED_BY: tag },
  });
  c.unref();
};

try {
  const input = readStdin();

  // Promote a FINISHED daily log into 60-Decisions / 20-Knowledge / Hard-Rules. Detached: its
  // `claude -p` runs for minutes, far past any hook timeout. No race with flush - compile only
  // ever reads logs for a past logical day, and flush only ever appends to today's. Runs even
  // when the transcript is missing, because it does not need one.
  detach("brain_compile", join(HOOKS, "brain-compile.mjs"));

  // Token/cost digest, at most once per logical day. The digest file's own mtime IS the gate -
  // usage.py rewrites the whole month every run, so a fresh file means today is already covered
  // and no state file is needed. Detached: it walks every transcript under ~/.claude/projects.
  const day = (t) => logicalDate(new Date(t)).toDateString();
  const d = logicalDate(new Date());
  const month = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
  let stale = true;
  try {
    stale = day(statSync(join(VAULT, "50-Ops", "Usage", `${month}.md`)).mtimeMs) !== day(Date.now());
  } catch {
    /* no digest yet - stale stays true */
  }
  if (stale) {
    const u = spawn("python", [join(VAULT, ".brain", "usage.py"), "--month", month], {
      detached: true,
      stdio: "ignore",
      windowsHide: true,
    });
    u.unref();
  }

  const tp = input.transcript_path;
  if (!tp || !existsSync(tp)) process.exit(0); // Claude Code #13668: empty on some compactions

  const sid = String(input.session_id || "unknown").replace(/[^a-z0-9-]/gi, "");
  const temp = join(tmpdir(), `brain-flush-${sid}.jsonl`);
  copyFileSync(tp, temp);

  detach("brain_flush", join(HOOKS, "brain-flush.mjs"), temp, sid, input.cwd || "");
} catch {
  /* a logging hook must never break a session */
}
process.exit(0);

// brain-capture.mjs - SessionEnd · PreCompact · Stop · SubagentStop. No parsing, no API. Fast.
// Plan: C:\obsidian\root\40-Plans\2026-09-20-vault-governance-overhaul\stages\vault-governance-02-session-capture.md
import { statSync, openSync, readSync, closeSync } from "node:fs";
import { join } from "node:path";
import { spawn } from "node:child_process";
import { guard, readStdin, logicalDate, HOOKS, VAULT, logEvent, readWatermarks, writeWatermark, resolveTranscript } from "./brain-lib.mjs";

guard(); // MUST be first - without this, flush's own `claude -p` re-fires this hook.

const dry = process.argv.includes("--dry-run");

// Stop fires after EVERY assistant turn. A session that compacts and keeps going never reaches
// SessionEnd, so Stop is what captures its tail - at most once per 20 minutes per session, or it
// would be a model call per turn. brain-flush's watermark makes a repeat capture send only what is
// new, so extra capture points cannot duplicate content into the daily note.
const STOP_EVERY_MS = 20 * 60_000;

// The vault-health Routine (Stage 06) is a claude session, so it fires Stop/SessionEnd like any
// other. Captured, it cost a haiku flush a day and wrote "vault healthy" into the daily note, which
// also blinded brain-doctor's `sessions` check (a note would exist every day). The Desktop app opens
// a scheduled run's first user message with this tag, independent of the prompt's wording.
const ROUTINE_MARKER = '<scheduled-task name="vault-health"';
const isRoutine = (tp) => {
  let fd;
  try {
    fd = openSync(tp, "r");
    const buf = Buffer.alloc(262_144); // hook attachments precede the first user record
    // The FIRST user message only: a session that merely reads the stage file quoting this prompt
    // must still be captured.
    for (const l of buf.toString("utf8", 0, readSync(fd, buf, 0, buf.length, 0)).split("\n")) {
      let r;
      try { r = JSON.parse(l); } catch { continue; }
      if (r?.type !== "user") continue;
      const c = r.message?.content;
      const text = typeof c === "string" ? c : Array.isArray(c) ? c.map((p) => p?.text ?? "").join("") : "";
      return text.trimStart().startsWith(ROUTINE_MARKER);
    }
    return false;
  } catch {
    return false;
  } finally {
    try { if (fd !== undefined) closeSync(fd); } catch {}
  }
};

// process.execPath is bun.exe; --bun forces the bun runtime, per 00-Meta/Hard-Rules.
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
  const event = String(input.hook_event_name || "unknown");
  const sid = String(input.session_id || "").replace(/[^a-z0-9-]/gi, "");
  const isStop = event === "Stop" || event === "SubagentStop";

  // Throttled Stops exit before logging: logging them would add a line per turn and say nothing.
  if (isStop && Date.now() - (readWatermarks()[sid]?.triedAt ?? 0) < STOP_EVERY_MS) process.exit(0);

  const tp = resolveTranscript(sid, input.transcript_path);

  // Logged under its own tag, so brain-doctor's `sessions` check does not count it as a session.
  if (tp && isRoutine(tp)) {
    if (!dry) logEvent({ hook: "capture-skipped", event, sid, reason: "vault-health routine" });
    else process.stdout.write(`${JSON.stringify({ event, sid, skipped: "vault-health routine" })}\n`);
    process.exit(0);
  }

  if (dry) {
    process.stdout.write(
      `${JSON.stringify({ event, sid, transcript: tp, compileAndUsage: !isStop, flush: !!(tp && sid) })}\n`,
    );
    process.exit(0);
  }

  logEvent({ hook: "capture", event, sid, transcript: tp, givenPathUsed: !!tp && tp === input.transcript_path });

  if (!isStop) {
    // Promote a FINISHED daily log into 60-Decisions / 20-Knowledge / Hard-Rules. Detached: its
    // `claude -p` runs for minutes. Runs even without a transcript - it does not need one.
    detach("brain_compile", join(HOOKS, "brain-compile.mjs"));

    // Token/cost digest, at most once per logical day; the digest file's own mtime is the gate.
    const day = (t) => logicalDate(new Date(t)).toDateString();
    const d = logicalDate(new Date());
    const month = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
    let stale = true;
    try {
      stale = day(statSync(join(VAULT, "50-Ops", "Usage", `usage-${month}.md`)).mtimeMs) !== day(Date.now());
    } catch {
      /* no digest yet - stale stays true */
    }
    if (stale) {
      spawn("python", [join(VAULT, ".brain", "usage.py"), "--month", month], {
        detached: true,
        stdio: "ignore",
        windowsHide: true,
      }).unref();
    }
  }

  if (!tp || !sid) process.exit(0);
  writeWatermark(sid, { triedAt: Date.now() });
  detach("brain_flush", join(HOOKS, "brain-flush.mjs"), sid, String(input.cwd || ""), "--transcript", tp);
} catch {
  /* a logging hook must never break a session */
}
process.exit(0);

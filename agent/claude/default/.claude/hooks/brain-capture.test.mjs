// brain-capture.test.mjs - run: bun --bun brain-capture.test.mjs
//
// Regression test for the 2026-09-10 flush outage: SessionEnd delivered a payload
// with no usable `transcript_path`, capture exited before flushing, and the
// daily notes stopped for four days while capture itself kept running.
//
// Runs capture with --dry-run ONLY. The first version ran it for real: each check detached a
// real compile and flush, and on 2026-09-22 three flushes of one session raced and wrote the
// same entries into the daily note three times.

import { readdirSync, statSync, writeFileSync, rmSync } from "node:fs";
import { join } from "node:path";
import { tmpdir, homedir } from "node:os";
import { spawnSync } from "node:child_process";

const HOOKS = join(homedir(), ".claude", "hooks");
const PROJECTS = join(homedir(), ".claude", "projects");

/** Any real transcript on disk, newest first - the test needs a session id that exists. */
function anyTranscript() {
  const found = [];
  for (const d of readdirSync(PROJECTS, { withFileTypes: true })) {
    if (!d.isDirectory()) continue;
    for (const f of readdirSync(join(PROJECTS, d.name))) {
      if (f.endsWith(".jsonl")) {
        const p = join(PROJECTS, d.name, f);
        found.push({ sid: f.slice(0, -6), path: p, mtime: statSync(p).mtimeMs });
      }
    }
  }
  found.sort((a, b) => b.mtime - a.mtime);
  return found[0];
}

/** Capture's dry-run verdict for a payload: what it would log and detach, as parsed JSON. */
function run(payload) {
  const env = { ...process.env };
  delete env.CLAUDE_INVOKED_BY; // guard() would exit before anything is decided
  const r = spawnSync(process.execPath, ["--bun", join(HOOKS, "brain-capture.mjs"), "--dry-run"], {
    input: JSON.stringify(payload),
    encoding: "utf8",
    windowsHide: true,
    env,
  });
  try {
    return JSON.parse(r.stdout.trim().split("\n").at(-1));
  } catch {
    return {};
  }
}

const t = anyTranscript();
if (!t) {
  console.log("SKIP - no transcript on disk to test against");
  process.exit(0);
}

let failed = 0;
const check = (name, got, want) => {
  const ok = got === want;
  if (!ok) failed++;
  console.log(`${ok ? "PASS" : "FAIL"}  ${name}${ok ? "" : `  (got ${got}, want ${want})`}`);
};
const end = { cwd: "C:\\dev\\TheAtlas", hook_event_name: "SessionEnd" };

// The bug: this payload is what SessionEnd actually delivered, and capture gave up.
check("payload with NO transcript_path still resolves it from session_id", run({ ...end, session_id: t.sid }).transcript, t.path);

// The path that always worked - must keep working.
check("payload WITH a valid transcript_path still works", run({ ...end, session_id: t.sid, transcript_path: t.path }).flush, true);

// A stale path must fall back rather than abort, which is the compaction case
// the original comment (Claude Code #13668) named.
check(
  "payload with a STALE transcript_path falls back instead of giving up",
  run({ ...end, session_id: t.sid, transcript_path: join(tmpdir(), "definitely-not-here.jsonl") }).transcript,
  t.path,
);

// An unknown session has no transcript anywhere - capture must not flush.
check(
  "unknown session id does not flush",
  run({ ...end, session_id: "00000000-0000-0000-0000-000000000000", cwd: "C:\\dev" }).flush,
  false,
);

// The vault-health Routine's session is skipped, not flushed into the daily note (Stage 06).
const fake = join(tmpdir(), "brain-capture-test-routine.jsonl");
const line = (text) => JSON.stringify({ type: "user", message: { role: "user", content: text } });
writeFileSync(fake, `${line('<scheduled-task name="vault-health" file="x">run the sweep</scheduled-task>')}\n`);
check(
  "vault-health Routine session is skipped",
  run({ ...end, session_id: "11111111-1111-1111-1111-111111111111", transcript_path: fake }).skipped,
  "vault-health routine",
);

// Only the FIRST user message counts: a session that later quotes the marker is still captured.
writeFileSync(fake, `${line("read the stage file")}\n${line('<scheduled-task name="vault-health"> quoted')}\n`);
check(
  "a session quoting the marker later is still captured",
  run({ ...end, session_id: "11111111-1111-1111-1111-111111111111", transcript_path: fake }).flush,
  true,
);
rmSync(fake, { force: true });

console.log(failed ? `\n${failed} failing` : "\nall passing");
process.exit(failed ? 1 : 0);

// brain-capture.test.mjs - run: bun --bun brain-capture.test.mjs
//
// Regression test for the 2026-09-10 flush outage: SessionEnd delivered a payload
// with no usable `transcript_path`, capture exited before copyFileSync, and the
// daily notes stopped for four days while capture itself kept running.
//
// Asserts capture still finds the transcript when the payload omits it.

import { existsSync, readdirSync, rmSync, statSync } from "node:fs";
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

function run(payload) {
  const sid = payload.session_id;
  const temp = join(tmpdir(), `brain-flush-${sid}.jsonl`);
  try {
    rmSync(temp, { force: true });
  } catch {}
  spawnSync(process.execPath, ["--bun", join(HOOKS, "brain-capture.mjs")], {
    input: JSON.stringify(payload),
    encoding: "utf8",
    windowsHide: true,
  });
  // capture detaches flush, which consumes the temp - check immediately.
  const made = existsSync(temp);
  try {
    rmSync(temp, { force: true });
  } catch {}
  return made;
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

// The bug: this payload is what SessionEnd actually delivered, and capture gave up.
check(
  "payload with NO transcript_path still resolves it from session_id",
  run({ session_id: t.sid, cwd: "C:\\dev\\TheAtlas", hook_event_name: "SessionEnd" }),
  true,
);

// The path that always worked - must keep working.
check(
  "payload WITH a valid transcript_path still works",
  run({
    session_id: t.sid,
    transcript_path: t.path,
    cwd: "C:\\dev\\TheAtlas",
    hook_event_name: "SessionEnd",
  }),
  true,
);

// A stale path must fall back rather than abort, which is the compaction case
// the original comment (Claude Code #13668) named.
check(
  "payload with a STALE transcript_path falls back instead of giving up",
  run({
    session_id: t.sid,
    transcript_path: join(tmpdir(), "definitely-not-here.jsonl"),
    cwd: "C:\\dev\\TheAtlas",
    hook_event_name: "SessionEnd",
  }),
  true,
);

// An unknown session has no transcript anywhere - capture must exit quietly.
check(
  "unknown session id produces nothing (no crash, no temp)",
  run({ session_id: "00000000-0000-0000-0000-000000000000", cwd: "C:\\dev", hook_event_name: "SessionEnd" }),
  false,
);

console.log(failed ? `\n${failed} failing` : "\nall passing");
process.exit(failed ? 1 : 0);

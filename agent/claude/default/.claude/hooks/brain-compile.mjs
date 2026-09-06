// brain-compile.mjs - promotes a FINISHED daily log into the curated tiers, then commits.
// Runtime is bun (`bun --bun`), per 00-Brain/Hard-Rules.
// Spec: C:\obsidian\root\40-Plans\2026-08-22-brain-memory-compiler.md
//
// Gate is "the log is finished", not a wall clock. The old `hour >= 18` gate could never fire
// for a 03:00-07:00 worker, and nothing scheduled it anyway - so this tier never ran once.
// A log for a past logical day never changes again, so it compiles exactly once, and the hash
// in STATE is what proves it. `--force` targets today's still-open log.
import { readFileSync, writeFileSync, existsSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import { notePath, VAULT } from "./brain-lib.mjs";

const STATE = join(VAULT, "50-Ops", "brain-compile-state.json");
const SESSIONS = join(VAULT, "30-Sessions");
const force = process.argv.includes("--force");
const dry = process.argv.includes("--dry-run");

// A compile that died mid-run leaves its claim behind; expire it. Longer than the 900s sonnet
// timeout, so a live run is never stolen from.
const CLAIM_STALE_MS = 20 * 60_000;
const claimed = (v) =>
  typeof v === "string" && v.startsWith("running:") && Date.now() - Number(v.slice(8)) < CLAIM_STALE_MS;

const readState = () => {
  try {
    return JSON.parse(readFileSync(STATE, "utf8"));
  } catch {
    return {};
  }
};

const subdirs = (p) => {
  try {
    return readdirSync(p, { withFileTypes: true })
      .filter((e) => e.isDirectory())
      .map((e) => e.name)
      .sort();
  } catch {
    return [];
  }
};

/** Every daily log, chronological (path sorts as YYYY/MM/YYYY-MM-DD). */
function logs() {
  const out = [];
  for (const y of subdirs(SESSIONS))
    for (const m of subdirs(join(SESSIONS, y)))
      for (const f of readdirSync(join(SESSIONS, y, m)).sort())
        if (/^\d{4}-\d{2}-\d{2}\.md$/.test(f)) out.push(join(SESSIONS, y, m, f));
  return out;
}

const hashOf = (f) => createHash("sha256").update(readFileSync(f, "utf8")).digest("hex");

try {
  const now = new Date();
  const today = notePath(now);
  const state = readState();

  // One log per invocation, oldest first - a backlog drains over successive sessions instead
  // of firing N sonnet calls at once.
  const log = force
    ? existsSync(today) && today
    : logs().find((f) => f !== today && !claimed(state[f]) && state[f] !== hashOf(f));
  if (!log) process.exit(0);

  // Claim the log BEFORE the sonnet run, not after. Several SessionEnds can fire at once - every
  // spawned `claude -p` ends in one - and on 2026-09-06 three compiles raced on a single log.
  // All three read the state file before any wrote it, all three saw the log uncompiled, and each
  // wrote its own copy of the same decisions at the same "next free" numbers: 0012 ended up with
  // three files, 0013 with three, 0014-0017 with two each. Re-read immediately before claiming so
  // the check-to-claim window is as small as a file write.
  {
    const fresh = readState();
    if (claimed(fresh[log])) process.exit(0);
    fresh[log] = `running:${Date.now()}`;
    writeFileSync(STATE, JSON.stringify(fresh, null, 1));
  }

  const body = readFileSync(log, "utf8");

  const prompt = [
    `Compile a session log into the vault at ${VAULT}.`,
    "",
    "MANDATORY FIRST STEP, before writing anything: read 00-Brain/00-MOC-Root.md and",
    "00-Brain/Conventions.md, then LIST the full contents of 60-Decisions/<Repo-Name>/ and every",
    "20-Knowledge/<Area>/ you might write to. You must know every existing filename and the",
    "highest ADR number already on disk before you create a single file. Do not skip this.",
    "",
    "Then route each item:",
    "- decisions   -> 60-Decisions/<Repo-Name>/<NNNN>-<slug>.md",
    "- gotchas     -> 20-Knowledge/<Area>/<slug>.md",
    "- patterns    -> 20-Knowledge/Connections/<slug>.md",
    "- preferences -> append to 00-Brain/Hard-Rules.md or 00-Brain/Identity.md",
    "",
    "A decision the user reversed, and a mistake either of you fixed, are BOTH decisions -",
    "record what was chosen, what was rejected, and why. Do not drop the reversal.",
    "",
    "Rules:",
    "- ADRs are CENTRAL. Never write into a checkout's own Decisions/ folder - the checkouts live",
    "  outside the vault at C:\\dev\\<remote-name>\\, so anything written there is invisible to the",
    "  vault's history, its search index and its graph. Write to 60-Decisions/<Repo-Name>/.",
    "- ONE decision per ADR file. Never bundle several decisions into one omnibus note - if the",
    "  log holds four decisions, that is four files, not one titled 'X, Y and Z'.",
    "- If a decision or gotcha in this log ALREADY has a file, EDIT THAT FILE. Do not write a",
    "  second file for it under a different slug. Two notes describing one decision is the worst",
    "  outcome available here - worse than no note, because both then rot separately. This log may",
    "  have been compiled before: assume it was, and check before you create.",
    "- ADR numbers: (highest number present in that repo folder) + 1, incrementing from there.",
    "  Never reuse a number already on disk, even when the file holding it looks unrelated to you.",
    "- Every note gets frontmatter per Conventions.md. Filenames kebab-case, H1 is `NNNN — Title`.",
    "- Link back to the source log with a [[wikilink]], never a path link.",
    "- Add EVERY new decision to the table in 60-Decisions/00-MOC-Decisions.md. A note missing from",
    "  its MOC is unreachable at retrieval tier 1 and will be rewritten by a later run.",
    "- Touch nothing outside the four target areas.",
    dry ? "- DRY RUN: describe what you would write. Write NOTHING." : "",
    "",
    `## The log (${log})`,
    body,
  ].join("\n");

  // Snapshot the tracked scope BEFORE the run so the commit below can contain only what this
  // compiler actually touched. `git add <dir>` swept in whatever the user happened to have dirty
  // in those five directories - on 2026-09-06 it laundered hand-written ADRs into a
  // `chore(brain): compile` commit authored by brain-compiler, mid-edit.
  const SCOPE = ["00-Brain", "20-Knowledge", "60-Decisions", "30-Sessions", "50-Ops"];
  const snapshot = () => {
    try {
      return new Map(
        execFileSync("git", ["status", "--porcelain", "--", ...SCOPE], {
          cwd: VAULT,
          encoding: "utf8",
          windowsHide: true,
        })
          .split("\n")
          .filter(Boolean)
          // `R  old -> new` reports both sides; the new path is the one to stage.
          .map((l) => [l.slice(3).split(" -> ").pop().replace(/^"|"$/g, ""), l.slice(0, 2)]),
      );
    } catch {
      return new Map();
    }
  };
  const before = snapshot();

  execFileSync(
    "claude",
    [
      "-p",
      "--model", "sonnet",
      // A spawned `claude -p` inherits settings.json's permission mode - explicit in both
      // directions, so the compiler can never silently degrade to emitting plans.
      "--permission-mode", dry ? "plan" : "acceptEdits",
      "--allowedTools", dry ? "Read,Glob,Grep" : "Read,Glob,Grep,Write,Edit",
    ],
    {
      input: prompt,
      encoding: "utf8",
      cwd: VAULT,
      timeout: 900_000,
      stdio: ["pipe", "inherit", "inherit"],
      windowsHide: true,
      env: { ...process.env, CLAUDE_INVOKED_BY: "brain_compile" },
    },
  );

  if (dry) process.exit(0);

  // Commit only what the compiler wrote, as its own author, so `git log` is a review queue.
  const git = (...a) => execFileSync("git", a, { cwd: VAULT, encoding: "utf8", windowsHide: true });
  // 50-Ops carries the auto-written Commits/ and Usage/ digests; its state file is gitignored.
  // Stage the delta against the pre-run snapshot, never whole directories. A path the user
  // already had dirty keeps its status and is skipped - including one the compiler then also
  // edited, which is the intended bias: never fold someone else's work into this commit.
  const mine = [...snapshot()].filter(([p, s]) => before.get(p) !== s).map(([p]) => p);
  if (mine.length) git("add", "--", ...mine);
  if (mine.length && git("diff", "--cached", "--name-only").trim()) {
    git(
      "-c", "user.name=brain-compiler",
      "-c", "user.email=noreply@local",
      "commit", "-m", `chore(brain): compile ${log.slice(-13, -3)}`,
    );
  }

  // Re-hash AFTER the run: the compiler sometimes edits the log it just read, and storing the
  // pre-run hash would make that log look uncompiled forever.
  // Re-read: our own claim, and possibly another log's, landed after `state` was captured.
  const fresh = readState();
  fresh[log] = hashOf(log);
  writeFileSync(STATE, JSON.stringify(fresh, null, 1));
} catch {
  /* background - never surface */
}
process.exit(0);

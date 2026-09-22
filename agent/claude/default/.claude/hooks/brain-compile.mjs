// brain-compile.mjs - promotes a FINISHED daily log into the curated tiers, then commits.
// Runtime is bun (`bun --bun`), per 00-Meta/Hard-Rules.
// Spec: C:\obsidian\root\40-Plans\2026-08-22-brain-memory-compiler\2026-08-22-brain-memory-compiler.md
//
// Gate is "the log is finished", not a wall clock. The old `hour >= 18` gate could never fire
// for a 03:00-07:00 worker, and nothing scheduled it anyway - so this tier never ran once.
// A log for a past logical day never changes again, so it compiles exactly once, and the hash
// in STATE is what proves it. `--force` targets today's still-open log.
import { readFileSync, writeFileSync, existsSync, readdirSync } from "node:fs";
import { join, basename } from "node:path";
import { createHash } from "node:crypto";
import { execFileSync, spawn } from "node:child_process";
import { notePath, VAULT, DEV_ROOT, HOOKS, STATE_DIR, recordFailure, clearFailure, linksOf } from "./brain-lib.mjs";

const STATE = join(VAULT, "50-Ops", "brain-compile-state.json");
const SESSIONS = join(VAULT, "30-Sessions");
const force = process.argv.includes("--force");
const dry = process.argv.includes("--dry-run");
// Kill switch for structural work on the vault: a compile firing mid-restructure would stage a
// half-moved tree under its own author. While this file exists, compile does nothing.
if (existsSync(join(STATE_DIR, "compile.disabled"))) process.exit(0);

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

/**
 * Link every note this run created that its MOC does not link yet, under an "Unsorted" heading.
 * The prompt asks the model to file its notes, and some runs don't: the 09-17 compile wrote five
 * knowledge notes and linked none, so they sat outside `reach` until a human noticed. A MOC is one
 * hop from 00-MOC-Root, so a link there keeps the note within the 2 hops `reach` requires.
 * Returns the basenames it linked.
 */
function fileUnlinked(created, day) {
  const MOCS = { "60-Decisions/": "60-Decisions/00-MOC-Decisions.md", "20-Knowledge/": "20-Knowledge/00-MOC-Knowledge.md" };
  const HEAD = "## Unsorted (brain-compile)";
  const filed = [];
  for (const [prefix, moc] of Object.entries(MOCS)) {
    const file = join(VAULT, moc);
    let text;
    try {
      text = readFileSync(file, "utf8");
    } catch {
      continue;
    }
    const linked = new Set(linksOf(text).map((t) => t.toLowerCase()));
    const add = created
      .filter((p) => p.startsWith(prefix) && p.endsWith(".md") && !basename(p).startsWith("00-MOC-"))
      .map((p) => basename(p, ".md"))
      .filter((n) => !linked.has(n.toLowerCase()));
    if (!add.length) continue;
    const lines = add.map((n) => `- [[${n}]] — from [[${day}]], filed by brain-compile; move it to its section`);
    text = text.includes(`${HEAD}\n\n`)
      ? text.replace(`${HEAD}\n\n`, () => `${HEAD}\n\n${lines.join("\n")}\n`)
      : `${text.replace(/\s*$/, "")}\n\n${HEAD}\n\n${lines.join("\n")}\n`;
    writeFileSync(file, text, "utf8");
    filed.push(...add);
  }
  return filed;
}

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
    "MANDATORY FIRST STEP, before writing anything: read 00-Meta/00-MOC-Root.md and",
    "00-Meta/Conventions.md, then LIST the full contents of the 60-Decisions/ folder you will write to and every",
    "20-Knowledge/<Area>/ you might write to. You must know every existing filename and the",
    "highest ADR number already on disk before you create a single file. Do not skip this.",
    "",
    "Then route each item:",
    "- decisions   -> 60-Decisions/Repos/<Repo-Name>/<NNNN>-<slug>.md about one repo; 60-Decisions/Identity/<NNNN>-<slug>.md about the vault, its hooks, or how the agent must behave. <Repo-Name> is the GitHub remote's exact casing.",
    "- gotchas     -> 20-Knowledge/<Area>/<slug>.md",
    "- patterns    -> 20-Knowledge/Connections/<slug>.md",
    "- preferences -> append to 00-Meta/Hard-Rules.md or 00-Meta/Identity.md",
    "",
    "A decision the user reversed, and a mistake either of you fixed, are BOTH decisions -",
    "record what was chosen, what was rejected, and why. Do not drop the reversal.",
    "",
    "Rules:",
    "- ADRs are CENTRAL. Never write into a checkout's own Decisions/ folder - the checkouts live",
    `  outside the vault at ${join(DEV_ROOT, "<remote-name>")}, so anything written there is invisible to the`,
    "  vault's history, its search index and its graph. Write to 60-Decisions/Repos/<Repo-Name>/ or 60-Decisions/Identity/.",
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
    "- Add EVERY new decision to the table in 60-Decisions/00-MOC-Decisions.md, and EVERY new",
    "  20-Knowledge note to 20-Knowledge/00-MOC-Knowledge.md under its area's section, as",
    "  `- [[<slug>]] — <one line>`. A note missing from its MOC is unreachable at retrieval tier 1",
    "  and will be rewritten by a later run.",
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
  const SCOPE = ["00-Meta", "20-Knowledge", "60-Decisions", "30-Sessions", "50-Ops"];
  const snapshot = () => {
    try {
      return new Map(
        // -uall: a new folder is listed file by file, so fileUnlinked() sees each new note.
        execFileSync("git", ["status", "--porcelain", "--untracked-files=all", "--", ...SCOPE], {
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

  try {
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
      // stderr piped, not inherited: a detached parent has nowhere to inherit it to, and the
      // failure reason is what recordFailure needs.
      stdio: ["pipe", "inherit", "pipe"],
      windowsHide: true,
      env: { ...process.env, CLAUDE_INVOKED_BY: "brain_compile" },
    },
  );
    if (!dry) clearFailure("compile");
  } catch (e) {
    if (!dry) recordFailure("compile", e);
    throw e;
  }

  if (dry) process.exit(0);

  // Commit only what the compiler wrote, as its own author, so `git log` is a review queue.
  const git = (...a) => execFileSync("git", a, { cwd: VAULT, encoding: "utf8", windowsHide: true });
  // 50-Ops carries the auto-written Commits/ and Usage/ digests; its state file is gitignored.
  // Stage the delta against the pre-run snapshot, never whole directories. A path the user
  // already had dirty keeps its status and is skipped - including one the compiler then also
  // edited, which is the intended bias: never fold someone else's work into this commit.
  const day = log.slice(-13, -3);
  const created = [...snapshot()].filter(([p, s]) => s === "??" && !before.has(p)).map(([p]) => p);
  const filed = fileUnlinked(created, day);
  const mine = [...snapshot()].filter(([p, s]) => before.get(p) !== s).map(([p]) => p);
  if (mine.length) git("add", "--", ...mine);
  const staged = mine.length ? git("diff", "--cached", "--name-only").trim() : "";
  if (staged) {
    // The commit note copies the body as the commit's "why" (spec D5 option A). Without one, 14 of
    // 17 subject-only commits in 2026-09 were this compiler's.
    const body = [
      `Promoted the finished session log [[${day}]] into the vault: the decisions, gotchas and`,
      "preferences it recorded, routed by brain-compile (sonnet).",
      "",
      "Files:",
      ...staged.split("\n").map((f) => `- ${f}`),
      ...(filed.length ? ["", `Linked by the fallback, not by the model (sort them): ${filed.join(", ")}`] : []),
    ].join("\n");
    git(
      "-c", "user.name=brain-compiler",
      "-c", "user.email=noreply@local",
      "commit", "-m", `chore(brain): compile ${day}`, "-m", body,
    );
  }

  // F2: this compiler is the vault's largest writer, and it writes through a guard()ed
  // `claude -p` whose PostToolUse hooks exit immediately - so brain-reindex never saw a single
  // one of its writes, and everything it produced was unsearchable until some unrelated edit
  // happened to trigger a reindex. Schedule it here, and only when something was actually written.
  // brain-reindex does not call guard(), so inheriting CLAUDE_INVOKED_BY is harmless.
  if (mine.length) {
    spawn(process.execPath, ["--bun", join(HOOKS, "brain-reindex.mjs"), "--vault"], {
      detached: true,
      stdio: "ignore",
      windowsHide: true,
    }).unref();
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

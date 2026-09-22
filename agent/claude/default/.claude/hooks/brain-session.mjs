// brain-session.mjs - SessionStart. Injects the always-true core of the brain.
//
// Why this exists: brain-inject.mjs does per-prompt FTS5 lookup, but keyword search
// structurally cannot answer identity questions - "Who am I" shares no term with
// Identity.md, so it returns nothing. This carries the small always-relevant tier
// regardless of cwd, so sessions started OUTSIDE the vault (where the vault's own
// CLAUDE.md never loads) still know who the user is and where things live.
//
// Runtime is bun (`bun --bun`), per 00-Meta/Hard-Rules.
import { readFileSync, existsSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import { release } from "node:os";
import { VAULT, DEV_ROOT, sessionDbs, failures, HOOK_EVENTS } from "./brain-lib.mjs";

/**
 * Which OS this session runs on, detected now rather than written into a file. The machine
 * dual-boots, and the same dotfiles (merged from `main`) are checked out on both sides — a
 * hand-written "you are on Windows" would be right on one boot and wrong on the other.
 */
function machine() {
  let current;
  if (process.platform === "win32") {
    current = `Windows (NT ${release()})`;
  } else if (process.platform === "linux") {
    let distro = "Linux";
    try {
      distro = readFileSync("/etc/os-release", "utf8").match(/^PRETTY_NAME="?([^"\n]+)/m)?.[1] ?? distro;
    } catch {}
    const desktop = [process.env.XDG_CURRENT_DESKTOP, process.env.XDG_SESSION_TYPE].filter(Boolean).join(", ");
    current = desktop ? `${distro} (${desktop})` : distro;
  } else {
    current = process.platform;
  }
  return [
    "## Machine",
    "",
    "This machine DUAL-BOOTS Windows 10 Pro and Arch Linux (Hyprland + Caelestia shell), on the",
    `same hardware. **Current OS: ${current}.** Paths, shells and tools differ per OS: vault`,
    `${VAULT}, checkouts ${DEV_ROOT}. Hardware and per-OS details: Identity.md § Machine.`,
    "Dotfiles: AtlasAta-DotFiles, branch `windows` or `arch-caelestia`; shared material on `main`.",
  ].join("\n");
}

const CAP = 7000; // chars; ~1,900 tokens, paid once per session
const STALE_DAYS = 3; // slack for a weekend off, tight enough to catch a real break early

/**
 * The flush canary. Sessions are being captured (a session DB was written) but no daily note has
 * appeared for days => the flush pipeline is dropping everything on the floor.
 *
 * This is the only monitoring the memory loop has. Hooks fail silent by design
 * ([[0002-hooks-fail-silent-always-query]]), so a broken flush reports nothing - it ran for ten
 * days in 2026-08/09 writing FLUSH_OK every time and nothing anywhere said so. The statusline
 * that would have carried this was removed ([[0008-statusline-removed]]), and SessionStart is
 * the one surface left that the user reads every single session.
 *
 * Deliberately mtime-only: no sqlite open, no query, just a stat per DB file. "Days since the
 * last note" alone cannot tell a broken pipeline from a few days off - the comparison against
 * capture activity is what makes the signal mean something.
 */
/** The last flush outcome from the hook event log - names the layer, not just the symptom. */
function lastFlush() {
  try {
    const lines = readFileSync(HOOK_EVENTS, "utf8").trimEnd().split("\n");
    for (let i = lines.length - 1; i >= Math.max(0, lines.length - 500); i--) {
      const e = JSON.parse(lines[i]);
      if (e.hook === "flush") return `last flush: ${e.outcome} at ${String(e.ts).slice(0, 16)}Z`;
    }
  } catch {}
  return "no flush in 50-Ops/hook-events.jsonl yet";
}

function flushCanary() {
  const days = (ms) => Math.floor((Date.now() - ms) / 86_400_000);

  let newestNote = 0;
  const dir = join(VAULT, "30-Sessions");
  const walk = (p) => {
    for (const e of readdirSync(p, { withFileTypes: true })) {
      if (e.isDirectory()) walk(join(p, e.name));
      else if (/^\d{4}-\d{2}-\d{2}\.md$/.test(e.name)) {
        const t = Date.parse(`${e.name.slice(0, 10)}T12:00:00`);
        if (t > newestNote) newestNote = t;
      }
    }
  };
  walk(dir);

  let newestCapture = 0;
  for (const f of sessionDbs()) {
    const t = statSync(f).mtimeMs;
    if (t > newestCapture) newestCapture = t;
  }
  if (!newestCapture) return null;

  const quiet = days(newestNote);
  if (quiet < STALE_DAYS || newestCapture <= newestNote) return null;

  return (
    `!! FLUSH CANARY: sessions captured ${days(newestCapture)}d ago, but the newest note in ` +
    `30-Sessions/ is ${quiet}d old. The memory loop is capturing and not writing (${lastFlush()}). ` +
    `Diagnose with: bun --bun ~/.claude/hooks/brain-flush.mjs <session-id> "<cwd>" --dry-run, ` +
    `and read the tail of ${HOOK_EVENTS}.`
  );
}

/**
 * The daily sweep's verdict, surfaced only when something is wrong. Silence means healthy - a
 * green line printed every session is wallpaper within a week. Also catches the Routine itself
 * stopping: it is a claude session and dies with auth, and this hook does not depend on it (V7).
 */
function healthAlarm() {
  const dir = join(VAULT, "50-Ops", "Health");
  let files = [];
  try {
    files = readdirSync(dir).filter((f) => /^health-\d{4}-\d{2}\.md$/.test(f)).sort();
  } catch {}
  if (!files.length) return null; // before the Routine's first run: nothing to say yet
  const lines = readFileSync(join(dir, files.at(-1)), "utf8").split("\n").filter((l) => /^- \d{4}-\d{2}-\d{2} /.test(l));
  const last = lines.at(-1);
  if (!last) return null;
  const day = last.slice(2, 12);
  const ageDays = Math.floor((Date.now() - Date.parse(`${day}T12:00:00`)) / 86_400_000);
  if (ageDays >= 2)
    return `!! VAULT HEALTH: the daily sweep has not recorded since ${day} (${ageDays}d). Is the Claude Desktop app running its vault-health Routine? Run it by hand: bun --bun ~/.claude/hooks/brain-doctor.mjs --repair --record --pretty`;
  if (last.includes("**FAIL**"))
    return `!! VAULT HEALTH FAIL (${day}): ${last.split("·")[1]?.trim()}. Details: bun --bun ~/.claude/hooks/brain-doctor.mjs --pretty — and any explanation the Routine wrote under that line in 50-Ops/Health/${files.at(-1)}.`;
  return null;
}

const CORE = [
  ["Identity", join(VAULT, "00-Meta", "Identity.md")],
  ["Where things live", join(VAULT, "00-Meta", "00-MOC-Root.md")],
];

// Strip YAML frontmatter - it is metadata, not context worth spending tokens on.
const body = (t) => t.replace(/^---\n[\s\S]*?\n---\n/, "").trim();

try {
  // The OS line matters even when the vault is missing — more so, since that is how a fresh
  // boot into the other OS usually looks.
  if (!existsSync(VAULT)) {
    process.stdout.write(
      JSON.stringify({
        hookSpecificOutput: {
          hookEventName: "SessionStart",
          additionalContext: `${machine()}\n\nThe vault is not at ${VAULT} on this OS.`,
        },
      }),
    );
    process.exit(0);
  }

  const parts = [];
  let used = 0;
  for (const [label, file] of CORE) {
    if (!existsSync(file)) continue;
    const t = body(readFileSync(file, "utf8"));
    if (used + t.length > CAP) continue;
    parts.push(`## ${label}\n\n${t}`);
    used += t.length;
  }
  if (!parts.length) process.exit(0);

  // Never let the canary break the injection it rides on.
  let canary = null;
  try {
    canary = flushCanary();
  } catch {}
  let health = null;
  try {
    health = healthAlarm();
  } catch {}

  // The cause, when a hook recorded one — no waiting STALE_DAYS for the symptom.
  const failing = Object.entries(failures()).map(
    ([tag, f]) =>
      `!! BRAIN ${tag.toUpperCase()} FAILING since ${new Date(f.at).toISOString().slice(0, 16)}Z: ${f.reason}. ` +
      "Tell the user in the first reply; a `claude -p` auth failure needs them to run `claude` and /login.",
  );

  const ctx = [
    ...failing.flatMap((l) => [l, ""]),
    ...(canary ? [canary, ""] : []),
    ...(health ? [health, ""] : []),
    machine(),
    "",
    `The user's second brain is at ${VAULT}. This is its always-true core, injected at`,
    "session start. It is authoritative about who the user is and where things live.",
    "",
    "Retrieval order for anything else - do not skip tiers:",
    "  0. Note names injected on each prompt by brain-inject - vault notes only. Follow one into the file.",
    "  1. 00-MOC-Root -> the 00-MOC-* it points to -> the note",
    "  2. ctx_search - see the warning below",
    '  3. graphify query "<q>" --budget 1500 - how things connect',
    "  4. Read one named file",
    "",
    "ctx_search reaches the vault ONLY in a session launched in the vault. Its `project` parameter",
    "does not redirect it (measured 2026-09-21, context-mode v1.0.169): from anywhere else it returns",
    "this session's own events, never vault notes - even though the index is complete. Outside the",
    "vault, tier 0 then tier 4 is the working path. Details: 00-Meta/Hard-Rules.md § Tooling.",
    "Check retrieval any time, zero tokens: bun --bun ~/.claude/hooks/brain-doctor.mjs --pretty",
    "",
    `The vault is notes only - the checkouts moved to ${join(DEV_ROOT, "<remote-name>")} on 2026-09-06.`,
    `Do NOT sweep ${DEV_ROOT} blind: that is where node_modules and target/ live. Repo docs are indexed`,
    "per repo (searchable via ctx_search in a session launched in that repo) and reachable through",
    "the merged graph, so a blind sweep is the wrong tool there too.",
    "Full behavioural rules: 00-Meta/Hard-Rules.md.",
    "",
    parts.join("\n\n---\n\n"),
  ].join("\n");

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: { hookEventName: "SessionStart", additionalContext: ctx },
    }),
  );
} catch {
  /* a context hook must never break a session */
}
process.exit(0);

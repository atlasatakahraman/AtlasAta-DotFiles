// brain-session.mjs - SessionStart. Injects the always-true core of the brain.
//
// Why this exists: brain-inject.mjs does per-prompt FTS5 lookup, but keyword search
// structurally cannot answer identity questions - "Who am I" shares no term with
// Identity.md, so it returns nothing. This carries the small always-relevant tier
// regardless of cwd, so sessions started OUTSIDE the vault (where the vault's own
// CLAUDE.md never loads) still know who the user is and where things live.
//
// Runtime is bun (`bun --bun`), per 00-Brain/Hard-Rules.
import { readFileSync, existsSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import { VAULT, sessionDbs } from "./brain-lib.mjs";

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
    `30-Sessions/ is ${quiet}d old. The memory loop is capturing and not writing. ` +
    `Diagnose with: bun --bun ~/.claude/hooks/brain-flush.mjs <transcript> <session-id> "${VAULT}" --dry-run`
  );
}

const CORE = [
  ["Identity", join(VAULT, "00-Brain", "Identity.md")],
  ["Where things live", join(VAULT, "00-Brain", "00-MOC-Root.md")],
];

// Strip YAML frontmatter - it is metadata, not context worth spending tokens on.
const body = (t) => t.replace(/^---\n[\s\S]*?\n---\n/, "").trim();

try {
  if (!existsSync(VAULT)) process.exit(0);

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

  const ctx = [
    ...(canary ? [canary, ""] : []),
    `The user's second brain is at ${VAULT}. This is its always-true core, injected at`,
    "session start. It is authoritative about who the user is and where things live.",
    "",
    "Retrieval order for anything else - do not skip tiers:",
    "  00-MOC-Root -> ctx_search -> graphify query -> raw Read (last resort)",
    "",
    'ctx_search is PROJECT-SCOPED. Querying the brain REQUIRES project: "global" (or',
    `project: "${VAULT}"). Without it you get "Knowledge base is empty" in any session`,
    "started outside the vault - the content is there, you just scoped past it.",
    "",
    "Never `find` or `grep` the vault blind: 10-Repos/ holds real checkouts with node_modules.",
    "Full behavioural rules: 00-Brain/Hard-Rules.md.",
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

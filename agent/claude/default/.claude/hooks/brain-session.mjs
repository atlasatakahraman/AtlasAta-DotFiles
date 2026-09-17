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
import { VAULT, DEV_ROOT, sessionDbs } from "./brain-lib.mjs";

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

  const ctx = [
    ...(canary ? [canary, ""] : []),
    machine(),
    "",
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
    `The vault is notes only (~160 markdown files) - the checkouts moved to ${join(DEV_ROOT, "<remote-name>")}`,
    `on 2026-09-06, so searching the vault is now cheap. Do NOT sweep ${DEV_ROOT} blind: that is where`,
    "node_modules and target/ live. Repo code is reachable via ctx_search (indexed per repo) and",
    "through the merged graph, so a blind sweep is the wrong tool there too.",
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

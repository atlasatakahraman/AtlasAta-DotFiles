// brain-lib.mjs - shared helpers for the brain memory hooks.
// Runtime is bun (`bun --bun`), per 00-Meta/Hard-Rules.
// Spec: C:\obsidian\root\40-Plans\2026-08-22-brain-memory-compiler.md
import { readFileSync, existsSync, mkdirSync, writeFileSync, readdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { homedir, tmpdir } from "node:os";
import { Database } from "bun:sqlite";

/**
 * Open a context-mode DB read-only.
 * bun ships `bun:sqlite`, NOT `node:sqlite` (verified absent on 1.4.0-canary.1).
 * The option key is `readonly` here, vs node's `readOnly`. `prepare()` is
 * API-compatible with node:sqlite, so call sites need no other change.
 */
export function openDb(file) {
  return new Database(file, { readonly: true });
}

// The two roots differ per OS, so they live in `brain-paths.mjs`: each platform branch of
// AtlasAta-DotFiles (`windows`, `arch-caelestia`) carries its own. `main` has none — it is never
// deployed, only merged from.
export { VAULT, DEV_ROOT } from "./brain-paths.mjs";
export const HOOKS = join(homedir(), ".claude", "hooks");
export const CTX = join(homedir(), ".claude", "context-mode");
export const ROLLOVER_HOUR = 5;

/**
 * Why the last `claude -p` a background hook spawned failed, by hook tag. Hooks fail silent, and
 * the canary only notices days later that notes stopped: on 2026-09-17 flush had been dying on
 * "OAuth session expired" since 09-15 with nothing saying so. SessionStart reads this.
 */
const FAILURES = join(tmpdir(), "brain-claude-failures.json");

export function failures() {
  try {
    return JSON.parse(readFileSync(FAILURES, "utf8"));
  } catch {
    return {};
  }
}

export function recordFailure(tag, e) {
  const reason =
    // `claude -p` prints "Failed to authenticate…" on stdout, not stderr.
    `${e?.stderr ?? ""}\n${e?.stdout ?? ""}`
      .split("\n")
      .map((l) => l.trim())
      .find((l) => l && !l.includes("hook [")) || String(e?.message ?? e).split("\n")[0];
  try {
    writeFileSync(FAILURES, JSON.stringify({ ...failures(), [tag]: { at: Date.now(), reason } }));
  } catch {}
}

export function clearFailure(tag) {
  const all = failures();
  if (!(tag in all)) return;
  delete all[tag];
  try {
    writeFileSync(FAILURES, JSON.stringify(all));
  } catch {}
}

/** Exit immediately if we are running inside a claude -p spawned by our own hooks. */
export function guard() {
  if (process.env.CLAUDE_INVOKED_BY) process.exit(0);
}

export function readStdin() {
  try {
    return JSON.parse(readFileSync(0, "utf8") || "{}");
  } catch {
    return {};
  }
}

export const IS_WINDOWS = process.platform === "win32";

/**
 * A path in comparable form. Windows paths arrive with mixed separators and are
 * case-insensitive, so there they are unified to `\` and lower-cased. Linux paths are
 * case-sensitive and already `/`-separated: only a trailing separator goes.
 */
export function normDir(p) {
  const s = String(p || "");
  if (!IS_WINDOWS) return s.replace(/\/+$/, "");
  return s.replace(/\//g, "\\").replace(/\\+$/, "").toLowerCase();
}

/**
 * The context-mode CLI bundle, newest installed version. It ships as a plugin bundle, not on
 * PATH. Resolved rather than pinned: a pinned version path breaks silently on every update.
 */
export function contextModeCli() {
  const base = join(homedir(), ".claude", "plugins", "cache", "context-mode", "context-mode");
  try {
    const versions = readdirSync(base)
      .filter((v) => existsSync(join(base, v, "cli.bundle.mjs")))
      .sort((a, b) => a.localeCompare(b, undefined, { numeric: true }));
    return versions.length ? join(base, versions.at(-1), "cli.bundle.mjs") : null;
  } catch {
    return null;
  }
}

/** The logical date `now` belongs to. Rollover is 05:00 - a 02:00 session is still yesterday. */
export function logicalDate(now) {
  return new Date(now.getTime() - ROLLOVER_HOUR * 3600_000);
}

/** Daily note path, on the logical day. */
export function notePath(now) {
  const d = logicalDate(now);
  const y = String(d.getFullYear());
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return join(VAULT, "30-Sessions", y, m, `${y}-${m}-${day}.md`);
}

export function ensureNote(file, now) {
  if (existsSync(file)) return;
  mkdirSync(dirname(file), { recursive: true });
  const stamp = logicalDate(now).toISOString().slice(0, 10);
  writeFileSync(
    file,
    `---\ntype: session\nproject: knowledge\ntags: [session, log]\n` +
      `created: ${stamp}\nupdated: ${stamp}\nstatus: active\n---\n\n` +
      `# ${stamp}\n\nAuto-captured. Write the real log with \`/brain-log\`.\n\n## Sessions\n\n`,
    "utf8",
  );
}

const dbs = (sub) => {
  const d = join(CTX, sub);
  try {
    return readdirSync(d)
      .filter((f) => f.endsWith(".db"))
      .map((f) => join(d, f));
  } catch {
    return [];
  }
};

/** The SAME session_id can appear in several DBs - always union across all of them. */
export const sessionDbs = () => dbs("sessions");
export const contentDbs = () => dbs("content");

const STOP = new Set([
  "the", "and", "for", "with", "that", "this", "from", "have", "been", "are", "was",
  "you", "your", "can", "not", "but", "how", "why", "what", "when", "where", "does",
  "did", "its", "his", "her", "them", "they", "then", "than", "into", "out", "get",
  "got", "use", "using", "should", "would",
]);

/** Build a safe FTS5 MATCH string. Quoting each token neutralizes FTS5 operators. */
export function ftsMatch(text) {
  const toks = [
    ...new Set(
      (String(text).toLowerCase().match(/[a-z0-9_]{3,}/g) || []).filter((t) => !STOP.has(t)),
    ),
  ].slice(0, 8);
  return toks.length ? toks.map((t) => `"${t}"`).join(" OR ") : "";
}

// brain-lib.mjs - shared helpers for the brain memory hooks.
// Runtime is bun (`bun --bun`), per 00-Meta/Hard-Rules.
// Spec: C:\obsidian\root\40-Plans\2026-08-22-brain-memory-compiler.md
import { readFileSync, existsSync, mkdirSync, writeFileSync, readdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { homedir } from "node:os";
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

export const VAULT = "C:\\obsidian\\root";
export const HOOKS = join(homedir(), ".claude", "hooks");
export const CTX = join(homedir(), ".claude", "context-mode");
export const ROLLOVER_HOUR = 5;

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

/** Windows paths arrive with mixed separators - normalize before comparing. */
export function normDir(p) {
  return String(p || "").replace(/\//g, "\\").replace(/\\+$/, "").toLowerCase();
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

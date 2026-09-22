// brain-lib.mjs - shared helpers for the brain memory hooks.
// Runtime is bun (`bun --bun`), per 00-Meta/Hard-Rules.
// Spec: C:\obsidian\root\40-Plans\2026-08-22-brain-memory-compiler\2026-08-22-brain-memory-compiler.md
import { readFileSync, existsSync, mkdirSync, writeFileSync, readdirSync, appendFileSync, statSync } from "node:fs";
import { join, dirname, basename } from "node:path";
import { homedir, tmpdir } from "node:os";
import { execFileSync } from "node:child_process";
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
// Imported AND re-exported: a bare `export { … } from` creates no local binding, and brain-lib's own
// vault helpers need VAULT in scope. Getting this wrong fails at MODULE LOAD, before any hook's
// try/catch exists - so every hook importing this file dies at once. It did, on 2026-09-21.
import { VAULT, DEV_ROOT } from "./brain-paths.mjs";
export { VAULT, DEV_ROOT };
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
  // Local date parts, as notePath uses. toISOString() is UTC: a flush at 05:00-08:00 TST stamped
  // the previous day into a note whose path said today (2026-09-21.md was headed 2026-09-20).
  const d = logicalDate(now);
  const stamp = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
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

/**
 * Directories never indexed and never counted as notes - one list, shared by brain-reindex (what
 * gets indexed) and brain-doctor (what counts as a note). They used to be two lists, and they
 * drifted: the index took in `.remember/` scratch buffers that the doctor ignored, so the first
 * clean rebuild reported 7 ghosts that were really a disagreement between the two walkers.
 * `.remember/` and `.claude/` are agent scratch and config, not notes - serving them as vault
 * memory is the noise R1 removed (remember.md was one of the junk injections).
 */
export const INDEX_EXCLUDES = ["node_modules", "out", "target", ".git", "graphify-out", ".obsidian", ".remember", ".claude", ".brain"];

// ---- Vault-scoped search -------------------------------------------------------------------
// Shared by brain-inject (every prompt) and brain-doctor (the retrieval regression test), so the
// test exercises exactly the path production takes. Until 2026-09-21 brain-inject walked every
// content DB under a 50ms budget and never reached the vault's, which sorts 9th of 12.
// Evidence: 40-Plans/2026-09-20-vault-governance-overhaul/evidence/2026-09-21-retrieval-audit.md

/** `VAULT\%`. `\` is not an escape character in SQLite LIKE, so Windows paths need no handling. */
export const VAULT_LIKE = `${VAULT}${VAULT.includes("\\") ? "\\" : "/"}%`;
export const VAULT_DB_CACHE = join(tmpdir(), "brain-vault-db.json");

// Vault sources only, and never the dead 00-Brain tree left over from the rename. The path filter
// is what stops a stale copy outranking a live one: dedupe is by basename, so before this a
// 2026-09-10 snapshot of Hard-Rules.md could and did win.
const VAULT_SQL = `SELECT s.file_path AS path, snippet(chunks,1,'','','…',26) AS snip, bm25(chunks) AS rank
                   FROM chunks JOIN sources s ON s.id = chunks.source_id
                   WHERE chunks MATCH ?
                     AND s.file_path LIKE ?
                     AND s.file_path NOT LIKE '%00-Brain%'
                     AND s.file_path NOT LIKE ?
                   ORDER BY rank LIMIT 6`;
// Per-commit notes and their month index are records, not answers: hundreds of short notes would
// crowd rules and ADRs out of the six slots. They stay indexed (ctx_search finds them); injection
// skips them.
const COMMITS_LIKE = `%${join("50-Ops", "Commits")}${VAULT.includes("\\") ? "\\" : "/"}%`;
const VAULT_HAS = `SELECT 1 FROM sources WHERE file_path LIKE ? LIMIT 1`;

/** Query one DB: its vault hits, and whether it holds vault sources at all (for self-healing). */
function askVault(file, match) {
  let db;
  try {
    db = openDb(file);
    const rows = db.prepare(VAULT_SQL).all(match, VAULT_LIKE, COMMITS_LIKE);
    return { rows, isVault: rows.length > 0 || !!db.prepare(VAULT_HAS).get(VAULT_LIKE) };
  } catch {
    return { rows: [], isVault: false };
  } finally {
    try {
      db?.close();
    } catch {}
  }
}

/**
 * Search vault notes only. Steady state is one ~9ms open of the cached DB. On a miss - first run,
 * or context-mode re-keyed the project - it scans every content DB with NO time budget: a budget
 * on a scan whose target sorts late is exactly the bug this replaced. The scan runs once per
 * cache lifetime.
 *
 * Returns `{ rows, file }`; `file` is null when no DB holds vault sources at all.
 */
export function vaultSearch(match) {
  try {
    const cached = JSON.parse(readFileSync(VAULT_DB_CACHE, "utf8")).file;
    if (cached) {
      const r = askVault(cached, match);
      if (r.isVault) return { rows: r.rows, file: cached };
    }
  } catch {}
  for (const file of contentDbs()) {
    const r = askVault(file, match);
    if (!r.isVault) continue;
    try {
      writeFileSync(VAULT_DB_CACHE, JSON.stringify({ file, at: Date.now() }));
    } catch {}
    return { rows: r.rows, file };
  }
  return { rows: [], file: null };
}

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

// ---- Capture diagnostics + per-session flush watermarks ---------------------------------------
// Plan: 40-Plans/2026-09-20-vault-governance-overhaul/stages/vault-governance-02-session-capture.md

/** Runtime state that must survive a reboot. Gitignored in AtlasAta-DotFiles: state, not config. */
export const STATE_DIR = join(HOOKS, ".state");

/**
 * One JSON line per capture firing and per flush outcome, so a missing daily note can be traced to
 * the layer that dropped it - "PreCompact fired 03:12, flush answered FLUSH_OK" - instead of just
 * "a note is missing". In the vault, where the user reads it; gitignored there, because an
 * append-only log would otherwise leave the vault permanently dirty.
 */
export const HOOK_EVENTS = join(VAULT, "50-Ops", "hook-events.jsonl");

export function logEvent(e) {
  try {
    appendFileSync(HOOK_EVENTS, `${JSON.stringify({ ts: new Date().toISOString(), ...e })}\n`);
  } catch {}
}

const WATERMARKS = join(STATE_DIR, "flush-watermarks.json");
const WATERMARK_TTL_MS = 30 * 86_400_000;

/** `{ [sessionId]: { dbs: { [dbFile]: lastEventId }, turns, triedAt, flushedAt } }` */
export function readWatermarks() {
  try {
    return JSON.parse(readFileSync(WATERMARKS, "utf8"));
  } catch {
    return {};
  }
}

/** Merge `patch` into one session's watermark. Sessions untouched for 30 days are pruned. */
export function writeWatermark(sid, patch) {
  try {
    mkdirSync(STATE_DIR, { recursive: true });
    const all = readWatermarks();
    all[sid] = { ...all[sid], ...patch };
    const cutoff = Date.now() - WATERMARK_TTL_MS;
    for (const [k, v] of Object.entries(all)) if ((v.triedAt ?? v.flushedAt ?? 0) < cutoff) delete all[k];
    writeFileSync(WATERMARKS, JSON.stringify(all));
  } catch {}
}

/**
 * A session's transcript. `given` (the hook payload's transcript_path) is the fast path and usually
 * right, but it is sometimes absent or stale - Claude Code #13668 documents that for compactions,
 * and on 2026-09-10 it happened on ordinary SessionEnd too. The file is always on disk as
 * ~/.claude/projects/<slug>/<sessionId>.jsonl; session ids are UUIDs, so a filename match is exact.
 */
export function resolveTranscript(sessionId, given) {
  if (given && existsSync(given)) return given;
  const sid = String(sessionId || "").replace(/[^a-z0-9-]/gi, "");
  if (!sid) return null;
  const root = join(homedir(), ".claude", "projects");
  try {
    for (const d of readdirSync(root, { withFileTypes: true })) {
      if (!d.isDirectory()) continue;
      const f = join(root, d.name, `${sid}.jsonl`);
      if (existsSync(f)) return f;
    }
  } catch {}
  return null;
}

// ---- Repos, commits, the vault index -------------------------------------------------------
// Moved here in Stage 06: brain-commit and brain-doctor both need them (the duplication trigger).

const US = "\x1f"; // field separator in git --format output
const RS = "\x1e"; // record separator
const gitOut = (cwd, ...a) =>
  execFileSync("git", a, { cwd, encoding: "utf8", windowsHide: true, stdio: ["ignore", "pipe", "ignore"] });

/** The vault + every checkout under DEV_ROOT, each named for its GitHub remote (Conventions). */
export function repoList() {
  const roots = [VAULT];
  try {
    for (const e of readdirSync(DEV_ROOT, { withFileTypes: true }))
      if (e.isDirectory() && existsSync(join(DEV_ROOT, e.name, ".git"))) roots.push(join(DEV_ROOT, e.name));
  } catch {}
  return roots.map((root) => {
    let name = root.split(/[\\/]/).pop();
    try {
      name = gitOut(root, "remote", "get-url", "origin").trim().replace(/\.git$/, "").split(/[/:]/).pop() || name;
    } catch {}
    return { root, name };
  });
}

/** Non-merge commits in one repo since `since`, oldest first. The full hash is the identity. */
export function recentCommits({ root, name }, since) {
  let out = "";
  try {
    out = gitOut(root, "log", `--since=${since}`, "--no-merges", "--reverse", `--format=%H${US}%cI${US}%s${US}%b${RS}`);
  } catch {
    return [];
  }
  return out
    .split(RS)
    .map((r) => r.replace(/^\s+/, ""))
    .filter(Boolean)
    .map((r) => {
      const [hash, iso, subject, body = ""] = r.split(US);
      return { root, name, hash, iso, subject: subject || "(no subject)", body: body.trim() };
    })
    .filter((c) => /^[0-9a-f]{40}$/.test(c.hash));
}

/** What is recorded, read from the notes: full hashes, and each logical day's highest ordinal. */
export function recordedCommits() {
  const root = join(VAULT, "50-Ops", "Commits");
  const hashes = new Set();
  const maxOrdinal = new Map(); // "YYYY-MM-DD" -> N
  if (!existsSync(root)) return { hashes, maxOrdinal };
  for (const m of readdirSync(root, { withFileTypes: true })) {
    if (!m.isDirectory() || !/^\d{4}-\d{2}$/.test(m.name)) continue;
    for (const f of readdirSync(join(root, m.name))) {
      const hit = /^(\d{2})-x(\d+)-.+\.md$/.exec(f);
      if (!hit) continue;
      const day = `${m.name}-${hit[1]}`;
      maxOrdinal.set(day, Math.max(maxOrdinal.get(day) ?? 0, Number(hit[2])));
      const h = /^hash:\s*([0-9a-f]{40})/m.exec(readFileSync(join(root, m.name, f), "utf8"));
      if (h) hashes.add(h[1]);
    }
  }
  return { hashes, maxOrdinal };
}

/**
 * Rebuild the vault's context-mode index, synchronously. The same arguments brain-reindex has
 * always used; one definition, so the Routine's repair and the edit-time reindex cannot diverge.
 * Throws on failure - callers decide whether that is fatal.
 */
export function indexVault() {
  const cli = contextModeCli();
  if (!cli) throw new Error("context-mode CLI not found");
  execFileSync(
    process.execPath,
    [
      "--bun", cli, "index", VAULT,
      "--source", "brain-vault",
      "--max-depth", "4",
      // Per-commit notes add 100+ files a month; at 500 the index truncated silently.
      // brain-doctor's `unindexed` count is the tripwire.
      "--max-files", "20000",
      "--ext", ".md",
      ...INDEX_EXCLUDES.flatMap((e) => ["--exclude", `**/${e}/**`]),
    ],
    { cwd: VAULT, timeout: 600_000, stdio: "ignore", windowsHide: true },
  );
}

// ---- Notes on disk --------------------------------------------------------------------------------
// Moved from brain-doctor in Stage 07: brain-reindex's write-time check applies the same rules to
// one note, and two copies of "what is a broken link" would disagree sooner or later.

// Files whose top lines a tool or a reader consumes verbatim: no frontmatter, not notes to link.
export const NOTE_EXEMPT = /^(LICENSE.*|CLAUDE|AGENTS|README)\.md$/i;

/** Every note (lower-cased path -> { path, mtime }) and every file, skipping INDEX_EXCLUDES. */
export function walkVault() {
  const skip = new Set(INDEX_EXCLUDES);
  const notes = new Map();
  const files = []; // every file, for [[attachment.png]] links
  const go = (d) => {
    for (const e of readdirSync(d, { withFileTypes: true })) {
      if (skip.has(e.name)) continue;
      const p = join(d, e.name);
      if (e.isDirectory()) go(p);
      else {
        files.push(p);
        if (e.name.endsWith(".md")) notes.set(p.toLowerCase(), { path: p, mtime: statSync(p).mtimeMs });
      }
    }
  };
  go(VAULT);
  return { notes, files };
}

// A link inside `inline code` or a fenced block is an example, not a link - Obsidian does not follow
// it. Every link check strips code first, which is also what lets a prose example like `[[bin]]` stand.
const stripCode = (t) => t.replace(/`{3}[\s\S]*?`{3}/g, "").replace(/`[^`\n]*`/g, "");
// Closed on the same line, as Obsidian requires: an unclosed "[[" in prose is not a link. Before,
// `contains "[[".` in a commit body was read as a link to the rest of the file.
export const linksOf = (text) => [...stripCode(text).matchAll(/\[\[([^\]|#\n]+)[^\]\n]*\]\]/g)].map((m) => m[1].trim().split(/[\\/]/).pop());

/** `type` and `created` in a leading frontmatter block. */
export function frontmatterOk(text) {
  const m = /^---\r?\n([\s\S]*?)\r?\n---/.exec(text);
  return !!m && /^type:\s*\S/m.test(m[1]) && /^created:\s*\S/m.test(m[1]);
}

/** Intentional forward links, lower-cased. The list writes each link in backticks, so it contains no broken links itself. */
export function forwardLinks() {
  try {
    return new Set([...readFileSync(join(VAULT, "00-Meta", "Forward-Links.md"), "utf8").matchAll(/`\[\[([^\]|#]+)/g)].map((m) => m[1].trim().toLowerCase()));
  } catch {
    return new Set();
  }
}

/**
 * `(text) => targets` that resolve to no note, no file and no forward link, plus `Note#Heading`
 * for a [[Note#Heading]] whose note has no such heading. Build once, apply per note.
 */
export function brokenLinksIn({ notes, files }, allowed = forwardLinks()) {
  const names = new Set([...notes.values()].map((n) => basename(n.path, ".md").toLowerCase()));
  const fileNames = new Set(files.map((p) => basename(p).toLowerCase()));
  // The rules kernel links Hard-Rules sections (Stage 08): a renamed heading must not leave it
  // pointing nowhere. Headings are read lazily, once per note; fenced code holds no headings.
  const pathOf = new Map([...notes.values()].map((n) => [basename(n.path, ".md").toLowerCase(), n.path]));
  const headingsOf = new Map();
  const headings = (k) => {
    if (!headingsOf.has(k))
      headingsOf.set(k, new Set([...readFileSync(pathOf.get(k), "utf8").replace(/`{3}[\s\S]*?`{3}/g, "").matchAll(/^#{1,6}\s+(.+?)\s*$/gm)].map((m) => m[1].toLowerCase())));
    return headingsOf.get(k);
  };
  return (text) => [
    ...linksOf(text).filter((t) => {
      const k = t.toLowerCase();
      return !names.has(k) && !fileNames.has(k) && !allowed.has(k);
    }),
    // [^#^]: a nested [[Note#A#B]] or a block ref [[Note#^id]] is not checked.
    ...[...stripCode(text).matchAll(/\[\[([^\]|#\n]+)#([^\]|#^\n]+)(?:\|[^\]\n]*)?\]\]/g)]
      .map((m) => [m[1].trim().split(/[\\/]/).pop(), m[2].trim()])
      .filter(([n, h]) => pathOf.has(n.toLowerCase()) && !headings(n.toLowerCase()).has(h.toLowerCase()))
      .map(([n, h]) => `${n}#${h}`),
  ];
}

// ---- Decision ledger (Stage 07) -----------------------------------------------------------------
// One JSON line per captured decision. Tracked in git: these are durable records, unlike the hook
// event log. Written only through these functions, so the file is never hand-edited.

export const LEDGER = join(VAULT, "50-Ops", "decisions.jsonl");

export function ledgerRead() {
  try {
    return readFileSync(LEDGER, "utf8").split("\n").filter(Boolean).map((l) => JSON.parse(l));
  } catch {
    return [];
  }
}

/** Append entries whose `src` is not already in the ledger. Returns how many were added. */
export function ledgerAdd(entries) {
  const seen = new Set(ledgerRead().map((e) => e.src));
  const fresh = entries.filter((e) => e.src && !seen.has(e.src));
  if (fresh.length) appendFileSync(LEDGER, fresh.map((e) => `${JSON.stringify({ ts: new Date().toISOString(), promoted: null, ...e })}\n`).join(""));
  return fresh.length;
}

/**
 * Update one entry in place, by `src`. Rewrites the whole file - it is small.
 * ponytail: a flush appending during this rewrite can lose its line; the next flush of that
 * session re-adds nothing (its watermark moved). A lock shared with ledgerAdd is the upgrade.
 */
export function ledgerSet(src, patch) {
  const all = ledgerRead();
  const i = all.findIndex((e) => e.src === src);
  if (i === -1) return false;
  all[i] = { ...all[i], ...patch };
  writeFileSync(LEDGER, all.map((e) => `${JSON.stringify(e)}\n`).join(""));
  return true;
}

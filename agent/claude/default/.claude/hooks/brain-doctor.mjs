// brain-doctor.mjs - zero-token vault health check. Emits JSON; exit 0 always.
// Runtime is bun (`bun --bun`), per 00-Meta/Hard-Rules.
// Spec: C:\obsidian\root\40-Plans\2026-09-20-vault-governance-overhaul\spec.md § Component 2
//
//   bun --bun ~/.claude/hooks/brain-doctor.mjs            JSON, for the daily Routine
//   bun --bun ~/.claude/hooks/brain-doctor.mjs --pretty   table, for a human
//
// Why this exists: every failure of this system so far was SILENT. The vault's retrieval hook
// never returned a vault note for as long as it existed, and nothing noticed, because nothing
// asserted that a vault-shaped question gets a vault answer. That assertion is `retrieval` below.
//
// Two of ten planned checks. The rest land with Part B of the spec.
import { readdirSync, statSync } from "node:fs";
import { join, basename } from "node:path";
import { VAULT, VAULT_LIKE, INDEX_EXCLUDES, openDb, ftsMatch, vaultSearch } from "./brain-lib.mjs";

const pretty = process.argv.includes("--pretty");
const FLOOR = -6; // must match brain-inject: a hit it would not show is a miss here too
const GRACE_MS = 10 * 60_000; // brain-reindex is detached; a note written a minute ago is fine

/**
 * Ground truth. Each query must return its expected note in the top hits, above FLOOR.
 *
 * Chosen so the expected note is unambiguous, and keyed by BASENAME so the Part D restructure -
 * which moves folders but renames none of these files - does not break the test. If a case
 * starts failing after a move, the move broke retrieval; that is the point.
 */
const CASES = [
  ["Wayland compositing guard WEBKIT_DISABLE_COMPOSITING_MODE", "wayland-compositing-guard"],
  ["bunx never bare bunx node shebang", "Hard-Rules"],
  ["GPL AAKCL withdrawn commercial", "0031-gpl-3-only-aakcl-withdrawn"],
  ["retrieval protocol tiers ctx_search graphify", "Retrieval-Protocol"],
  ["one binary not four windows", "0002-one-binary-not-four"],
  ["frontmatter schema naming conventions wikilinks", "Conventions"],
];

const SKIP = new Set(INDEX_EXCLUDES); // the same list brain-reindex indexes by

/** Every vault note, with its mtime. */
function notes() {
  const out = new Map();
  const walk = (d) => {
    for (const e of readdirSync(d, { withFileTypes: true })) {
      if (SKIP.has(e.name)) continue;
      const p = join(d, e.name);
      if (e.isDirectory()) walk(p);
      else if (e.name.endsWith(".md")) out.set(p.toLowerCase(), { path: p, mtime: statSync(p).mtimeMs });
    }
  };
  walk(VAULT);
  return out;
}

/** Is the vault's index present, live, keyed to this OS, and current note by note? */
function checkIndex() {
  // vaultSearch() resolves (and self-heals the cache for) the one DB holding vault sources.
  const { file } = vaultSearch(ftsMatch("vault notes"));
  if (!file) return { id: "vault-index", ok: false, detail: { reason: "no content DB holds any vault source" } };

  let rows = [];
  let dead = 0;
  let db;
  try {
    db = openDb(file);
    rows = db.prepare(`SELECT file_path, indexed_at FROM sources WHERE file_path LIKE ?`).all(VAULT_LIKE);
    dead = db.prepare(`SELECT count(*) c FROM sources WHERE file_path LIKE '%00-Brain%'`).get().c;
  } finally {
    try {
      db?.close();
    } catch {}
  }

  // `indexed_at` is SQLite datetime('now'): UTC, no zone marker.
  const indexed = new Map(rows.map((r) => [String(r.file_path).toLowerCase(), Date.parse(`${r.indexed_at.replace(" ", "T")}Z`)]));
  const all = notes();

  const unindexed = [];
  const stale = [];
  for (const [key, n] of all) {
    const at = indexed.get(key);
    if (at === undefined) unindexed.push(n.path);
    else if (n.mtime > at + GRACE_MS) stale.push(n.path);
  }
  // The reverse direction: rows for files that no longer exist. A ghost is the same hazard as the
  // dead 00-Brain rows - dedupe is by basename, so a ghost can outrank the live note. First run
  // of this check read 223 live rows against 204 notes and called it healthy; that was the miss.
  const ghosts = rows
    .map((r) => String(r.file_path))
    .filter((p) => !/00-Brain/i.test(p) && !all.has(p.toLowerCase()));
  const rel = (p) => p.slice(VAULT.length + 1);

  return {
    id: "vault-index",
    ok: unindexed.length === 0 && stale.length === 0 && dead === 0 && ghosts.length === 0,
    detail: {
      db: basename(file),
      notes: all.size,
      rows: rows.length,
      deadRows: dead,
      ghostRows: ghosts.length,
      unindexed: unindexed.length,
      stale: stale.length,
      samples: [
        ...unindexed.slice(0, 5).map((p) => `unindexed: ${rel(p)}`),
        ...stale.slice(0, 5).map((p) => `stale: ${rel(p)}`),
        ...ghosts.slice(0, 8).map((p) => `ghost: ${rel(p)}`),
      ],
    },
  };
}

/** The regression test: vault-shaped questions must return the right vault note. */
function checkRetrieval() {
  const failed = [];
  for (const [q, want] of CASES) {
    const { rows } = vaultSearch(ftsMatch(q));
    const got = rows.filter((r) => r.rank < FLOOR).map((r) => basename(String(r.path), ".md"));
    if (!got.includes(want)) failed.push({ q, want, got: [...new Set(got)].slice(0, 4) });
  }
  return {
    id: "retrieval",
    ok: failed.length === 0,
    detail: { passed: CASES.length - failed.length, total: CASES.length, failed },
  };
}

const run = (fn) => {
  try {
    return fn();
  } catch (e) {
    return { id: fn.name, ok: false, detail: { error: String(e?.message ?? e) } };
  }
};

const checks = [run(checkIndex), run(checkRetrieval)];
const report = {
  ok: checks.every((c) => c.ok),
  at: new Date().toISOString(),
  checks,
  // Stated rather than silently skipped: a script cannot call an MCP tool.
  untestable: ["ctx_search (MCP) project scoping — measured 2026-09-21 returning session-events only"],
};

if (pretty) {
  const mark = (ok) => (ok ? "PASS" : "FAIL");
  console.log(`brain-doctor  ${mark(report.ok)}  ${report.at}\n`);
  for (const c of checks) {
    console.log(`  ${mark(c.ok)}  ${c.id}`);
    for (const [k, v] of Object.entries(c.detail)) {
      if (Array.isArray(v)) {
        for (const x of v) console.log(`          ${typeof x === "string" ? x : JSON.stringify(x)}`);
      } else console.log(`          ${k}: ${v}`);
    }
  }
  console.log(`\n  untestable: ${report.untestable.join("; ")}`);
} else {
  process.stdout.write(JSON.stringify(report));
}
process.exit(0);

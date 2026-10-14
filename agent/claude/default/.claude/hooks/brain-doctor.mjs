// brain-doctor.mjs - zero-token vault health check. JSON by default; exit 0 always.
// Plan: C:\obsidian\root\40-Plans\2026-09-20-vault-governance-overhaul\stages\vault-governance-06-daily-sweep.md
//
//   bun --bun ~/.claude/hooks/brain-doctor.mjs            JSON, for the Routine
//   ... --pretty                                          table, for a human
//   ... --repair                                          idempotent repairs, then check
//   ... --record                                          write today's line to 50-Ops/Health/
//
// Every failure of this system so far was SILENT - the retrieval hook never returned a vault note
// for as long as it existed, and nothing noticed. Each check below exists because of one.
// A `fail` check makes the report FAIL; a `warn` check is reported and does not.
// --repair runs only what is safe to run twice and cannot lose data (spec D9): prune ghost index
// rows, re-index, graph rebuild, hub regeneration. It never edits, moves or deletes a note.
// A plain run writes one derived artifact too: the graph, when `graph-links` finds it stale.
import { readdirSync, readFileSync, existsSync, writeFileSync, mkdirSync, realpathSync } from "node:fs";
import { join, basename, dirname, isAbsolute } from "node:path";
import { homedir } from "node:os";
import { execFileSync } from "node:child_process";
import {
  VAULT, DEV_ROOT, HOOKS, VAULT_LIKE, HOOK_EVENTS,
  openDb, ftsMatch, vaultSearch, failures, logicalDate, notePath,
  repoList, recentCommits, recordedCommits, unrecorded, indexVault, pruneVaultIndex,
  rebuildGraph, missingLinkEdges, wikilinkPairs, MERGED_GRAPH,
  NOTE_EXEMPT as EXEMPT, walkVault as walk, linksOf, frontmatterOk, forwardLinks, brokenLinksIn,
} from "./brain-lib.mjs";

const pretty = process.argv.includes("--pretty");
const repair = process.argv.includes("--repair");
const record = process.argv.includes("--record");
const FLOOR = -6; // must match brain-inject: a hit it would not show is a miss here too
const GRACE_MS = 10 * 60_000; // brain-reindex is debounced; a note written a minute ago is fine

/** Ground truth. Keyed by basename, so moves cannot break it; a failing case means retrieval broke. */
const CASES = [
  ["Wayland compositing guard WEBKIT_DISABLE_COMPOSITING_MODE", "wayland-compositing-guard"],
  ["bunx never bare bunx node shebang", "Hard-Rules"],
  ["GPL AAKCL withdrawn commercial", "0031-gpl-3-only-aakcl-withdrawn"],
  ["retrieval protocol tiers ctx_search graphify", "Retrieval-Protocol"],
  ["one binary not four windows", "0002-one-binary-not-four"],
  ["frontmatter schema naming conventions wikilinks", "Conventions"],
];

// ---- the vault on disk (walk, links, frontmatter: shared with brain-reindex, in brain-lib) -------

const rel = (p) => p.slice(VAULT.length + 1);
const isRootFile = (p) => !rel(p).includes("\\") && !rel(p).includes("/");

// ---- checks -------------------------------------------------------------------------------------

function checkIndex({ notes }) {
  const { file } = vaultSearch(ftsMatch("vault notes"));
  if (!file) return { id: "vault-index", level: "fail", ok: false, detail: { reason: "no content DB holds any vault source" } };
  let rows = [];
  let dead = 0;
  let db;
  try {
    db = openDb(file);
    rows = db.prepare(`SELECT file_path, indexed_at FROM sources WHERE file_path LIKE ?`).all(VAULT_LIKE);
    dead = db.prepare(`SELECT count(*) c FROM sources WHERE file_path LIKE '%00-Brain%'`).get().c;
  } finally {
    try { db?.close(); } catch {}
  }
  const indexed = new Map(rows.map((r) => [String(r.file_path).toLowerCase(), Date.parse(`${r.indexed_at.replace(" ", "T")}Z`)]));
  const unindexed = [];
  const pending = []; // unindexed but younger than GRACE_MS: brain-reindex's debounce has not fired yet
  const stale = [];
  // context-mode's chunker splits on "\n" and its heading regex fails on a trailing "\r": a CRLF
  // note is indexed as ONE chunk and loses every ranking. Found 2026-09-22 (retrieval fell to 5/6).
  const crlf = [];
  for (const [key, n] of notes) {
    const at = indexed.get(key);
    if (at === undefined) (Date.now() - n.mtime < GRACE_MS ? pending : unindexed).push(n.path);
    else if (n.mtime > at + GRACE_MS) stale.push(n.path);
    if (readFileSync(n.path, "utf8").includes("\r\n")) crlf.push(n.path);
  }
  const ghosts = rows.map((r) => String(r.file_path)).filter((p) => !/00-Brain/i.test(p) && !notes.has(p.toLowerCase()));
  return {
    id: "vault-index", level: "fail",
    ok: !unindexed.length && !stale.length && !dead && !ghosts.length && !crlf.length,
    detail: {
      db: basename(file), notes: notes.size, rows: rows.length, deadRows: dead, ghostRows: ghosts.length,
      unindexed: unindexed.length, pending: pending.length, stale: stale.length, crlf: crlf.length,
      samples: [
        ...unindexed.slice(0, 5).map((p) => `unindexed: ${rel(p)}`),
        ...stale.slice(0, 5).map((p) => `stale: ${rel(p)}`),
        ...ghosts.slice(0, 5).map((p) => `ghost: ${rel(p)}`),
        ...crlf.slice(0, 5).map((p) => `crlf: ${rel(p)}`),
      ],
    },
  };
}

function checkRetrieval() {
  const failed = [];
  for (const [q, want] of CASES) {
    const got = vaultSearch(ftsMatch(q)).rows.filter((r) => r.rank < FLOOR).map((r) => basename(String(r.path), ".md"));
    if (!got.includes(want)) failed.push({ q, want, got: [...new Set(got)].slice(0, 4) });
  }
  return { id: "retrieval", level: "fail", ok: !failed.length, detail: { passed: CASES.length - failed.length, total: CASES.length, failed } };
}

/**
 * Yesterday's daily note exists - or every session that captured yesterday was flushed and judged
 * non-durable. A flush writes a note only on durable output, so a quiet day has captures and no
 * note by design; 2026-10-12/13 failed this check while every flush was a genuine FLUSH_OK.
 */
function checkSessions() {
  const file = notePath(new Date(Date.now() - 86_400_000));
  const day = basename(file, ".md");
  if (existsSync(file)) return { id: "sessions", level: "fail", ok: true, detail: { day, note: true } };
  // Without the capture log this check could not tell a broken pipeline from a day off.
  const captured = new Map(); // sid -> last capture ts that day
  const settled = new Map(); // sid -> last flush ts that judged its material
  try {
    for (const l of readFileSync(HOOK_EVENTS, "utf8").split("\n")) {
      try {
        const e = JSON.parse(l);
        if (e.hook === "capture" && basename(notePath(new Date(e.ts)), ".md") === day) captured.set(e.sid, e.ts);
        // Any day: a session's tail is often flushed by SessionEnd after the rollover.
        if (e.hook === "flush" && ["flush-ok", "nothing-new", "wrote"].includes(e.outcome)) settled.set(e.sid, e.ts);
      } catch {}
    }
  } catch {}
  const unsettled = [...captured].filter(([sid, ts]) => !(settled.get(sid) >= ts)).map(([sid]) => sid.slice(0, 8));
  const reading = !captured.size ? "no session that day"
    : unsettled.length ? "sessions ran and no note was written" : "sessions ran, every flush judged nothing durable";
  return { id: "sessions", level: "fail", ok: !unsettled.length, detail: { day, note: false, sessions: captured.size, unsettled, reading } };
}

function checkAuth() {
  const f = failures();
  return { id: "auth", level: "fail", ok: !Object.keys(f).length, detail: Object.fromEntries(Object.entries(f).map(([k, v]) => [k, v.reason])) };
}

function checkFrontmatter({ notes }) {
  const bad = [];
  for (const { path } of notes.values()) {
    if (EXEMPT.test(basename(path))) continue;
    if (!frontmatterOk(readFileSync(path, "utf8"))) bad.push(rel(path));
  }
  return { id: "frontmatter", level: "fail", ok: !bad.length, detail: { bad: bad.length, samples: bad.slice(0, 8) } };
}

/** Every [[link]] resolves, except the intentional forward links listed in 00-Meta/Forward-Links.md. */
function checkLinks(vault) {
  const allowed = forwardLinks();
  const brokenIn = brokenLinksIn(vault, allowed);
  const broken = [];
  for (const { path } of vault.notes.values())
    for (const t of brokenIn(readFileSync(path, "utf8"))) broken.push(`${rel(path)} -> [[${t}]]`);
  return { id: "links", level: "fail", ok: !broken.length, detail: { broken: broken.length, allowedForward: allowed.size, samples: broken.slice(0, 8) } };
}

/** The vault's own promise: every note within 2 hops of 00-MOC-Root; records (daily, commit) within 3. */
function checkReach({ notes }) {
  const byName = new Map();
  for (const n of notes.values()) byName.set(basename(n.path, ".md").toLowerCase(), n.path);
  const adj = new Map();
  for (const n of notes.values()) adj.set(n.path, linksOf(readFileSync(n.path, "utf8")).map((t) => byName.get(t.toLowerCase())).filter(Boolean));
  const start = byName.get("00-moc-root");
  const depth = new Map([[start, 0]]);
  let frontier = [start];
  for (let d = 1; d <= 3; d++) {
    const next = [];
    for (const p of frontier) for (const q of adj.get(p) || []) if (!depth.has(q)) { depth.set(q, d); next.push(q); }
    frontier = next;
  }
  const isRecord = (p) => /[\\/]30-Sessions[\\/]/.test(p) || /[\\/]50-Ops[\\/]Commits[\\/]\d{4}-\d{2}[\\/]/.test(p);
  const orphans = [];
  for (const { path } of notes.values()) {
    if (isRootFile(path) && EXEMPT.test(basename(path))) continue;
    const d = depth.get(path);
    if (d === undefined || d > (isRecord(path) ? 3 : 2)) orphans.push(rel(path));
  }
  return { id: "reach", level: "fail", ok: !orphans.length, detail: { orphans: orphans.length, samples: orphans.slice(0, 8) } };
}

/** Stale ignore paths broke Obsidian (33 GB indexable) and shrank the graph, both silently. */
function checkIgnores() {
  const stale = [];
  try {
    for (const raw of readFileSync(join(VAULT, ".graphifyignore"), "utf8").split("\n")) {
      const line = raw.trim();
      if (!line || line.startsWith("#")) continue;
      const fixed = line.replace(/^!/, "").split("*")[0].replace(/\/+$/, "");
      if (fixed && !existsSync(join(VAULT, fixed))) stale.push(`.graphifyignore: ${line}`);
    }
  } catch {}
  try {
    for (const p of JSON.parse(readFileSync(join(VAULT, ".obsidian", "app.json"), "utf8")).userIgnoreFilters || [])
      if (!existsSync(join(VAULT, String(p).replace(/\/+$/, "")))) stale.push(`userIgnoreFilters: ${p}`);
  } catch {}
  return { id: "ignores", level: "fail", ok: !stale.length, detail: { stale } };
}

/** Every commit of the last 3 days has its note (Stage 01). */
function checkCommits() {
  const { hashes } = recordedCommits();
  const missing = [];
  for (const c of unrecorded(repoList().flatMap((r) => recentCommits(r, "3.days.ago")), hashes)) {
    let files = [];
    try { files = execFileSync("git", ["show", "--name-only", "--format=", c.hash], { cwd: c.root, encoding: "utf8" }).split("\n").filter(Boolean); } catch {}
    if (c.root === VAULT && files.length && files.every((f) => f.startsWith("50-Ops/Commits/"))) continue; // record-only commits are skipped by design
    missing.push(`${c.name} ${c.hash.slice(0, 7)} ${c.subject.slice(0, 60)}`);
  }
  return { id: "commits", level: "fail", ok: !missing.length, detail: { missing: missing.length, samples: missing.slice(0, 8) } };
}

/**
 * Identity and Hard-Rules reach every session whole: ~/.claude/CLAUDE.md imports both, every import
 * resolves, and the session hook stays under Claude Code's 10,000-char additionalContext limit (over
 * it, Claude gets a file path and a 2,000-char preview). The old in-hook cap dropped the rules
 * kernel instead, and nothing noticed (2026-10-09).
 */
function checkPriming() {
  const LIMIT = 10_000;
  const md = join(homedir(), ".claude", "CLAUDE.md");
  const norm = (p) => p.replace(/\\/g, "/").toLowerCase();
  const imports = [...readFileSync(md, "utf8").matchAll(/^@(\S+)\s*$/gm)]
    .map((m) => m[1].replace(/^~(?=[\\/])/, homedir()))
    .map((p) => (isAbsolute(p) ? p : join(dirname(md), p)));
  const missing = imports.filter((p) => !existsSync(p));
  const unimported = ["Identity.md", "Hard-Rules.md"]
    .map((f) => join(VAULT, "00-Meta", f))
    .filter((r) => !imports.some((i) => norm(i) === norm(r)));
  let hookChars = -1;
  try {
    const out = execFileSync(process.execPath, ["--bun", join(HOOKS, "brain-session.mjs"), "--dry"], { input: "{}", encoding: "utf8", timeout: 30_000, windowsHide: true });
    hookChars = JSON.parse(out).hookSpecificOutput.additionalContext.length;
  } catch {}
  return {
    id: "priming", level: "fail",
    ok: !missing.length && !unimported.length && hookChars >= 0 && hookChars <= LIMIT,
    detail: { imports: imports.length, missing, unimported: unimported.map(rel), hookChars, limit: LIMIT },
  };
}

// Tracked on DotFiles `main` because arch-caelestia takes them from there, but each platform branch
// keeps its own content (ADR AtlasAta-DotFiles/0004). Deleting them from `main` would delete Arch's
// copies on its next merge of `main`, so they stay, exempt from parity.
const PER_BRANCH_ON_MAIN = new Set([
  "agent/claude/default/.claude/commands/brain-commits.md",
  "agent/claude/default/.claude/commands/brain-sync.md",
]);

/**
 * DotFiles `main` holds only shared material (ADR AtlasAta-DotFiles/0003), so every file it tracks
 * must be identical on the checked-out platform branch. A hook fix committed straight to `windows`
 * (7dc1b16) was missing from `main` for weeks and nothing noticed. Read-only and local refs only:
 * no fetch, and the other OS's branch is never read.
 */
function checkDotfilesParity() {
  const repo = execFileSync("git", ["rev-parse", "--show-toplevel"], { cwd: realpathSync(HOOKS), encoding: "utf8", windowsHide: true }).trim();
  const git = (...a) => execFileSync("git", a, { cwd: repo, encoding: "utf8", windowsHide: true }).split("\n").filter(Boolean);
  const branch = git("rev-parse", "--abbrev-ref", "HEAD")[0];
  const shared = new Set(git("ls-tree", "-r", "--name-only", "main").filter((f) => !PER_BRANCH_ON_MAIN.has(f)));
  const differ = git("diff", "--name-only", "main", "HEAD").filter((f) => shared.has(f));
  return {
    id: "dotfiles-parity", level: "fail", ok: !differ.length,
    detail: { branch, shared: shared.size, differ: differ.length, samples: differ.slice(0, 8) },
  };
}

/** Every [[wikilink]] between two notes is an edge in the served graph (graphify drops cross-folder links). */
function checkGraphLinks() {
  const scan = () => missingLinkEdges(JSON.parse(readFileSync(MERGED_GRAPH, "utf8")), "root::");
  let missing = scan();
  // A link written since the last rebuild is a stale graph, not a broken bridge: rebuild once and
  // re-check, so only an edge the rebuild still drops fails (2026-10-10, a fresh session-log link).
  // Only when something is missing, so a clean graph costs nothing. --repair skips it: its own graph
  // step rebuilds before the after-check, and the before-check should report the stale state.
  let rebuilt = false;
  if (missing.length && !repair) {
    try { rebuildGraph(); rebuilt = true; missing = scan(); } catch {}
  }
  return {
    id: "graph-links", level: "fail", ok: !missing.length,
    detail: { pairs: wikilinkPairs().size, missing: missing.length, rebuilt, samples: missing.slice(0, 5).map(({ from, to }) => `${from} -> ${to}`) },
  };
}

/** Reported, not failed: normal mid-day, but worth seeing every day. */
function checkHygiene() {
  const out = {};
  try {
    // Machine-written paths are dirty by design until the next vault commit (D9: the Routine never
    // commits), so counting them would warn every single day. What matters is human work at risk.
    const MACHINE = /^.. (\.obsidian\/|50-Ops\/|30-Sessions\/|graphify-out\/)/;
    out.uncommitted = execFileSync("git", ["status", "--porcelain"], { cwd: VAULT, encoding: "utf8" }).split("\n").filter((l) => l && !MACHINE.test(l)).length;
  } catch {}
  // D11: durable memory belongs in the vault. Non-empty per-cwd shards and stray files in checkouts are drift.
  const shards = [];
  try {
    const root = join(homedir(), ".claude", "projects");
    for (const d of readdirSync(root)) {
      const m = join(root, d, "memory");
      if (existsSync(m) && readdirSync(m).some((f) => f.endsWith(".md") && f !== "MEMORY.md")) shards.push(d);
    }
  } catch {}
  out.memoryShards = shards.length;
  // A file the checkout's own git tracks is that repo's documentation, which the vault never
  // duplicates - only untracked agent leftovers are strays (owner's decision, Stage 08).
  const tracked = (repo, f) => {
    try {
      execFileSync("git", ["ls-files", "--error-unmatch", f], { cwd: repo, stdio: "ignore" });
      return true;
    } catch {
      return false;
    }
  };
  const strays = [];
  try {
    for (const d of readdirSync(DEV_ROOT))
      for (const f of ["MEMORY.md", ".implementation_plan.md", ".remember"])
        if (existsSync(join(DEV_ROOT, d, f)) && !tracked(join(DEV_ROOT, d), f)) strays.push(`${d}/${f}`);
  } catch {}
  out.straysInCheckouts = strays;
  try {
    out.unpromotedDecisions = readFileSync(join(VAULT, "50-Ops", "decisions.jsonl"), "utf8").split("\n").filter((l) => l.includes('"promoted":null')).length;
  } catch {
    out.unpromotedDecisions = 0;
  }
  const ok = !out.uncommitted && !shards.length && !strays.length && !out.unpromotedDecisions;
  return { id: "hygiene", level: "warn", ok, detail: out };
}

function runChecks() {
  const vault = walk();
  const guard = (fn) => {
    try {
      return fn(vault);
    } catch (e) {
      return { id: fn.name.replace(/^check/, "").toLowerCase(), level: "fail", ok: false, detail: { error: String(e?.message ?? e) } };
    }
  };
  return [checkIndex, checkRetrieval, checkSessions, checkAuth, checkFrontmatter, checkLinks, checkReach, checkIgnores, checkCommits, checkPriming, checkGraphLinks, checkDotfilesParity, checkHygiene].map(guard);
}

// ---- repair (derived artifacts only) -------------------------------------------------------------

function runRepairs() {
  const since = new Date(Date.now() - 3 * 864e5).toISOString().slice(0, 10); // checkCommits' window
  const steps = [
    // Commits made outside a Claude Bash call (terminal, PowerShell, other hooks) get no PostToolUse
    // note; the sweep records them here, before reindex so the new notes are indexed.
    ["commits", () => execFileSync(process.execPath, ["--bun", join(HOOKS, "brain-commit.mjs"), "--backfill", since], { timeout: 120_000, stdio: "ignore", windowsHide: true })],
    // Hubs read the filesystem only, and write MOC links (a new day's [[YYYY-MM-DD]]) that reindex and
    // graph must see. Run after them and the graph misses those links: graph-links FAIL, 2026-10-10.
    ["hubs", () => execFileSync(process.execPath, ["--bun", join(HOOKS, "brain-hubs.mjs")], { timeout: 60_000, stdio: "ignore", windowsHide: true })],
    ["prune", () => pruneVaultIndex()],
    ["reindex", () => indexVault()],
    ["graph", () => rebuildGraph()], // graphify + wikilink bridge + merge into the served graph
  ];
  return steps.map(([step, fn]) => {
    const t = Date.now();
    try {
      fn();
      return { step, ok: true, ms: Date.now() - t };
    } catch (e) {
      return { step, ok: false, ms: Date.now() - t, error: String(e?.message ?? e).split("\n")[0] };
    }
  });
}

// ---- record --------------------------------------------------------------------------------------

function writeRecord(report) {
  const d = logicalDate(new Date());
  const pad = (n) => String(n).padStart(2, "0");
  const month = `${d.getFullYear()}-${pad(d.getMonth() + 1)}`;
  const day = `${month}-${pad(d.getDate())}`;
  const now = new Date();
  const failing = report.checks.filter((c) => c.level === "fail" && !c.ok).map((c) => c.id);
  const warning = report.checks.filter((c) => c.level === "warn" && !c.ok).map((c) => c.id);
  const notes = report.checks.find((c) => c.id === "vault-index")?.detail?.notes ?? "?";
  const line = `- ${day} ${pad(now.getHours())}:${pad(now.getMinutes())} **${report.ok ? "PASS" : "FAIL"}** · failing: ${failing.join(", ") || "none"} · warn: ${warning.join(", ") || "none"} · notes=${notes}`;
  const dir = join(VAULT, "50-Ops", "Health");
  const file = join(dir, `health-${month}.md`);
  const created = !existsSync(file);
  mkdirSync(dir, { recursive: true });
  const head = ["---", "type: usage", "project: knowledge", "tags: [health, ops, generated]", `created: ${month}-01`, `updated: ${day}`, "status: active", "---", "", `# Vault health — ${month}`, "", "One line per logical day from `brain-doctor --record`. The 17:00 Routine may indent an explanation under a FAIL line.", ""].join("\n");
  let body = existsSync(file) ? readFileSync(file, "utf8") : head;
  // Replace today's line on a re-run, so a day has one line. The explanation indented under it is kept,
  // and a replaced FAIL line is kept as a bullet so that explanation still says what it explains.
  const lines = body.split("\n");
  const at = lines.findIndex((l) => l.startsWith(`- ${day} `));
  if (at !== -1) {
    const old = lines[at];
    lines.splice(at, 1, line, ...(old.includes("**FAIL**") ? [`  - replaced: ${old.slice(2)}`] : []));
    body = lines.join("\n");
  } else body = `${body.replace(/\n*$/, "\n")}${line}\n`;
  writeFileSync(file, body.replace(/^updated: .*$/m, `updated: ${day}`), "utf8");
  // This write lands AFTER the checks and repairs, and a script write fires no reindex hook. Without
  // re-deriving here, a month's first file is an orphan and every day's line goes `stale` 10 min later.
  if (created) try { execFileSync(process.execPath, ["--bun", join(HOOKS, "brain-hubs.mjs")], { timeout: 60_000, stdio: "ignore", windowsHide: true }); } catch {}
  try { indexVault(); } catch {} // after the hubs, so a regenerated hub is indexed too
  return rel(file);
}

// ---- main ----------------------------------------------------------------------------------------

let before = null;
let repairs;
if (repair) {
  before = runChecks();
  repairs = runRepairs();
}
const checks = runChecks();
const report = {
  ok: checks.every((c) => c.level !== "fail" || c.ok),
  at: new Date().toISOString(),
  checks,
  ...(repair ? { repairs, repaired: before.filter((b) => !b.ok && checks.find((c) => c.id === b.id)?.ok).map((b) => b.id) } : {}),
  untestable: ["ctx_search (MCP) project scoping — a script cannot call an MCP tool"],
};
if (record) report.recorded = writeRecord(report);

if (pretty) {
  const mark = (c) => (c.ok ? "PASS" : c.level === "warn" ? "WARN" : "FAIL");
  console.log(`brain-doctor  ${report.ok ? "PASS" : "FAIL"}  ${report.at}\n`);
  if (repairs) console.log(`  repairs: ${repairs.map((r) => `${r.step}=${r.ok ? "ok" : "FAILED"} ${r.ms}ms`).join("  ")}${report.repaired.length ? `  -> fixed: ${report.repaired.join(", ")}` : ""}\n`);
  for (const c of checks) {
    console.log(`  ${mark(c)}  ${c.id}`);
    for (const [k, v] of Object.entries(c.detail)) {
      if (Array.isArray(v)) for (const x of v) console.log(`          ${typeof x === "string" ? x : JSON.stringify(x)}`);
      else console.log(`          ${k}: ${typeof v === "object" ? JSON.stringify(v) : v}`);
    }
  }
  if (report.recorded) console.log(`\n  recorded: ${report.recorded}`);
  console.log(`\n  untestable: ${report.untestable.join("; ")}`);
} else process.stdout.write(JSON.stringify(report));
process.exit(0);

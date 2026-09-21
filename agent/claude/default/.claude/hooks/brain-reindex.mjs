// brain-reindex.mjs - PostToolUse(Edit|Write). Trailing-debounce rebuild of both indexes.
// Runtime is bun (`bun --bun`), per 00-Meta/Hard-Rules.
// Spec: C:\obsidian\root\40-Plans\2026-08-22-brain-memory-compiler.md
import { readFileSync, writeFileSync, unlinkSync, existsSync, readdirSync } from "node:fs";
import { join, sep } from "node:path";
import { tmpdir } from "node:os";
import { spawn, execFileSync } from "node:child_process";
import { readStdin, normDir, VAULT, HOOKS, DEV_ROOT, contextModeCli, INDEX_EXCLUDES } from "./brain-lib.mjs";

const STAMP = join(tmpdir(), "brain-reindex.json");
const DEBOUNCE_MS = 90_000;
const LOCK_STALE_MS = 15 * 60_000; // a settler that died leaves a lock; expire it
const EXCLUDES = INDEX_EXCLUDES; // shared with brain-doctor, so what is indexed and what counts as a note cannot drift
// context-mode is NOT on PATH - it ships as a plugin bundle. Invoke it through the runtime.
const CM_CLI = contextModeCli();
// Checkouts left the vault on 2026-09-06 - see [[0012-repos-leave-the-vault-index-stays]].
// DEV_ROOT comes from brain-paths.mjs: C:\dev on Windows, ~/dev on Arch.

// Every child runs headless. Without this, each one opens a console window on Windows.
const QUIET = { stdio: "ignore", windowsHide: true };

const read = () => {
  try {
    return JSON.parse(readFileSync(STAMP, "utf8"));
  } catch {
    return null;
  }
};
const write = (o) => {
  try {
    writeFileSync(STAMP, JSON.stringify(o));
  } catch {}
};
const clear = () => {
  try {
    if (existsSync(STAMP)) unlinkSync(STAMP);
  } catch {}
};

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

/**
 * Index one checkout's markdown — `docs/` (plans, DESIGN, DEVELOPMENT), `CLAUDE.md`, README —
 * under `repo:<Name>:docs`. The checkouts left the vault on 2026-09-06, and from then on nothing
 * re-indexed them: a decision recorded in `docs/plans` was invisible to `ctx_search` until someone
 * indexed it by hand.
 */
function indexRepoDocs(root) {
  const name = root.split(sep).pop();
  if (!CM_CLI) return;
  try {
    execFileSync(
      process.execPath,
      [
        "--bun", CM_CLI, "index", root,
        "--source", `repo:${name}:docs`,
        "--max-depth", "5",
        "--max-files", "300",
        "--ext", ".md",
        ...EXCLUDES.flatMap((e) => ["--exclude", `**/${e}/**`]),
      ],
      { cwd: root, timeout: 600_000, ...QUIET },
    );
  } catch {}
}

/**
 * Record what changed and start a settler if none is running. `vault` and `repos` accumulate
 * across edits inside one debounce window, so a vault edit and a repo edit settle together.
 */
function schedule({ vault = false, repo = null }) {
  const prev = read();
  const lockLive = prev?.lock && Date.now() - prev.lock < LOCK_STALE_MS;
  const repos = [...new Set([...(prev?.repos ?? []), ...(repo ? [repo] : [])])];
  // Always refresh `at` so a live settler extends its wait instead of firing early.
  write({
    at: Date.now(),
    lock: lockLive ? prev.lock : Date.now(),
    // A stamp from before this field existed meant "the vault changed".
    vault: vault || (prev ? prev.vault !== false : false),
    repos,
  });
  if (!lockLive) {
    const c = spawn(process.execPath, ["--bun", join(HOOKS, "brain-reindex.mjs"), "--settle"], {
      detached: true,
      ...QUIET,
    });
    c.unref();
  }
}

/**
 * `<DEV_ROOT>/<Repo>/…` → `<DEV_ROOT>/<Repo>`, or null outside DEV_ROOT. On Windows `path`
 * arrives lower-cased by `normDir`, so the name is looked up on disk for its real casing:
 * `theatlas` and `TheAtlas` are one directory to Windows and two different projects to the
 * source label (Conventions § Renaming).
 */
function repoRoot(path) {
  const base = normDir(DEV_ROOT) + sep;
  if (!path.startsWith(base)) return null;
  const folded = path.slice(base.length).split(sep)[0];
  if (!folded) return null;
  try {
    const name = readdirSync(DEV_ROOT).find((n) => normDir(n) === folded);
    return name ? join(DEV_ROOT, name) : null;
  } catch {
    return null;
  }
}

if (process.argv.includes("--settle")) {
  // Trailing debounce: keep waiting while edits are still arriving, then run once.
  (async () => {
    try {
      for (;;) {
        const s = read();
        if (!s) break; // cleared by someone else; nothing to do
        const quiet = Date.now() - (s.at || 0);
        if (quiet < DEBOUNCE_MS) {
          await sleep(DEBOUNCE_MS - quiet);
          continue; // re-check: more edits may have landed while sleeping
        }
        // Repo docs first: cheap, and the reason this hook fires most days now.
        for (const repo of s.repos ?? []) indexRepoDocs(repo);
        if (s.vault === false) break; // only repo docs changed; the vault indexes are current
        try {
          execFileSync("graphify", ["update", "."], { cwd: VAULT, timeout: 600_000, ...QUIET });
        } catch {}
        // Re-merge whatever repo graphs exist under C:\dev\ into merged-graph.json, which is what
        // .mcp.json actually serves. Without this the vault half is rebuilt on every edit while
        // the served graph stays at whenever someone last ran merge-graphs by hand.
        // Repo graphs are built on demand, so a repo with no graphify-out yet is simply absent
        // from the merge - never an error.
        try {
          const repoGraphs = readdirSync(DEV_ROOT, { withFileTypes: true })
            .filter((e) => e.isDirectory())
            .map((e) => join(DEV_ROOT, e.name, "graphify-out", "graph.json"))
            .filter((p) => existsSync(p));
          if (repoGraphs.length) {
            execFileSync(
              "graphify",
              [
                "merge-graphs",
                join(VAULT, "graphify-out", "graph.json"),
                ...repoGraphs,
                "--out",
                join(VAULT, "graphify-out", "merged-graph.json"),
              ],
              { cwd: VAULT, timeout: 600_000, ...QUIET },
            );
          }
        } catch {}
        try {
          execFileSync(
            process.execPath,
            [
              "--bun", CM_CLI, "index", VAULT,
              "--source", "brain-vault",
              "--max-depth", "4",
              // Per-commit notes (Stage 01) add 100+ files a month; at 500 the index would silently
              // truncate within two months. brain-doctor's `unindexed` count is the tripwire.
              "--max-files", "20000",
              "--ext", ".md",
              ...EXCLUDES.flatMap((e) => ["--exclude", `**/${e}/**`]),
            ],
            { cwd: VAULT, timeout: 600_000, ...QUIET },
          );
        } catch {}
        break;
      }
    } catch {}
    clear(); // release the lock so the next edit can schedule again
    process.exit(0);
  })();
} else {
  try {
    // `--repo <root>`: brain-commit's entry, for markdown committed by any means — an edit made
    // through a shell script never reaches the Edit|Write matcher.
    const flag = process.argv.indexOf("--repo");
    if (flag !== -1) {
      const root = process.argv[flag + 1];
      if (root && repoRoot(normDir(root))) schedule({ repo: repoRoot(normDir(root)) });
      process.exit(0);
    }

    // `--vault`: brain-compile's entry. The compiler writes through a guard()ed `claude -p`, so
    // its Writes never reach this hook's PostToolUse matcher - the vault's largest writer was
    // invisible to reindexing by construction (F2). It now schedules the reindex itself.
    if (process.argv.includes("--vault")) {
      schedule({ vault: true });
      process.exit(0);
    }

    const input = readStdin();
    const path = normDir(input.tool_input?.file_path || "");
    if (!path) process.exit(0);
    if (EXCLUDES.some((e) => path.includes(`${sep}${e}${sep}`))) process.exit(0);

    if (path.startsWith(normDir(VAULT))) schedule({ vault: true });
    else if (path.endsWith(".md") && repoRoot(path)) schedule({ repo: repoRoot(path) });
  } catch {}
  process.exit(0);
}

// brain-reindex.mjs - PostToolUse(Edit|Write). Trailing-debounce rebuild of both indexes.
// Runtime is bun (`bun --bun`), per 00-Brain/Hard-Rules.
// Spec: C:\obsidian\root\40-Plans\2026-08-22-brain-memory-compiler.md
import { readFileSync, writeFileSync, unlinkSync, existsSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { spawn, execFileSync } from "node:child_process";
import { readStdin, normDir, VAULT, HOOKS } from "./brain-lib.mjs";

const STAMP = join(tmpdir(), "brain-reindex.json");
const DEBOUNCE_MS = 90_000;
const LOCK_STALE_MS = 15 * 60_000; // a settler that died leaves a lock; expire it
const EXCLUDES = ["node_modules", "out", "target", ".git", "graphify-out"];
// context-mode is NOT on PATH - it ships as a plugin bundle. Invoke it through the runtime.
const CM_CLI =
  "C:\\Users\\atlasfirarda\\.claude\\plugins\\cache\\context-mode\\context-mode\\1.0.169\\cli.bundle.mjs";
// Checkouts left the vault on 2026-09-06 - see [[0012-repos-leave-the-vault-index-stays]].
const DEV_ROOT = "C:\\dev";

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
              "--max-files", "500",
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
    const input = readStdin();
    const path = normDir(input.tool_input?.file_path || "");
    if (!path || !path.startsWith(normDir(VAULT))) process.exit(0);
    if (EXCLUDES.some((e) => path.includes(`\\${e}\\`))) process.exit(0);

    const prev = read();
    const lockLive = prev?.lock && Date.now() - prev.lock < LOCK_STALE_MS;
    // Always refresh `at` so a live settler extends its wait instead of firing early.
    write({ at: Date.now(), lock: lockLive ? prev.lock : Date.now() });

    if (!lockLive) {
      const c = spawn(
        process.execPath,
        ["--bun", join(HOOKS, "brain-reindex.mjs"), "--settle"],
        { detached: true, ...QUIET },
      );
      c.unref();
    }
  } catch {}
  process.exit(0);
}

// skeleton-config.mjs - the one place the hooks learn about this machine. Runtime: bun --bun.
// Plan: [[2026-11-01-knowledge-skeleton]] Stage 1 (D4).
//
//   import { CONFIG, FOLDERS } from "./skeleton-config.mjs"
//   bun --bun skeleton-config.mjs           print the resolved config as JSON
//   bun --bun skeleton-config.mjs <key>     print one value (vault, devRoot, os, ...) - for commands and scripts
//
// Read from, in order:
//   1. $KNOWLEDGE_CONFIG, if set (a temp HOME for an install test, a second vault)
//   2. %APPDATA%\knowledge\config.json on Windows, $XDG_CONFIG_HOME/knowledge/config.json
//      (default ~/.config/knowledge/config.json) elsewhere. Untracked, written by the installer.
//   3. brain-paths.mjs beside this file - the per-branch file this replaces; kept until every
//      machine has a config.json.
//
// A missing or invalid config throws at MODULE LOAD, on purpose: every hook imports this through
// brain-lib, and a hook that cannot find the vault has nothing useful to do silently.
import { readFileSync, existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { homedir } from "node:os";
import { fileURLToPath } from "node:url";

/** The vault layout. The template ships these folders; every hook names them through here. */
export const FOLDERS = Object.freeze({
  meta: "00-Meta",
  repos: "10-Repos",
  knowledge: "20-Knowledge",
  sessions: "30-Sessions",
  plans: "40-Plans",
  ops: "50-Ops",
  decisions: "60-Decisions",
  assets: "80-Assets",
  inbox: "90-Inbox",
});

const IS_WINDOWS = process.platform === "win32";

export const CONFIG_PATH =
  process.env.KNOWLEDGE_CONFIG ||
  (IS_WINDOWS
    ? join(process.env.APPDATA || join(homedir(), "AppData", "Roaming"), "knowledge", "config.json")
    : join(process.env.XDG_CONFIG_HOME || join(homedir(), ".config"), "knowledge", "config.json"));

/** `arch` / `windows` / the platform name: what records are stamped with when config names no OS. */
const detectedOs = () => (IS_WINDOWS ? "windows" : process.platform === "linux" ? "arch" : process.platform);

async function load() {
  if (existsSync(CONFIG_PATH)) {
    let raw;
    try {
      raw = JSON.parse(readFileSync(CONFIG_PATH, "utf8"));
    } catch (e) {
      throw new Error(`knowledge config ${CONFIG_PATH} is not valid JSON: ${e.message}`);
    }
    return { ...raw, source: CONFIG_PATH };
  }
  const legacy = join(dirname(fileURLToPath(import.meta.url)), "brain-paths.mjs");
  if (existsSync(legacy)) {
    const { VAULT, DEV_ROOT } = await import(legacy);
    return { vault: VAULT, devRoot: DEV_ROOT, source: legacy };
  }
  throw new Error(`no knowledge config: write ${CONFIG_PATH} ({"vault": "...", "devRoot": "..."}) - see INSTALL.md`);
}

const raw = await load();
for (const k of ["vault", "devRoot"])
  if (typeof raw[k] !== "string" || !raw[k]) throw new Error(`knowledge config ${raw.source}: "${k}" must be a non-empty path`);
const hour = raw.rolloverHour ?? 5;
if (!Number.isInteger(hour) || hour < 0 || hour > 23)
  throw new Error(`knowledge config ${raw.source}: "rolloverHour" must be an integer 0-23`);

/**
 * vault, devRoot - absolute paths. os - the label stamped on records. machine - free text the
 * SessionStart banner opens with (hardware, dual-boot, dotfiles). rolloverHour - when a daily note
 * starts, local time: a session at 02:00 belongs to the previous day with the default 5.
 */
export const CONFIG = Object.freeze({
  vault: raw.vault,
  devRoot: raw.devRoot,
  os: typeof raw.os === "string" && raw.os ? raw.os : detectedOs(),
  machine: typeof raw.machine === "string" ? raw.machine : "",
  rolloverHour: hour,
  source: raw.source,
});

if (import.meta.main) {
  const key = process.argv[2];
  if (!key) process.stdout.write(`${JSON.stringify(CONFIG, null, 2)}\n`);
  else if (key in CONFIG) process.stdout.write(`${CONFIG[key]}\n`);
  else if (key in FOLDERS) process.stdout.write(`${FOLDERS[key]}\n`);
  else {
    process.stderr.write(`unknown key "${key}": ${[...Object.keys(CONFIG), ...Object.keys(FOLDERS)].join(", ")}\n`);
    process.exit(1);
  }
}

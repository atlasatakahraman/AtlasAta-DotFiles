// brain-verify.mjs - referential integrity of the vault. Two checks, one command:
//   1. every [[wikilink]] resolves to a real note
//   2. every checkout:/docs: pointer in 10-Repos/*.md exists on disk
//
// Runtime is bun (`bun --bun`), per 00-Meta/Hard-Rules. Exits 1 if anything is broken, so it
// can gate a script; prints nothing but the verdict when clean.
//
// Written 2026-09-06 after getting both checks WRONG twice as throwaway shell one-liners in a
// single /brain-sync run - once from case-sensitivity, once from shell escaping mangling a regex
// so it silently skipped three files and reported a confident wrong number. A wrong-but-plausible
// answer is worse than an error, and re-deriving a check each run is how you get one.
import { readdirSync, readFileSync, existsSync } from "node:fs";
import { join, basename, relative } from "node:path";
import { VAULT } from "./brain-lib.mjs";

const SKIP = new Set(["graphify-out", ".obsidian", ".remember", ".git", "node_modules"]);
// 80-Assets holds attachments and verbatim COPIES of repo files. They are valid link TARGETS but
// are not vault notes, so their own links are not the vault's problem.
const isVaultNote = (p) => !p.includes(`${"\\"}80-Assets${"\\"}`);

const allMd = [];
(function walk(d) {
  let entries;
  try {
    entries = readdirSync(d, { withFileTypes: true });
  } catch {
    return;
  }
  for (const e of entries) {
    if (SKIP.has(e.name)) continue;
    const p = join(d, e.name);
    if (e.isDirectory()) walk(p);
    else if (e.name.endsWith(".md")) allMd.push(p);
  }
})(VAULT);

// Windows is case-insensitive and so is Obsidian's resolution here: [[TheAtlas-Media]] finds
// theatlas-media.md. A case-sensitive check reports false breaks.
const lc = (s) => String(s).toLowerCase();
const byName = new Set(allMd.map((p) => lc(basename(p, ".md"))));
const byPath = new Set(
  allMd.map((p) => lc(relative(VAULT, p).replace(/\\/g, "/").replace(/\.md$/, ""))),
);

// Obsidian resolves frontmatter `aliases:` as link targets too. Without this the checker reports
// a false break on any link written to an alias - which is the whole point of having them.
// Both YAML forms: `aliases: [A, B]` and a `-` list.
for (const p of allMd) {
  const fm = (readFileSync(p, "utf8").match(/^---\r?\n([\s\S]*?)\r?\n---/) || [])[1];
  if (!fm) continue;
  const inline = fm.match(/^aliases:\s*\[(.*?)\]\s*$/m);
  if (inline) {
    for (const a of inline[1].split(",")) if (a.trim()) byName.add(lc(a.trim().replace(/^["']|["']$/g, "")));
    continue;
  }
  const block = fm.match(/^aliases:\s*\r?\n((?:\s*-\s+.+\r?\n?)+)/m);
  if (block) {
    for (const line of block[1].split(/\r?\n/)) {
      const a = line.match(/^\s*-\s+(.+)$/);
      if (a) byName.add(lc(a[1].trim().replace(/^["']|["']$/g, "")));
    }
  }
}

// Strip fenced and inline code BEFORE scanning: bash `[[ ... ]]` conditionals are identical to
// wikilinks and used to produce ~50 phantom failures from the dotfiles tree.
const strip = (t) => t.replace(/```[\s\S]*?```/g, "").replace(/`[^`\n]*`/g, "");

/**
 * The deliberate-dangling allowlist lives in the VAULT, not in this script - 20-Knowledge's
 * "Known gaps" section. The vault owns the policy; this file only enforces it. Those entries sit
 * inside inline code, so they are read from the raw text, before stripping.
 */
function knownDangling() {
  const out = new Set();
  for (const f of allMd.filter((p) => basename(p).startsWith("00-MOC-"))) {
    const t = readFileSync(f, "utf8");
    const sec = t.split(/^##+\s*Known gaps.*$/im)[1];
    if (!sec) continue;
    const block = sec.split(/^##/m)[0];
    for (const x of block.matchAll(/\[\[([^\]|#]+)/g)) {
      out.add(lc(basename(x[1].trim())));
    }
  }
  return out;
}

const KNOWN = knownDangling();

let links = 0;
let known = 0;
const broken = [];
for (const f of allMd.filter(isVaultNote)) {
  const body = strip(readFileSync(f, "utf8"));
  for (const m of body.matchAll(/\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|[^\]]*)?\]\]/g)) {
    const target = m[1].trim();
    if (!target) continue;
    links++;
    if (byName.has(lc(basename(target))) || byPath.has(lc(target.replace(/\.md$/, "")))) continue;
    if (KNOWN.has(lc(basename(target)))) {
      known++;
      continue;
    }
    broken.push(`${relative(VAULT, f).replace(/\\/g, "/")}  ->  [[${target}]]`);
  }
}

let ptrs = 0;
const dead = [];
const REPOS = join(VAULT, "10-Repos");
for (const f of (() => {
  try {
    return readdirSync(REPOS).filter((x) => x.endsWith(".md"));
  } catch {
    return [];
  }
})()) {
  const t = readFileSync(join(REPOS, f), "utf8");
  const fm = (t.match(/^---\r?\n([\s\S]*?)\r?\n---/) || [])[1];
  if (!fm) continue;
  let inList = false;
  for (const line of fm.split(/\r?\n/)) {
    const kv = line.match(/^(checkout|docs):\s*(.*)$/);
    if (kv) {
      inList = kv[2].trim() === "";
      if (kv[2].trim()) {
        ptrs++;
        if (!existsSync(kv[2].trim())) dead.push(`${f}  ${kv[1]}  ${kv[2].trim()}`);
      }
      continue;
    }
    const item = line.match(/^\s*-\s+(.+)$/);
    if (inList && item) {
      ptrs++;
      if (!existsSync(item[1].trim())) dead.push(`${f}  checkout  ${item[1].trim()}`);
      continue;
    }
    if (line.trim() && !/^\s/.test(line)) inList = false;
  }
}

console.log(`notes ${allMd.filter(isVaultNote).length} · links ${links} · pointers ${ptrs}`);
console.log(`known-dangling (allowlisted in a MOC's "Known gaps"): ${known}`);

if (!broken.length && !dead.length) {
  console.log("OK - every link resolves, every pointer exists");
  process.exit(0);
}
if (broken.length) {
  console.log(`\nBROKEN LINKS (${broken.length}):`);
  broken.forEach((b) => console.log("  " + b));
}
if (dead.length) {
  console.log(`\nDEAD POINTERS (${dead.length}):`);
  dead.forEach((d) => console.log("  " + d));
}
process.exit(1);

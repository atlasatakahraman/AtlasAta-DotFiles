// brain-prune.mjs - drop context-mode index entries whose source file no longer exists.
// Runtime is bun (`bun --bun`), per 00-Brain/Hard-Rules.
//
// Why this exists: `context-mode index` is ADDITIVE. Re-indexing never removes entries for files
// that have been deleted or renamed, so every note the compiler retires stays searchable forever
// and keeps being injected into prompts by brain-inject. Found 2026-09-06: 14 phantom sources,
// including 8 ADRs deleted hours earlier and one renamed weeks before that.
//
// This is NOT the `/brain-lint` "never retrieved in 90 days" idea, which reports and never
// deletes because that heuristic can discard useful notes. Here the file is already gone from
// disk - the index entry is a lie with no information value, and removing it cannot lose
// knowledge. Different case, different rule.
//
// Reports by default. Pass --apply to actually delete.
import { Database } from "bun:sqlite";
import { readdirSync, existsSync, copyFileSync } from "node:fs";
import { join } from "node:path";
import { homedir, tmpdir } from "node:os";

const CONTENT = join(homedir(), ".claude", "context-mode", "content");
const apply = process.argv.includes("--apply");

// A file-backed source's label ends with an absolute Windows path:
//   brain-vault:C:\obsidian\root\00-Brain\Identity.md
//   repo:TheAtlas:C:\dev\TheAtlas\apps\core\page.tsx
// Web sources use `name::https://...` and command captures use `batch:...` - neither has one,
// and neither must ever be pruned.
const filePath = (label) => (String(label).match(/([A-Za-z]:\\.+)$/) || [])[1] ?? null;

let dbs = [];
try {
  dbs = readdirSync(CONTENT).filter((f) => f.endsWith(".db"));
} catch {
  console.log("no content directory - nothing to prune");
  process.exit(0);
}

let totalDead = 0;
let totalChunks = 0;
let errors = 0;

for (const f of dbs) {
  const path = join(CONTENT, f);
  let db;
  try {
    // bun:sqlite: `{ readonly: false }` is NOT the same as omitting the option - it throws
    // SQLITE_MISUSE ("bad parameter or other API misuse") on the first prepare(). Omit it to
    // open read-write.
    db = apply ? new Database(path) : new Database(path, { readonly: true });
    if (!db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='sources'").get()) {
      db.close();
      continue;
    }

    const dead = [];
    for (const r of db.prepare("SELECT id, label FROM sources").all()) {
      const p = filePath(r.label);
      if (p && !existsSync(p)) dead.push(r);
    }
    if (!dead.length) {
      db.close();
      continue;
    }

    totalDead += dead.length;
    console.log(`\n${f}  ${dead.length} phantom source(s)`);
    for (const r of dead.slice(0, 20)) {
      console.log(`   ${String(r.label).split(/[\\/]/).pop()}`);
    }
    if (dead.length > 20) console.log(`   ... and ${dead.length - 20} more`);

    if (apply) {
      // One backup per run, before the first write, so a bad prune is recoverable.
      const bak = join(tmpdir(), `brain-prune-${f}.bak`);
      copyFileSync(path, bak);

      const ids = dead.map((r) => r.id);
      const ph = ids.map(() => "?").join(",");
      db.exec("BEGIN");
      const a = db.prepare(`DELETE FROM chunks WHERE source_id IN (${ph})`).run(...ids);
      // The trigram mirror is a second FTS table over the same rows - both or neither.
      let b = { changes: 0 };
      try {
        b = db.prepare(`DELETE FROM chunks_trigram WHERE source_id IN (${ph})`).run(...ids);
      } catch {
        /* older DBs have no trigram table */
      }
      db.prepare(`DELETE FROM sources WHERE id IN (${ph})`).run(...ids);
      db.exec("COMMIT");
      totalChunks += a.changes;

      const ok = db.prepare("PRAGMA integrity_check").get();
      const verdict = Object.values(ok)[0];
      console.log(`   pruned ${a.changes} chunks / ${b.changes} trigram - integrity: ${verdict}`);
      if (verdict !== "ok") console.log(`   !! restore from ${bak}`);
      else console.log(`   backup: ${bak}`);
    }
    db.close();
  } catch (e) {
    errors++;
    console.log(`   ERROR ${f}: ${e.message.slice(0, 90)}`);
    try {
      db?.close();
    } catch {}
  }
}

// An error is not "clean". Saying so is the failure mode this whole hook family keeps hitting.
if (errors) {
  console.log(`\n${errors} database(s) FAILED - results above are incomplete, nothing is proven`);
  process.exit(1);
}

if (!totalDead) {
  console.log("clean - every indexed source still exists on disk");
} else if (apply) {
  console.log(`\nremoved ${totalDead} phantom source(s), ${totalChunks} chunk(s)`);
} else {
  console.log(`\n${totalDead} phantom source(s) found. Re-run with --apply to remove them.`);
}
process.exit(0);

// brain-inject.mjs - UserPromptSubmit. Injects relevant vault memory. Fails silent, always.
// Spec: C:\obsidian\root\40-Plans\2026-08-22-brain-memory-compiler.md
import { readStdin, contentDbs, ftsMatch, openDb, VAULT } from "./brain-lib.mjs";

const CAP = 1200; // hard char cap - FTS5 ignores any budget we ask for
const FLOOR = -6; // bm25 is negative; lower is better. Real hits measured -7.5..-11.6
const BUDGET_MS = 50;

const SQL = `SELECT s.label AS label, snippet(chunks,1,'','','…',26) AS snip, bm25(chunks) AS rank
             FROM chunks JOIN sources s ON s.id = chunks.source_id
             WHERE chunks MATCH ? ORDER BY rank LIMIT 6`;

try {
  const started = Date.now();
  const { prompt } = readStdin();
  const match = ftsMatch(prompt);
  if (!match) process.exit(0);

  const hits = [];
  for (const file of contentDbs()) {
    if (Date.now() - started > BUDGET_MS) break;
    let db;
    try {
      db = openDb(file);
      for (const r of db.prepare(SQL).all(match)) {
        if (r.rank < FLOOR) hits.push(r);
      }
    } catch {
      /* a corrupt or busy DB must never break the prompt */
    } finally {
      try {
        db?.close();
      } catch {}
    }
  }
  if (!hits.length) process.exit(0);

  hits.sort((a, b) => a.rank - b.rank);
  const seen = new Set();
  let out = "";
  let used = 0;
  for (const h of hits) {
    const name = String(h.label).replace(/^brain-vault:/, "").split(/[\\/]/).pop();
    if (seen.has(name)) continue; // one line per source note
    seen.add(name);
    const line = `- **${name}** — ${String(h.snip).replace(/\s+/g, " ").trim()}\n`;
    if (used + line.length > CAP) break;
    out += line;
    used += line.length;
  }
  if (!out) process.exit(0);

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "UserPromptSubmit",
        additionalContext:
          `Relevant memory from the brain (${VAULT}):\n${out}\n` +
          `Query the vault before answering from scratch.`,
      },
    }),
  );
} catch {
  /* never break a prompt */
}
process.exit(0);

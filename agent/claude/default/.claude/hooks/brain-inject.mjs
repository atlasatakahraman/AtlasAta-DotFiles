// brain-inject.mjs - UserPromptSubmit. Injects relevant vault notes. Fails silent, always.
// Spec: C:\obsidian\root\40-Plans\2026-08-22-brain-memory-compiler\2026-08-22-brain-memory-compiler.md
//
// SCOPED TO THE VAULT, 2026-09-21. It used to walk every context-mode content DB under a 50ms
// budget. Measured that day: 12 DBs at 7-9ms per open, ~90ms total - the budget stopped it at
// the 6th, and the vault's DB sorts 9th, so it NEVER reached the vault. Roughly twenty injections
// in one session were headed "Relevant memory from the brain" and held only repo source and
// stray agent-memory files (AppView.tsx, store.ts, MEMORY.md, build.rs) - zero vault notes, and
// ~330 tokens per prompt of misleading context. The query now lives in brain-lib's vaultSearch(),
// shared with brain-doctor so the regression test exercises this exact path.
// Evidence: C:\obsidian\root\40-Plans\2026-09-20-vault-governance-overhaul\evidence\2026-09-21-retrieval-audit.md
import { basename } from "node:path";
import { readStdin, ftsMatch, vaultSearch, VAULT } from "./brain-lib.mjs";

const CAP = 1200; // hard char cap - FTS5 ignores any budget we ask for
const FLOOR = -6; // bm25 is negative; lower is better. Real hits measured -7.5..-11.6

try {
  const { prompt } = readStdin();
  const match = ftsMatch(prompt);
  if (!match) process.exit(0);

  const { rows } = vaultSearch(match);
  if (!rows.length) process.exit(0);

  const seen = new Set();
  let out = "";
  let used = 0;
  for (const h of rows) {
    if (h.rank >= FLOOR) continue;
    const name = basename(String(h.path), ".md");
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
          `Relevant notes from the knowledge vault (${VAULT}):\n${out}\n` +
          `These are vault notes only. A snippet is not the note — follow the name into the file.`,
      },
    }),
  );
} catch {
  /* never break a prompt */
}
process.exit(0);

// brain-ledger.mjs - read and update the decision ledger. The brain skill calls this; nothing
// hand-edits 50-Ops/decisions.jsonl.
// Plan: C:\obsidian\root\40-Plans\2026-09-20-vault-governance-overhaul\stages\vault-governance-07-decision-capture.md
//
//   list                                                        unpromoted entries
//   add --tier 1 --question "<q>" --answer "<a>" [--promoted <path>]
//   promote <src> <vault-relative-ADR-path | not-a-decision>
import { ledgerRead, ledgerAdd, ledgerSet } from "./brain-lib.mjs";

const [, , cmd, ...rest] = process.argv;
const opt = (k) => {
  const i = rest.indexOf(k);
  return i !== -1 ? rest[i + 1] : null;
};

if (cmd === "list") {
  const open = ledgerRead().filter((e) => e.promoted === null);
  for (const e of open)
    console.log(`${e.src}\n  Q: ${e.question}\n  A: ${e.answer}${e.note ? `\n  note: ${e.note}` : ""}${e.options?.length ? `\n  offered: ${e.options.join(" · ")}` : ""}\n`);
  console.log(`${open.length} unpromoted`);
} else if (cmd === "add") {
  const n = ledgerAdd([{ tier: Number(opt("--tier") || 1), sid: null, src: `manual:${Date.now()}`, question: opt("--question") || "", answer: opt("--answer") || "", promoted: opt("--promoted") }]);
  console.log(n ? "added" : "not added");
} else if (cmd === "promote") {
  console.log(ledgerSet(rest[0], { promoted: rest[1] }) ? "updated" : `no entry with src ${rest[0]}`);
} else {
  console.log("usage: brain-ledger.mjs list | add --tier 1 --question <q> --answer <a> [--promoted <path>] | promote <src> <path|not-a-decision>");
}

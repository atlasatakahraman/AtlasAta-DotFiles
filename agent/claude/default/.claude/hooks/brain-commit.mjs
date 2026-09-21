// brain-commit.mjs - one vault note per commit, in every repo, with its why. Runtime: bun --bun.
// Plan: C:\obsidian\root\40-Plans\2026-09-20-vault-governance-overhaul\stages\vault-governance-01-commit-recording.md
//
//   (PostToolUse Bash hook)      record commits from the last 3 days that have no note yet
//   --backfill YYYY-MM-DD        the same, since that date. Idempotent: safe to re-run.
//   --dry-run                    print what would be written; write nothing
//
// Detection is STATELESS and does not parse the command beyond a loose prefilter. v1 parsed the
// command and trusted the session cwd: on 2026-09-21 it recorded 0 of 10 commits (a command that
// also ran `git log` was treated as not-a-commit) and recorded the WRONG repo's HEAD for
// `cd <repo> && git commit`. Now the notes themselves are the state: scan every repo's recent log
// and record whatever has no note. How, or from where, the commit was made no longer matters.
import { readFileSync, writeFileSync, existsSync, mkdirSync, readdirSync } from "node:fs";
import { join, basename } from "node:path";
import { execFileSync } from "node:child_process";
import { readStdin, logicalDate, VAULT, DEV_ROOT, HOOKS } from "./brain-lib.mjs";

const dry = process.argv.includes("--dry-run");
const bfAt = process.argv.indexOf("--backfill");
const backfill = bfAt !== -1 ? process.argv[bfAt + 1] : null;
const ROOT = join(VAULT, "50-Ops", "Commits");
const US = "\x1f"; // field separator in git --format output
const RS = "\x1e"; // record separator

const git = (cwd, ...a) =>
  execFileSync("git", a, { cwd, encoding: "utf8", windowsHide: true, stdio: ["ignore", "pipe", "ignore"] });
const pad = (n) => String(n).padStart(2, "0");

/** The vault + every checkout under DEV_ROOT, each named for its GitHub remote (Conventions). */
function repoList() {
  const roots = [VAULT];
  try {
    for (const e of readdirSync(DEV_ROOT, { withFileTypes: true }))
      if (e.isDirectory() && existsSync(join(DEV_ROOT, e.name, ".git"))) roots.push(join(DEV_ROOT, e.name));
  } catch {}
  return roots.map((root) => {
    let name = basename(root);
    try {
      name = git(root, "remote", "get-url", "origin").trim().replace(/\.git$/, "").split(/[/:]/).pop() || name;
    } catch {}
    return { root, name };
  });
}

/** Non-merge commits in one repo since `since`, oldest first. The full hash is the identity. */
function recentCommits({ root, name }, since) {
  let out = "";
  try {
    out = git(root, "log", `--since=${since}`, "--no-merges", "--reverse", `--format=%H${US}%cI${US}%s${US}%b${RS}`);
  } catch {
    return [];
  }
  return out
    .split(RS)
    .map((r) => r.replace(/^\s+/, ""))
    .filter(Boolean)
    .map((r) => {
      const [hash, iso, subject, body = ""] = r.split(US);
      return { root, name, hash, iso, subject: subject || "(no subject)", body: body.trim() };
    })
    .filter((c) => /^[0-9a-f]{40}$/.test(c.hash));
}

/** What is already recorded, read from the notes: full hashes, and each day's highest ordinal. */
function recorded() {
  const hashes = new Set();
  const maxOrdinal = new Map(); // "YYYY-MM-DD" -> N
  if (!existsSync(ROOT)) return { hashes, maxOrdinal };
  for (const m of readdirSync(ROOT, { withFileTypes: true })) {
    if (!m.isDirectory() || !/^\d{4}-\d{2}$/.test(m.name)) continue;
    for (const f of readdirSync(join(ROOT, m.name))) {
      const hit = /^(\d{2})-x(\d+)-.+\.md$/.exec(f);
      if (!hit) continue;
      const day = `${m.name}-${hit[1]}`;
      maxOrdinal.set(day, Math.max(maxOrdinal.get(day) ?? 0, Number(hit[2])));
      const h = /^hash:\s*([0-9a-f]{40})/m.exec(readFileSync(join(ROOT, m.name, f), "utf8"));
      if (h) hashes.add(h[1]);
    }
  }
  return { hashes, maxOrdinal };
}

/** Logical day (05:00 rollover), matching 30-Sessions/: a 02:00 commit is yesterday's work. */
function dayOf(iso) {
  const d = logicalDate(new Date(iso));
  return { month: `${d.getFullYear()}-${pad(d.getMonth() + 1)}`, dd: pad(d.getDate()) };
}

/** Subject -> filename slug. The conventional-commit prefix is dropped here; the H1 keeps it. */
const slugOf = (s) =>
  s
    .toLowerCase()
    .replace(/^[a-z]+(\([^)]*\))?!?:\s*/, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 48)
    .replace(/-+$/, "") || "commit";

const filesOf = (c) => {
  try {
    return git(c.root, "show", "--name-only", "--format=", c.hash).split("\n").filter(Boolean);
  } catch {
    return [];
  }
};

function noteFor(c, files, month, dd, n) {
  let stat = "";
  try {
    stat = git(c.root, "show", "--shortstat", "--format=", c.hash).replace(/\s+/g, " ").trim();
  } catch {}
  const areas = [...new Set(files.map((f) => (f.includes("/") ? `${f.split("/")[0]}/` : f)))].slice(0, 6).join(" ");
  const day = `${month}-${dd}`;
  const t = new Date(c.iso);
  const why =
    c.body ||
    "_No commit body. Under D5 option A a commit record carries only what its message says — the why belongs in the body._";
  // ponytail: ordinal = highest existing for the day + 1. Correct when commits are recorded in time
  // order, which live use and a first backfill both guarantee. A later backfill of an OLDER day
  // that already has notes would append out of order; renumbering is the upgrade if that happens.
  const file = join(ROOT, month, `${dd}-x${n}-${c.name}-${slugOf(c.subject)}.md`);
  const lower = c.name.toLowerCase();
  const text = [
    "---",
    "type: commit",
    `project: ${lower}`,
    `tags: [commit, ${lower}]`,
    `repo: ${c.name}`,
    `hash: ${c.hash}`,
    `committed: ${c.iso}`,
    `created: ${day}`,
    `updated: ${day}`,
    "status: active",
    "---",
    "",
    `# ${c.subject}`,
    "",
    `\`${c.hash.slice(0, 7)}\` · ${c.name} · ${pad(t.getHours())}:${pad(t.getMinutes())} · session log [[${day}]]`,
    "",
    "## Why",
    "",
    why,
    "",
    "## Change",
    "",
    `${stat || "(no stat)"}${areas ? ` · ${areas}` : ""}`,
    "",
  ].join("\n");
  return { file, text };
}

/** Regenerate the month index from the notes on disk. Deterministic, so it cannot drift from them. */
function writeIndex(month) {
  const dir = join(ROOT, month);
  const rows = readdirSync(dir)
    .filter((f) => /^\d{2}-x\d+-.+\.md$/.test(f))
    .sort((a, b) => a.localeCompare(b, undefined, { numeric: true }))
    .map((f) => {
      const t = readFileSync(join(dir, f), "utf8");
      const title = (/^# (.+)$/m.exec(t)?.[1] ?? f).replace(/[|\]]/g, "-");
      const repo = /^repo:\s*(.+)$/m.exec(t)?.[1]?.trim() ?? "";
      return { dd: f.slice(0, 2), link: `- [[${f.slice(0, -3)}|${repo} · ${title}]]` };
    });
  const out = [
    "---",
    "type: commits",
    "project: knowledge",
    "tags: [commits, git, ops, index]",
    `created: ${month}-01`,
    `updated: ${new Date().toISOString().slice(0, 10)}`,
    "status: active",
    "---",
    "",
    `# Commits — ${month}`,
    "",
    `One note per commit, generated by \`brain-commit\` — ${rows.length} commits. Rewritten on every record; do not edit by hand.`,
  ];
  let last = "";
  for (const r of rows) {
    if (r.dd !== last) {
      out.push("", `## ${month}-${r.dd}`, "");
      last = r.dd;
    }
    out.push(r.link);
  }
  writeFileSync(join(ROOT, `commits-${month}.md`), `${out.join("\n")}\n`, "utf8");
}

try {
  if (!backfill) {
    // Loose prefilter only: could this Bash command have made a commit? A false positive costs one
    // scan that finds nothing new. A false negative is the only failure that matters, so no
    // exclusions — v1's `git log` exclusion is exactly what dropped all ten commits.
    if (!/\bcommit\b/.test(String(readStdin().tool_input?.command || ""))) process.exit(0);
  }

  const { hashes, maxOrdinal } = recorded();
  const fresh = repoList()
    .flatMap((r) => recentCommits(r, backfill || "3.days.ago"))
    .filter((c) => !hashes.has(c.hash))
    .sort((a, b) => Date.parse(a.iso) - Date.parse(b.iso));

  const months = new Set();
  const mdRepos = new Set();
  let written = 0;
  for (const c of fresh) {
    const files = filesOf(c);
    // A commit that only adds commit records would record itself forever, one trailing note per
    // commit of the notes. Skip it — its content IS the record.
    if (c.root === VAULT && files.length && files.every((f) => f.startsWith("50-Ops/Commits/"))) continue;

    const { month, dd } = dayOf(c.iso);
    const key = `${month}-${dd}`;
    const n = (maxOrdinal.get(key) ?? 0) + 1;
    maxOrdinal.set(key, n);
    const { file, text } = noteFor(c, files, month, dd, n);
    written++;
    if (dry) {
      process.stdout.write(`[dry-run] ${file.slice(VAULT.length + 1)}\n`);
      continue;
    }
    mkdirSync(join(ROOT, month), { recursive: true });
    writeFileSync(file, text, "utf8");
    months.add(month);
    if (c.root !== VAULT && files.some((f) => f.endsWith(".md"))) mdRepos.add(c.root);
  }

  if (dry) {
    process.stdout.write(`[dry-run] ${written} new commit notes\n`);
    process.exit(0);
  }
  for (const m of months) writeIndex(m);

  // These notes are written by this script, not by the Edit/Write tools, so brain-reindex's
  // PostToolUse matcher never sees them — the same blind spot F2 fixed for the compiler.
  // Sequential, not spawned in parallel: two `schedule()` calls racing on the reindex state file
  // can drop one of them.
  if (written) {
    const reindex = (...a) => {
      try {
        execFileSync(process.execPath, ["--bun", join(HOOKS, "brain-reindex.mjs"), ...a], { stdio: "ignore", windowsHide: true, timeout: 10_000 });
      } catch {}
    };
    reindex("--vault");
    for (const r of mdRepos) reindex("--repo", r);
  }
} catch {
  /* a logging hook must never break a session */
}
process.exit(0);

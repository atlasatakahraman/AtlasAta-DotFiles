// brain-commit.mjs - PostToolUse(Bash). Records every commit in 50-Ops/Commits/YYYY-MM.md.
// Runtime is bun (`bun --bun`), per 00-Meta/Hard-Rules.
//
// Zero tokens: the subject says what the commit does, the touched top-level dirs and the
// shortstat say how much. `/brain-commits` still owns the full monthly digest and the count line.
import { readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { join, dirname, basename } from "node:path";
import { execFileSync, spawn } from "node:child_process";
import { readStdin, VAULT, HOOKS } from "./brain-lib.mjs";

const dry = process.argv.includes("--dry-run");

/** A `git ... commit` in the command, not `git log`, and not a rehearsal. */
const isCommit = (cmd) =>
  /(^|[\s;&|(])git\b[^;&|]*\bcommit\b/.test(cmd) && !/--dry-run|\bgit\s+log\b/.test(cmd);

const digestPath = (cs) => join(VAULT, "50-Ops", "Commits", `${cs.slice(0, 7)}.md`);

function ensureDigest(file, cs) {
  if (existsSync(file)) return;
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(
    file,
    `---\ntype: commits\nproject: knowledge\ntags: [commits, git, ops]\n` +
      `created: ${cs}\nupdated: ${cs}\nstatus: active\n---\n\n` +
      `# Commits — ${cs.slice(0, 7)}\n\nAuto-recorded per commit by \`brain-commit\`. ` +
      `Full digest via \`/brain-commits\`.\n`,
    "utf8",
  );
}

/** Insert the bullet at the END of this repo's section, so the file stays grouped by repo. */
function insert(body, repo, bullet) {
  const lines = body.split("\n");
  const head = lines.findIndex((l) => l.trim() === `## ${repo}`);
  if (head === -1) return `${body.replace(/\n+$/, "")}\n\n## ${repo}\n\n${bullet}\n`;
  let end = lines.length;
  for (let i = head + 1; i < lines.length; i++)
    if (lines[i].startsWith("## ")) {
      end = i;
      break;
    }
  while (end > head + 1 && lines[end - 1].trim() === "") end--; // keep the blank line before the next heading
  lines.splice(end, 0, bullet);
  return lines.join("\n");
}

try {
  const input = readStdin();
  if (!isCommit(String(input.tool_input?.command || ""))) process.exit(0);

  const cwd = input.cwd || process.cwd();
  const git = (...a) =>
    execFileSync("git", a, { cwd, encoding: "utf8", windowsHide: true }).replace(/\s+$/, "");

  const repo = basename(git("rev-parse", "--show-toplevel"));
  const [hash, cs, subject] = git("log", "-1", "--pretty=%h%n%cs%n%s").split("\n");
  if (!hash || !/^\d{4}-\d{2}-\d{2}$/.test(cs || "")) process.exit(0);

  const file = digestPath(cs);
  const existing = existsSync(file) ? readFileSync(file, "utf8") : "";
  if (existing.includes(`\`${hash}\``)) process.exit(0); // PostToolUse can fire twice

  const stat = git("log", "-1", "--pretty=", "--shortstat")
    .replace(/\s+/g, " ")
    .replace(/(\d+) files? changed/, (_, n) => n + (n === "1" ? " file" : " files"))
    .replace(/(\d+) insertions?\(\+\)/, "+$1")
    .replace(/(\d+) deletions?\(-\)/, "-$1")
    .replace(/, /g, " ")
    .trim();
  const areas = [
    ...new Set(
      git("log", "-1", "--pretty=", "--name-only")
        .split("\n")
        .filter(Boolean)
        .map((f) => (f.includes("/") ? `${f.split("/")[0]}/` : f)),
    ),
  ].slice(0, 4);

  const bullet =
    `- ${cs} \`${hash}\` ${subject}` +
    (stat ? ` — ${stat}` : "") +
    (areas.length ? ` · ${areas.join(" ")}` : "");

  if (dry) {
    process.stdout.write(`[dry-run] ${file}\n${bullet}\n`);
    process.exit(0);
  }
  ensureDigest(file, cs);
  const body = readFileSync(file, "utf8");
  writeFileSync(
    file,
    insert(body, repo, bullet).replace(/^(updated:) .*$/m, `$1 ${cs}`),
    "utf8",
  );

  // Markdown in the commit → re-index that checkout's docs. Covers edits that never went through
  // Edit|Write (scripts, sed), which brain-reindex's own matcher cannot see.
  const touchedMarkdown = git("log", "-1", "--pretty=", "--name-only")
    .split("\n")
    .some((f) => f.endsWith(".md"));
  if (touchedMarkdown) {
    spawn(
      process.execPath,
      ["--bun", join(HOOKS, "brain-reindex.mjs"), "--repo", git("rev-parse", "--show-toplevel")],
      { detached: true, stdio: "ignore", windowsHide: true },
    ).unref();
  }
} catch {
  /* a logging hook must never break a session */
}
process.exit(0);

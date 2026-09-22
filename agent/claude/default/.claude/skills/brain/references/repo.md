# brain: repo

A thin pointer page in `10-Repos/` carrying the completion-gate `status`, or a whole new project.

## new — page for an existing repo

The repo's own `docs/` is its documentation. This page is an **index**, never a copy.

```yaml
---
type: repo
project: <slug>
tags: [...]
aliases: [Other Name]        # if the folder name differs from the project name
created: <today>
updated: <today>
status: in-progress          # completion gate reads this
---
```

Sections that earn their place:
- What it is, and **where the code is** (path, remote, branch, license)
- **Its own docs** — a table pointing into the repo, not restating it
- Stack, compared against the other repos where that comparison is informative
- **Known gaps — don't chase these** ← the highest-value section. Stops re-investigation of
  things already decided against.

Then link from `10-Repos/00-MOC-Repos.md`.

## Always — the asset folder

Every repo gets `80-Assets/Repos/<Repo-Name>/`, named exactly as the `10-Repos/` directory:

```bash
mkdir -p "80-Assets/Repos/<Repo-Name>" && touch "80-Assets/Repos/<Repo-Name>/.gitkeep"
```

Masters only — the `.svg` a logo is drawn in, the source of a README banner, the icon set an
app builds `.ico`/`.icns` from. The **exported** artifact still ships inside the repo, because
GitHub renders a README from the repo's own tree; a vault-hosted logo 404s for everyone else.
Rules in `80-Assets/00-MOC-Assets.md`.

## new — scaffolding an actual project

Read `00-Meta/Hard-Rules.md` first, in full. It governs: bun (`bun --bun`), shadcn +
unified `radix-ui` + Phosphor + `next-themes`, the Wayland guard for any cross-platform Tauri app,
AAKNCL licensing, and **no tests until the completion gate**.

- `main` only. No feature branches.
- `LICENSE.md` = AAKNCL v1.0, copied from `10-Repos/TheAtlas-Media/LICENSE.md`
- `package.json` → `"license": "SEE LICENSE IN LICENSE.md"`
- `CLAUDE.md` following TheAtlas-Media's section layout (see `00-Meta/Conventions.md`)
- **No CI yet** — CI arrives at the completion gate, and only after `20-Knowledge/Tooling/ci-repair.md`
  is done, or you inherit two broken workflows.

## edit

- Flip `status: complete` **only** through the completion gate: I say it's done → you ask once →
  scaffold CI + `bun test` (+ `cargo test`) → then flip.
- Never ask about completion unprompted.

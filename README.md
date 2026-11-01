# AtlasAta DotFiles

Personal dotfiles for a **dual-boot** machine: Windows 10 Pro and Arch Linux (Hyprland +
[Caelestia](https://github.com/caelestia-dots/caelestia)), on the same hardware.

## Branches

| Branch | Holds | Deployed on |
|---|---|---|
| `main` | Shared material only: fonts, licences, the OpenClaude config | nowhere: cherry-picked into `windows` |
| `windows` | Windows-side config, including Claude Code's `CLAUDE.md` and `settings.json` | Windows, checked out at `C:\dev\AtlasAta-DotFiles` |
| `archlinux` | Selected Arch config (Hyprland, fish, Caelestia, GTK/Qt, editors, apps), including `~/.claude/CLAUDE.md` and `settings.json` | Arch: the repo's working tree is `$HOME`; `.gitignore` whitelists what is tracked |

A machine works on its own branch and carries nothing from the other platform. Each side commits
and pushes only its own changes; on Arch, `dotfiles-backup.sh` does that for `archlinux`.

**Shared changes land on `main` first**, then are cherry-picked into `windows`
(`git cherry-pick -x`), never merged. `archlinux` takes nothing from `windows` and is committed
from Arch only.

## Agent engine

The Claude Code hooks, the `/brain` skill and the `brain-*` commands moved to their own repo,
[knowledge-skeleton](https://github.com/atlasatakahraman/knowledge-skeleton), on 2026-11-01. Its
README covers linking them into `~/.claude` and the per-machine `config.json` they read.

What stays here is per OS: the global `CLAUDE.md` and a copy of `settings.json`, on `windows`
under `agent/claude/default/.claude/` and on `archlinux` at `~/.claude/` itself. On Windows the
`CLAUDE.md` is symlinked rather than copied, so it cannot drift:

```powershell
New-Item -ItemType SymbolicLink -Path $HOME\.claude\CLAUDE.md -Target C:\dev\AtlasAta-DotFiles\agent\claude\default\.claude\CLAUDE.md
```

Not to be confused with `agent/openclaude/CLAUDE.md` and `agent/claude/default/.claude/instructions.md`:
OpenClaude multi-provider configs, not linked anywhere.

## License

**GPL-3.0-only** — [LICENSE](LICENSE). Use, modify and redistribute under the GPL's terms.

Third-party material keeps its own licence and is not covered by that grant — notably
everything under `fonts/`.

SPDX-License-Identifier: `GPL-3.0-only`

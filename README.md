# AtlasAta DotFiles

Personal dotfiles for a **dual-boot** machine: Windows 10 Pro and Arch Linux (Hyprland +
[Caelestia](https://github.com/caelestia-dots/caelestia)), on the same hardware.

## Branches

| Branch | Holds | Deployed on |
|---|---|---|
| `main` | Shared material only: fonts, the agent hooks and commands, licences | nowhere — merged into both |
| `windows` | Windows-side config, and `brain-paths.mjs` for `C:\obsidian\root` / `C:\dev` | Windows, checked out at `C:\dev\AtlasAta-DotFiles` |
| `arch-caelestia` | The Arch `$HOME` (Hyprland, fish, Caelestia, GTK/Qt, editors, apps), and `brain-paths.mjs` for `~/obsidian/root` / `~/dev` | Arch, cloned into `$HOME` |

A machine checks out its own branch and carries nothing from the other platform.

**Shared changes land on `main` first**, then merge into each platform branch:

```bash
git switch main           # commit the shared change here
git switch windows        && git merge main
git switch arch-caelestia && git merge main
```

Another Arch desktop later is a sibling branch (e.g. `arch-kde`) merging the same `main`.

## Agent hooks

`agent/claude/default/.claude/hooks/` is shared code. What differs per OS — the vault root and
the checkouts root — lives in `brain-paths.mjs`, which **only the platform branches carry**.
`main` alone does not run the hooks, deliberately: it is never deployed.

`brain-session.mjs` detects the running OS every session and tells the agent the machine
dual-boots and which side it is on.

Link the hooks into Claude Code's config directory:

```powershell
# Windows
New-Item -ItemType SymbolicLink -Path $HOME\.claude\hooks -Target C:\dev\AtlasAta-DotFiles\agent\claude\default\.claude\hooks
```

```bash
# Arch (repo cloned into $HOME)
ln -s ~/agent/claude/default/.claude/hooks ~/.claude/hooks
```

## License

[AAKNCL v1.0](LICENSE.md) — Non-commercial use only.

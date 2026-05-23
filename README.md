# AtlasAta DotFiles

Personal dotfiles for my Arch Linux + Hyprland setup, backed up automatically to GitHub and Google Drive.

## System

- **OS:** Arch Linux
- **WM:** Hyprland (Wayland)
- **Shell:** Fish
- **Theme:** [Caelestia](https://github.com/caelestia-dots/caelestia)
- **Terminal:** Kitty / Foot
- **Editor:** Neovim / Zed / Cursor
- **Bar/Launcher:** Waybar / Fuzzel

## What's Included

| Category | Path |
|---|---|
| Hyprland config | `.config/caelestia/hypr-*.conf` |
| Fish shell | `.local/share/caelestia/fish/` |
| Neovim | `.config/nvim/` |
| Zed | `.config/zed/` |
| Kitty | `.config/kitty/kitty.conf` |
| Starship prompt | `.config/starship.toml` |
| Spicetify | `.config/spicetify/` |
| EasyEffects | `.config/easyeffects/` |
| GTK 3 / 4 | `.config/gtk-3.0/`, `.config/gtk-4.0/` |
| Qt5ct / Qt6ct | `.config/qt5ct/`, `.config/qt6ct/` |
| GIMP | `.config/GIMP/` |
| Inkscape | `.config/inkscape/` |
| OpenRGB | `.config/OpenRGB/` |
| Discord (Vencord) | `.config/Vencord/`, `.config/discord/settings.json` |
| Spicetify | `.config/spicetify/` |
| Fonts | `fonts/` |
| Gemini config | `.gemini/` |
| Antigravity | `.antigravity/` |
| Caelestia data | `.local/share/caelestia/` |

## Backup Scripts

### `dotfiles-backup.sh` — GitHub backup

Stages all tracked dotfiles and pushes to this repo.

```bash
cd ~ && bash dotfiles-backup.sh
```

### `gdrive-sync.sh` — Google Drive backup

Syncs larger directories (stream, code, minecraft, pictures, videos, github) to Google Drive via rclone.

```bash
bash gdrive-sync.sh
bash gdrive-sync.sh --dry-run       # preview without uploading
bash gdrive-sync.sh --bwlimit=50M   # limit bandwidth
```

**Requires:** `rclone` configured with a remote named `gdrive`.

## Installation

> These are my personal configs — no install script is provided. Feel free to cherry-pick whatever's useful.

```bash
# Clone to home directory
git clone git@github.com:atlasatakahraman/AtlasAta-DotFiles.git ~
```

## License

[AAKNCL v1.0](LICENSE.md) — Non-commercial use only.

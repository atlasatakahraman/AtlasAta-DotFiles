#!/usr/bin/env bash
# ============================================================
# AtlasAta DotFiles Backup — GitHub
# Çalıştır: cd ~ && bash dotfiles-backup.sh
# ============================================================

REMOTE_URL="git@github.com:atlasatakahraman/AtlasAta-DotFiles.git"
BRANCH="main"
COMMIT_MSG="backup: $(date '+%Y-%m-%d %H:%M')"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[✓]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }

cd "$HOME" || error "HOME dizinine gidilemedi"

# ── 1. Git repo ──────────────────────────────────────────────
if [ ! -d ".git" ]; then
    git init && git branch -M "$BRANCH"
fi

if git remote get-url origin &>/dev/null; then
    git remote set-url origin "$REMOTE_URL"
else
    git remote add origin "$REMOTE_URL"
fi
info "Remote: $REMOTE_URL"

# ── 2. .gitattributes (LFS YOK) ──────────────────────────────
cat > .gitattributes << 'EOF'
# AtlasAta DotFiles — LFS kullanılmıyor, sade git
* text=auto eol=lf
*.png binary
*.jpg binary
*.jpeg binary
*.webp binary
*.gif binary
*.ico binary
*.ttf binary
*.otf binary
*.woff binary
*.woff2 binary
*.mp3 binary
*.ogg binary
*.zip binary
*.tar binary
*.gz binary
*.zst binary
*.psd binary
EOF

# ── 3. .gitignore ────────────────────────────────────────────
cat > .gitignore << 'GITIGNORE'
# ============================================================
# GÜVENLİK — asla commit'e girmesin
# ============================================================
.Xauthority
.gnupg/
.ssh/
.pki/
.claude.json
.claude.json.backup.*
.gemini/
**/.env
**/.env.*
!**/.env.example
**/*cookie*
**/*Cookie*
**/*.sqlite
**/*.sqlite-wal
**/*.sqlite-shm
**/*password*
**/*secret*
**/*token*
**/credentials
**/access_token
.anydesk/

# ============================================================
# SHELL & SİSTEM
# ============================================================
.bash_history
.bash_logout
.node_repl_history
.wget-hsts
.bash_profile
.bashrc
.profile

# ============================================================
# YENİDEN KURULABİLİR ARAÇLAR
# ============================================================
.bun/
.cargo/
.rustup/
.npm/
.gradle/
.java/
.android/
.config/go/
.supabase/

# ============================================================
# CACHE & RUNTIME
# ============================================================
.cache/
.nv/
.var/
**/.cache/
**/Cache/
**/Cache_Data/
**/Code Cache/
**/GPUCache/
**/ShaderCache/
**/blob_storage/
**/CrashPad/
**/Crash Reports/
**/Session Storage/
**/Local Storage/
**/IndexedDB/
**/sessionData/
**/Local State
**/Network/
**/NetworkPersist/

# ============================================================
# BÜYÜK MEDYA / DRIVE'A GİDECEKLER
# ============================================================
stream/
Pictures/
Music/
Videos/
Downloads/
github/
minecraft/
fix/
MASAUSTU_KURTARMA/
backup/

# ============================================================
# KOD PROJELERİ — Drive'a gidecek
# ============================================================
code/

# ============================================================
# .CONFIG — tümü ignore, whitelist ile aç
# ============================================================
.config/**

# --- Caelestia (dotfile manager)
!.config/caelestia/
!.config/caelestia/**

# --- Hyprland / Wayland
!.config/hypr/
!.config/hypr/**
!.config/uwsm/
!.config/uwsm/**

# --- Bar / Launcher / Bildirimler
!.config/waybar/
!.config/waybar/**
!.config/fuzzel/
!.config/fuzzel/**
!.config/cava/
!.config/cava/**
!.config/mako/
!.config/mako/**

# --- Terminal
!.config/kitty/
!.config/kitty/**
!.config/foot/
!.config/foot/**
!.config/alacritty/
!.config/alacritty/**

# --- Shell / CLI
!.config/fish/
!.config/fish/**
!.config/starship.toml

# --- Editörler
!.config/nvim/
!.config/nvim/**
!.config/zed/
!.config/zed/**
.config/nvim.bck.2/
.config/nvim.bck.3/
.config/nvim.old/
.config/nvim.old.2/

# --- Sistem monitör
!.config/btop/
!.config/btop/**
!.config/htop/
!.config/htop/**
!.config/nvtop/
!.config/nvtop/**
!.config/fastfetch/
!.config/fastfetch/**

# --- Theming
!.config/gtk-3.0/
!.config/gtk-3.0/**
!.config/gtk-4.0/
!.config/gtk-4.0/**
!.config/Kvantum/
!.config/Kvantum/**
!.config/qt5ct/
!.config/qt5ct/**
!.config/qt6ct/
!.config/qt6ct/**
!.config/kdeglobals
!.config/mimeapps.list
!.config/user-dirs.dirs

# --- Ses
!.config/pipewire/
!.config/pipewire/**
!.config/easyeffects/
!.config/easyeffects/**
!.config/easyeffectsrc
!.config/pavucontrol.ini

# --- Medya
!.config/mpv/
!.config/mpv/**
!.config/vlc/
!.config/vlc/**

# --- Ekran görüntüsü
!.config/flameshot/
!.config/flameshot/**

# --- Müzik / Spicetify
!.config/spicetify/
!.config/spicetify/**
!.config/spotify/
.config/spotify/**
!.config/spotify/prefs

# --- Discord istemcileri
!.config/Vencord/
!.config/Vencord/**
!.config/BetterDiscord/
!.config/BetterDiscord/**
!.config/vesktop/
!.config/vesktop/**
!.config/discord/
!.config/discord/**
!.config/legcord/
!.config/legcord/**
!.config/equibop/
!.config/equibop/**
!.config/Equicord/
!.config/Equicord/**

# --- Tarayıcılar
!.config/vivaldi/
.config/vivaldi/**
!.config/vivaldi/Default/
.config/vivaldi/Default/**
!.config/vivaldi/Default/Preferences
!.config/vivaldi/Default/Bookmarks

# --- Antigravity (sadece config, extension binary'leri hariç)
!.config/Antigravity/
.config/Antigravity/**
!.config/Antigravity/argv.json
!.config/Antigravity/extensions/
!.config/Antigravity/extensions/**
.config/Antigravity/extensions/**/node_modules/

# --- Yaratıcı araçlar
!.config/GIMP/
!.config/GIMP/**
!.config/inkscape/
!.config/inkscape/**
!.config/OpenRGB/
!.config/OpenRGB/**

# --- VS Code OSS / Cursor / Antigravity editör
!.config/Code - OSS/
!.config/Code - OSS/User/
!.config/Code - OSS/User/settings.json
!.config/Code - OSS/User/keybindings.json
!.config/Code - OSS/User/snippets/
!.config/Code - OSS/User/snippets/**
!.config/cursor/
!.config/cursor/User/
!.config/cursor/User/settings.json
!.config/cursor/User/keybindings.json
!.config/Cursor/
!.config/Cursor/User/
!.config/Cursor/User/settings.json
!.config/Cursor/User/keybindings.json

# --- Notion
!.config/Notion/
.config/Notion/**
!.config/Notion/config.json

# --- KDE araçları (Thunar, Kate, Dolphin)
!.config/Thunar/
!.config/Thunar/**
!.config/kate/
!.config/kate/**
!.config/katerc
!.config/katevirc
!.config/kate-externaltoolspluginrc
!.config/kdeglobals
!.config/QtProject.conf
!.config/dolphinrc

# --- Systemd user units (önemli!)
!.config/systemd/
!.config/systemd/**

# --- Autostart
!.config/autostart/
!.config/autostart/**

# --- Diğer küçük config'ler
!.config/yay/
!.config/yay/**
!.config/session/
!.config/session/**

# ============================================================
# .LOCAL — seçici
# ============================================================
.local/share/**

# Caelestia (symlink source of truth)
!.local/share/caelestia/
!.local/share/caelestia/**

# PrismLauncher — config tut, instance'ları değil
!.local/share/PrismLauncher/
!.local/share/PrismLauncher/**
.local/share/PrismLauncher/instances/
.local/share/PrismLauncher/libraries/
.local/share/PrismLauncher/metacache/
.local/share/PrismLauncher/meta/
.local/share/PrismLauncher/jars/

# MultiMC — config tut
!.local/share/multimc/
!.local/share/multimc/**
.local/share/multimc/instances/
.local/share/multimc/libraries/

# Fish shell data
!.local/share/fish/
!.local/share/fish/**

# Nvim veri
!.local/share/nvim/
!.local/share/nvim/**

# Zed
!.local/share/zed/
!.local/share/zed/**

# Fontlar
!.local/share/fonts/
!.local/share/fonts/**

# Tauri uygulama verileri (atlasata)
!.local/share/com.atlasata.theatlas/
!.local/share/com.atlasata.theatlas/**
!.local/share/com.atlasata.theatlas-youtube/
!.local/share/com.atlasata.theatlas-youtube/**

.local/state/
.local/bin/

# ============================================================
# MOZİLLA — sadece userChrome.css
# ============================================================
.mozilla/**
!.mozilla/firefox/
!.mozilla/firefox/*/
.mozilla/firefox/*/**
!.mozilla/firefox/*/chrome/
!.mozilla/firefox/*/chrome/userChrome.css
!.mozilla/firefox/*/chrome/userContent.css

# ============================================================
# ANTIGRAVITY EXTENSİONS (home root'taki)
# ============================================================
.antigravity/
!.antigravity/argv.json

# ============================================================
# KÜÇÜK DOSYALAR — dahil et
# ============================================================
# fonts/, aseprite/, shortcuts/ dahil edilir (exclude yok)

# ============================================================
# MİSC
# ============================================================
*.log
Thumbs.db
.DS_Store
desktop.ini
lfs_cozucu.py
.gitconfig
.config.bak/
.vscode-oss/
.vscode-oss-shared/
.local/share/Trash/
GITIGNORE

info ".gitignore ve .gitattributes yazıldı"

# ── 4. Stage & Commit ────────────────────────────────────────
info "Dosyalar stage ediliyor..."
git add -A

STAGED=$(git diff --cached --name-only | wc -l)
if [ "$STAGED" -eq 0 ]; then
    warning "Değişiklik yok, zaten güncel."
    exit 0
fi
info "$STAGED dosya stage edildi"

git commit -m "$COMMIT_MSG" || {
    warning "Commit yapılamadı"
    exit 0
}
info "Commit: $COMMIT_MSG"

# ── 5. Push ──────────────────────────────────────────────────
info "GitHub'a push ediliyor..."
if git ls-remote --exit-code origin "$BRANCH" &>/dev/null; then
    git push origin "$BRANCH" || {
        warning "Normal push başarısız, force-with-lease deneniyor..."
        git push origin "$BRANCH" --force-with-lease
    }
else
    git push -u origin "$BRANCH" || {
        error "Push başarısız. Repo oluşturuldu mu?\n  gh repo create AtlasAta-DotFiles --private"
    }
fi

info "✅ Dotfiles backup tamamlandı → github.com/atlasatakahraman/AtlasAta-DotFiles"
